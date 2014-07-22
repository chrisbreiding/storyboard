reqwest = require 'reqwest'
_ = require 'lodash'
RSVP = require 'rsvp'
store = require './store'

BASE_URL = 'https://www.pivotaltracker.com/services/v5/'
POLL_INTERVAL = 1000

module.exports =

  apiToken: store.fetch 'apiToken'

  getProjects: ->
    @_queryPivotal('projects').then (projects)->
      _.map projects, (project)->
        _.pick project, 'id', 'name', 'version'

  getProject: (id)->
    @_queryPivotal("projects/#{id}", fields: 'name,version,current_velocity').then (project)->
      _.pick project, 'id', 'name', 'version', 'current_velocity'

  getIterations: (projectId)->
    current = @_queryIterations projectId, 'current', true
    backlog = @_queryIterations projectId, 'backlog'

    RSVP.all([current, backlog]).then (results)->
      _.flatten results

  getBacklogCount: (projectId)-> @_getCount projectId, 'unstarted'

  getIceboxCount: (projectId)-> @_getCount projectId, 'unscheduled'

  _getCount: (projectId, state)->
    @_queryPivotal("projects/#{projectId}/stories", with_state: state).then (stories)->
      stories.length

  _queryIterations: (projectId, scope, withOwners = false)->
    @_queryPivotal("projects/#{projectId}/iterations", scope: scope).then (iterations)=>
      @_mapIterations projectId, iterations, withOwners

  _mapIterations: (projectId, iterations, withOwners)->
    new RSVP.Promise (resolve)=>
      ownerPromises = []
      curatedIterations = _.map iterations, (iteration)=>
        number: iteration.number
        start: new Date(iteration.start)
        finish: new Date(iteration.finish)
        stories: _.map iteration.stories, (story)=>
          curatedStory = _.pick story, 'id', 'name', 'current_state', 'story_type', 'estimate', 'accepted_at'
          curatedStory.labels = _.pluck story.labels, 'name'
          if withOwners
            ownerPromises.push @_queryPivotal("projects/#{projectId}/stories/#{story.id}/owners").then (owners)->
              curatedStory.owners = _.pluck owners, 'initials'
          curatedStory

      RSVP.all(ownerPromises).then ->
        resolve curatedIterations

  listenForProjectUpdates: (id, version, onUpdate)->
    if @projectData? and @projectData.id isnt id
      clearInterval @projectData.interval

    queryForUpdates = =>
      currentVersion = @projectData.version
      @_queryPivotal("project_stale_commands/#{id}/#{currentVersion}").then (info) =>
        if currentVersion isnt info.project_version
          @projectData.version = info.project_version
          onUpdate()

    @projectData =
      id: id
      version: version
      interval: setInterval(queryForUpdates,  POLL_INTERVAL)

  _queryPivotal: (url, data)->
    reqwest
      url: "#{BASE_URL}#{url}"
      data: data
      headers:
        'X-TrackerToken': @apiToken
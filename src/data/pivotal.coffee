$ = require 'jquery'
_ = require 'lodash'
RSVP = require 'rsvp'
store = require './store'

BASE_URL = 'https://www.pivotaltracker.com/services/v5/'
POLL_INTERVAL = 1000

module.exports =

  apiToken: store.fetch 'apiToken'

  getProjects: ->
    @queryPivotal('projects').then (projects)->
      _.map projects, (project)->
        _.pick project, 'id', 'name', 'version'

  getProject: (id)->
    @queryPivotal("projects/#{id}").then (project)->
      _.pick project, 'id', 'name', 'version'

  getIterations: (projectId)->
    current = @_queryIterations projectId, 'current', true
    backlog = @_queryIterations projectId, 'backlog'

    RSVP.all([current, backlog]).then (results)->
      _.flatten results

  _queryIterations: (projectId, scope, withOwners = false)->
    @queryPivotal("projects/#{projectId}/iterations", scope: scope).then (iterations)=>
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
            ownerPromises.push @queryPivotal("projects/#{projectId}/stories/#{story.id}/owners").then (owners)->
              curatedStory.owners = _.pluck owners, 'initials'
          curatedStory

      RSVP.all(ownerPromises).then ->
        resolve curatedIterations

  listenForProjectUpdates: (id, version, onUpdate)->
    if @projectData? and @projectData.id isnt id
      clearInterval @projectData.interval

    queryForUpdates = =>
      currentVersion = @projectData.version
      @queryPivotal("project_stale_commands/#{id}/#{currentVersion}").then (info) =>
        if currentVersion isnt info.project_version
          @projectData.version = info.project_version
          onUpdate()

    @projectData =
      id: id
      version: version
      interval: setInterval(queryForUpdates,  POLL_INTERVAL)

  queryPivotal: (url, data)->
    $.ajax
      type: 'GET'
      url: "#{BASE_URL}#{url}"
      data: data
      headers:
        'X-TrackerToken': @apiToken

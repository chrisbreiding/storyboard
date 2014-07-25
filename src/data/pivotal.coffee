reqwest = require 'reqwest'
_ = require 'lodash'
RSVP = require 'rsvp'
store = require './store'

BASE_URL = 'https://www.pivotaltracker.com/services/v5/'
POLL_INTERVAL = 1000

module.exports =

  apiToken: store.fetch 'apiToken'

  inProgressStoryTypes: ['started', 'finished', 'delivered', 'rejected']

  getProjects: ->
    @_queryPivotal 'projects'

  getProject: (id)->
    @_queryPivotal "projects/#{id}", fields: 'name,version,current_velocity'

  getIterations: (projectId)->
    current = @_queryIterations projectId, 'current', true
    backlog = @_queryIterations projectId, 'backlog'

    RSVP.all([current, backlog]).then (results)-> _.flatten results

  getBacklogCount: (projectId)-> @_getCount projectId, 'unstarted'

  getIceboxCount: (projectId)-> @_getCount projectId, 'unscheduled'

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
      interval: setInterval queryForUpdates,  POLL_INTERVAL

  _getCount: (projectId, state)->
    @_queryPivotal("projects/#{projectId}/stories", with_state: state, limit: 101).then (stories)->
      if stories.length <= 100 then stories.length else '100+'

  _queryIterations: (projectId, scope, withOwners = false)->
    @_queryPivotal("projects/#{projectId}/iterations", scope: scope).then (iterations)=>
      @_mapIterations projectId, iterations, withOwners

  _mapIterations: (projectId, iterations, withOwners)->
    new RSVP.Promise (resolve)=>
      promises = []
      curatedIterations = _.map iterations, (iteration)=>
        iteration.start = new Date(iteration.start)
        iteration.finish = new Date(iteration.finish)
        stories: _.map iteration.stories, (story)=>
          if _.contains @inProgressStoryTypes, story.current_state
            promises.push @_queryPivotal("projects/#{projectId}/stories/#{story.id}/tasks").then (tasks)->
              story.tasks = tasks

          if withOwners
            promises.push @_queryPivotal("projects/#{projectId}/stories/#{story.id}/owners").then (owners)->
              story.owners = owners

          story

      RSVP.all(promises).then ->
        resolve curatedIterations

  _queryPivotal: (url, data)->
    reqwest
      url: "#{BASE_URL}#{url}"
      data: data
      headers:
        'X-TrackerToken': @apiToken

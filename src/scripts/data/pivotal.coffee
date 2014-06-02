BASE_URL = 'https://www.pivotaltracker.com/services/v5/'
PROJECT_UPDATES_POLL_INTERVAL = 3 * 1000

Pivotal = Ember.Object.extend

  init: ->
    @set 'token', App.settings.getValue 'apiToken', null

  isAuthenticated: ->
    @get('token')?

  setToken: (token)->
    App.settings.updateString 'apiToken', token
    @set 'token', token

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

    Ember.RSVP.all([current, backlog]).then (results)->
      _.flatten results

  _queryIterations: (projectId, scope, withOwners = false)->
    @queryPivotal("projects/#{projectId}/iterations", scope: scope).then (iterations)=>
      @_mapIterations projectId, iterations, withOwners

  _mapIterations: (projectId, iterations, withOwners)->
    new Ember.RSVP.Promise (resolve)=>
      ownerPromises = []
      curatedIterations = _.map iterations, (iteration)=>
        Ember.Object.create
          start: new Date(iteration.start)
          finish: new Date(iteration.finish)
          expanded: true
          stories: _.map iteration.stories, (story)=>
            curatedStory = _.pick story, 'id', 'name', 'current_state', 'story_type', 'estimate', 'accepted_at'
            curatedStory.labels = _.pluck story.labels, 'name'
            if withOwners
              ownerPromises.push @queryPivotal("projects/#{projectId}/stories/#{story.id}/owners").then (owners)->
                curatedStory.owners = _.pluck owners, 'initials'
            curatedStory

      Ember.RSVP.all(ownerPromises).then ->
        resolve curatedIterations

  listenForProjectUpdates: (project)->
    if @get('projectData.id') isnt project.id
      clearInterval @get('projectData.interval')

    queryForUpdates = =>
      currentVersion = @get 'projectData.version'
      @queryPivotal("project_stale_commands/#{project.id}/#{currentVersion}").then (info) =>
        if currentVersion isnt info.project_version
          @set 'projectData.version', info.project_version
          App.eventBus.trigger 'projectUpdated'

    @set 'projectData',
      id: project.id
      version: project.version
      interval: setInterval(queryForUpdates,  PROJECT_UPDATES_POLL_INTERVAL)

  queryPivotal: (url, data)->
    $.ajax
      type: 'GET'
      url: "#{BASE_URL}#{url}"
      data: data
      headers:
        'X-TrackerToken': @get 'token'

App.pivotal = Pivotal.create()

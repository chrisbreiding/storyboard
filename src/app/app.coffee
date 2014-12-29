React = require 'react'
RSVP = require 'rsvp'
_ = require 'lodash'

pivotal = require '../data/pivotal'
Login = require '../login/login'
Project = require '../project/project'
Settings = require '../settings/settings'
Store = require '../data/store'

fontSizeMatch = location.search.match /\?.*font-?[Ss]ize\=(\d+)/i
if fontSizeMatch and fontSizeMatch[1]
  fontSizeOverride = fontSizeMatch[1]

idMatch = location.search.match /\?.*id\=(\d+)/
id = if idMatch then "-#{idMatch[1]}" else ''

namespace = "storyboard#{id}"
store = new Store namespace

apiToken = store.fetch 'apiToken'
pivotal.setApiToken apiToken

module.exports = React.createClass

  getInitialState: ->
    apiToken: apiToken
    projectId: store.fetch 'projectId'

    inProgressMax: store.fetch('inProgressMax') or 5
    baseFontSize: fontSizeOverride or store.fetch('baseFontSize') or 24
    baseFontSizeOverridden: !!fontSizeOverride
    showAcceptedType: store.fetch('showAcceptedType') or 'count'
    showAcceptedValue: store.fetch('showAcceptedValue') or 2

  render: ->
    mainView = if @state.apiToken
      if @state.project
        project = Project _.extend {}, @state.project,
          overInProgressLimit: @state.project.storiesInProgress > @state.inProgressMax
          showAcceptedType: @state.showAcceptedType
          showAcceptedValue: @state.showAcceptedValue

      settings = Settings _.extend {}, @state,
        autoOpen: !@state.projectId?
        onUpdate: @updateSetting
        onSave: @saveSettings

      React.DOM.div null, project, settings
    else
      Login onLogin: @updateApiToken

    React.DOM.div
      style: fontSize: @state.baseFontSize
    , mainView

  updateApiToken: (apiToken)->
    pivotal.setApiToken apiToken
    store.save 'apiToken', apiToken
    @setState apiToken: apiToken, =>
      @_updateProjects()

  updateSetting: (setting)->
    @setState setting, =>
      @_updateProject(setting.projectId, @state.projects) if setting.projectId?

  saveSettings: ->
    store.save
      projectId: @state.projectId
      inProgressMax: @state.inProgressMax
      baseFontSize: @state.baseFontSize
      showAcceptedType: @state.showAcceptedType
      showAcceptedValue: @state.showAcceptedValue

  componentDidMount: ->
    @_updateProjects() if @state.apiToken

  _updateProjects: ->
    pivotal.getProjects().then (projects)=>
      projectId = @state.projectId or do ->
        store.save 'projectId', projectId
        projects[0].id

      @_updateProject projectId, projects

  _updateProject: (projectId, projects)->
    pivotal.getProject(projectId).then (project)=>

      pivotal.listenForProjectUpdates projectId, project.version, =>
        @_update project, projects

      @_update project, projects

  _update: (project, projects)->
    updates =
      iterations: pivotal.getIterations project.id
      backlogCount: pivotal.getBacklogCount project.id
      iceboxCount: pivotal.getIceboxCount project.id

    RSVP.hash(updates).then (result)=>
      @setState
        projects: projects
        project: _.extend result,
          version: project.version
          velocity: project.current_velocity
          storiesInProgress: @_storiesInProgress(result.iterations).length
          pointsInProgress: @_numPointsInProgress result.iterations

  _numPointsInProgress: (iterations)->
    _.reduce @_storiesInProgress(iterations), (total, story)->
      total + (story.estimate or 0)
    , 0

  _storiesInProgress: (iterations)->
    return [] unless iterations?[0]?.stories?

    _.filter iterations[0].stories, (story)->
      _.contains pivotal.inProgressStoryTypes, story.current_state

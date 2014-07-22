React = require 'react'
_ = require 'lodash'
pivotal = require '../data/pivotal'
Login = require '../login/login'
Stats = require '../stats/stats'
Project = require '../project/project'
Settings = require '../settings/settings'
store = require '../data/store'

fontSizeMatch = location.search.match /\?.*font-?[Ss]ize\=(\d+)/i
if fontSizeMatch and fontSizeMatch[1]
  fontSizeOverride = fontSizeMatch[1]

module.exports = React.createClass

  getInitialState: ->
    apiToken: store.fetch 'apiToken'
    projectId: store.fetch 'projectId'
    inProgressMax: store.fetch('inProgressMax') or 5
    baseFontSize: fontSizeOverride or store.fetch('baseFontSize') or 24
    baseFontSizeOverridden: !!fontSizeOverride
    showAcceptedType: store.fetch('showAcceptedType') or 'count'
    showAcceptedValue: store.fetch('showAcceptedValue') or 2
    storiesInProgress: 0
    pointsInProgress: 0
    velocity: 0
    backlogCount: 0
    iceboxCount: 0

  render: ->
    mainView = if @state.apiToken
      stats = Stats
        velocity: @state.velocity
        storiesInProgress: @state.storiesInProgress
        overInProgressLimit: @state.storiesInProgress > @state.inProgressMax
        pointsInProgress: @state.pointsInProgress
        backlogCount: @state.backlogCount
        iceboxCount: @state.iceboxCount

      project = Project
        ref: 'project'
        id: @state.projectId
        showAcceptedType: @state.showAcceptedType
        showAcceptedValue: @state.showAcceptedValue
        onUpdate: @projectUpdated

      settings = Settings _.extend {}, @state,
        onUpdate: @updateSetting
        onSave: @saveSettings

      React.DOM.div null, stats, project, settings
    else
      Login onLogin: @updateApiToken
    React.DOM.div
      style: fontSize: @state.baseFontSize
    , mainView

  updateApiToken: (apiToken)->
    store.save 'apiToken', apiToken
    pivotal.apiToken = apiToken
    pivotal.getProjects().then (projects)=>
      projectId = projects[0].id
      store.save 'projectId', projectId
      @setState
        apiToken: apiToken
        projectId: projectId
        projects: projects

  projectUpdated: ->
    @setState
      storiesInProgress: @refs.project.storiesInProgress()
      pointsInProgress: @refs.project.pointsInProgress()
      velocity: @refs.project.state.velocity
      backlogCount: @refs.project.state.backlogCount
      iceboxCount: @refs.project.state.iceboxCount

  updateSetting: (setting)->
    @setState setting

  saveSettings: ->
    store.save
      projectId: @state.projectId
      inProgressMax: @state.inProgressMax
      baseFontSize: @state.baseFontSize
      showAcceptedType: @state.showAcceptedType
      showAcceptedValue: @state.showAcceptedValue

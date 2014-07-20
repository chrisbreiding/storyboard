React = require 'react'
_ = require 'lodash'
pivotal = require '../data/pivotal'
Login = require '../login/login'
Project = require '../project/project'
Settings = require '../settings/settings'
store = require '../data/store'

module.exports = React.createClass

  getInitialState: ->
    apiToken: store.fetch 'apiToken'
    projectId: store.fetch 'projectId'
    inProgressMax: store.fetch('inProgressMax') or 5
    baseFontSize: store.fetch('baseFontSize') or 24
    showAcceptedType: store.fetch('showAcceptedType') or 'count'
    showAcceptedValue: store.fetch('showAcceptedValue') or 2
    storiesInProgress: 0

  render: ->
    mainView = if @state.apiToken
      bannerClass = if @state.storiesInProgress > @state.inProgressMax
        'banner show'
      else
        'banner'

      banner = React.DOM.div
        className: bannerClass
      , "There are over #{@state.inProgressMax} stories in progress"

      project = Project
        ref: 'project'
        id: @state.projectId
        onUpdate: @projectUpdated

      settings = Settings _.extend {}, @state,
        onUpdate: @updateSetting
        onSave: @saveSettings

      React.DOM.div null, banner, project, settings
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
    @setState storiesInProgress: @refs.project.storiesInProgress()

  updateSetting: (setting)->
    @setState setting

  saveSettings: ->
    store.save
      projectId: @state.projectId
      inProgressMax: @state.inProgressMax
      baseFontSize: @state.baseFontSize
      showAcceptedType: @state.showAcceptedType
      showAcceptedValue: @state.showAcceptedValue

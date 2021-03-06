React = require 'react'
_ = require 'lodash'

numberProps = ['inProgressMax', 'baseFontSize', 'showAcceptedValue']

module.exports = React.createClass

  getDefaultProps: ->
    projects: []

  render: ->
    [inflectedStory, inflectedDay] = if @props.showAcceptedValue is 1
       ['story', 'day']
    else
      ['stories', 'days']

    [showAcceptedPrefix, showAcceptedSuffix] = switch @props.showAcceptedType
      when 'count'
        ['Show up to', "accepted #{inflectedStory}"]
      when 'age'
        ['Show accepted stories up to', "#{inflectedDay} old"]

    React.DOM.div
      ref: 'container'
      className: 'settings-container'
    ,
      React.DOM.div
        className: 'open-settings-surface'
      ,
        React.DOM.button
          className: 'open-settings'
          onClick: @open
        ,
          React.DOM.i className: 'fa fa-cog'
    ,
      React.DOM.form
        className: 'settings'
        onSubmit: @save
      ,
        React.DOM.fieldset
          className: 'project-picker'
        ,
          React.DOM.label null, 'Project:'
        ,
          React.DOM.select
            ref: 'projectId'
            value: @props.projectId
            onChange: _.partial @updateSetting, 'projectId'
          ,
            @props.projects.map (project)->
              React.DOM.option key: project.id, value: project.id, project.name
      ,
        React.DOM.fieldset null,
          React.DOM.label null, 'Max. stories in progress before warning:'
        ,
          React.DOM.input
            ref: 'inProgressMax'
            value: @props.inProgressMax
            type: 'number'
            min: 0
            onChange: _.partial @updateSetting, 'inProgressMax'
      ,
        React.DOM.fieldset
          className: if @props.baseFontSizeOverridden then 'base-font-size overridden' else 'base-font-size'
        ,
          React.DOM.label null, 'Base font size:'
        ,
          React.DOM.input
            ref: 'baseFontSize'
            value: @props.baseFontSize
            type: 'number'
            min: 10
            onChange: _.partial @updateSetting, 'baseFontSize'
        ,
          React.DOM.span className: 'suffix', 'px'
        ,
          React.DOM.p null, 'Overridden by font size specified in URL'
      ,
        React.DOM.fieldset null,
          React.DOM.label null, 'Limit accepted stories by'
        ,
          React.DOM.select
            ref: 'showAcceptedType'
            value: @props.showAcceptedType
            onChange: _.partial @updateSetting, 'showAcceptedType'
          ,
            ['count', 'age'].map (type)->
              React.DOM.option key: type, type
      ,
        React.DOM.fieldset null,
          React.DOM.label null, showAcceptedPrefix
        ,
          React.DOM.input
            ref: 'showAcceptedValue'
            value: @props.showAcceptedValue
            type: 'number'
            min: 0
            onChange: _.partial @updateSetting, 'showAcceptedValue'
        ,
          React.DOM.span className: 'suffix', showAcceptedSuffix
      ,
        React.DOM.button type: 'submit', 'Save'

  open: ->
    @refs.container.getDOMNode().className = 'settings-container open'

  updateSetting: (key)->
    value = @refs[key].getDOMNode().value
    if _.contains numberProps, key
      value = Number value

    setting = {}
    setting[key] = value
    @props.onUpdate setting

  save: (e)->
    e.preventDefault()

    @refs.container.getDOMNode().className = 'settings-container'
    @props.onSave()

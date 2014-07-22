React = require 'react'

Stat = React.createClass
  render: ->
    React.DOM.div
      className: @props.type
    ,
      React.DOM.i className: "fa fa-#{@props.icon}"
    ,
      React.DOM.span null, @props.value
    ,
      React.DOM.p null, @props.label or @props.type

module.exports = React.createClass

  render: ->
    React.DOM.div
      className: 'stats'
    ,
      Stat
        type: 'velocity'
        icon: 'fighter-jet'
        value: @props.velocity
    ,
      Stat
        type: if @props.overInProgressLimit then 'stories-in-progress warning' else 'stories-in-progress'
        label: 'stories in progress'
        icon: 'refresh'
        value: @props.storiesInProgress
    ,
      Stat
        type: 'points-in-progress'
        label: 'points in progress'
        icon: 'bullseye'
        value: @props.pointsInProgress
    ,
      Stat
        type: 'backlog'
        label: 'stories in backlog'
        icon: 'list-ul'
        value: @props.backlogCount
    ,
      Stat
        type: 'icebox'
        label: 'stories in icebox'
        icon: 'asterisk'
        value: @props.iceboxCount

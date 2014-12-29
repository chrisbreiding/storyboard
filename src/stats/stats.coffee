React = require 'react'

RD = React.DOM

Stat = React.createClass
  render: ->
    RD.div
      className: @props.type
    ,
      RD.i className: "fa fa-#{@props.icon}"
    ,
      RD.span null, @props.value
    ,
      RD.p null, @props.label or @props.type

module.exports = React.createClass

  render: ->
    RD.div
      className: 'stats'
    ,
      RD.h2 null, @props.name
    ,
      Stat
        type: 'velocity'
        icon: 'dashboard'
        value: @props.velocity
    ,
      Stat
        type: if @props.overInProgressLimit then 'stories-in-progress warning' else 'stories-in-progress'
        label: 'stories in progress'
        icon: 'tasks'
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
        icon: 'list'
        value: @props.backlogCount

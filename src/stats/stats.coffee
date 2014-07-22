React = require 'react'

Stat = React.createClass
  render: ->
    React.DOM.div
      className: @props.type
    ,
      React.DOM.i className: "fa fa-#{@props.icon}"
    ,
      React.DOM.span null, @props.value

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
        type: if @props.overInProgressLimit then 'in-progress warning' else 'in-progress'
        icon: 'refresh'
        value: @props.storiesInProgress
    ,
      Stat
        type: 'backlog'
        icon: 'list-ul'
        value: @props.backlogCount
    ,
      Stat
        type: 'icebox'
        icon: 'asterisk'
        value: @props.iceboxCount

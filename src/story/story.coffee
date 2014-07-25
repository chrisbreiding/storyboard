React = require 'react'
marked = require 'marked'
_ = require 'lodash'

storyIcon = (storyType, estimate)->
  className = switch storyType
    when 'feature' then 'fa-certificate'
    when 'chore' then 'fa-wrench'
    when 'bug' then 'fa-bug'
    when 'release' then 'fa-flag-checkered'
  if estimate
    estimate = React.DOM.span className: 'estimate', estimate
  React.DOM.i className: "story-type fa #{className}", estimate

storyState = (state)->
  if state
    React.DOM.span className: 'state-meter'

owners = (owners)->
  if owners
    React.DOM.ul
      className: 'owners'
    ,
      owners.map (owner, i)-> React.DOM.li key: i, owner.initials

tasks = (tasks)->
  if tasks and tasks.length
    completed = _.reduce tasks, (total, task)->
      total + (task.complete | 0)
    , 0

    React.DOM.span
      className: 'tasks'
    ,
      React.DOM.i className: 'fa fa-list-ul'
    ,
      React.DOM.span null, "#{completed}/#{tasks.length}"

module.exports = React.createClass

  render: ->
    React.DOM.li
      className: "#{@props.current_state} #{@props.story_type}"
    ,
      storyState @props.current_state
    ,
      storyIcon @props.story_type, @props.estimate
    ,
      tasks @props.tasks
    ,
      React.DOM.ul
        className: 'labels'
      ,
        @props.labels.map (label, i)-> React.DOM.li key: i, label.name
    ,
      React.DOM.div
        className: 'main'
      ,
        React.DOM.div
          dangerouslySetInnerHTML: __html: marked @props.name
      ,
        owners @props.owners

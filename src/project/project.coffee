React = require 'react'
RSVP = require 'rsvp'
_ = require 'lodash'
pivotal = require '../data/pivotal'
Iteration = require '../iteration/iteration'

module.exports = React.createClass

  getInitialState: ->
    iterations: []
    version: 0
    velocity: 0
    backlogCount: 0
    iceboxCount: 0

  render: ->
    React.DOM.div
      className: 'project'
    ,
      @state.iterations.map (iteration)=>
        iteration.key = iteration.number
        iteration.showAcceptedType = @props.showAcceptedType
        iteration.showAcceptedValue = @props.showAcceptedValue
        Iteration iteration

  componentDidMount: ->
    @_updateProject()

  componentDidUpdate: (prevProps)->
    if prevProps.id isnt @props.id
      @_updateProject()

  storiesInProgress: ->
    @_storiesInProgress().length

  pointsInProgress: ->
    _.reduce @_storiesInProgress(), (total, story)->
      total += story.estimate
      total
    , 0

  _storiesInProgress: ->
    return [] unless @state.iterations.length and @state.iterations[0].stories.length

    _.filter @state.iterations[0].stories, (story)->
      _.contains pivotal.inProgressStoryTypes, story.current_state

  _updateProject: ->
    pivotal.getProject(@props.id).then (project)=>
      @setState
        version: project.version
        velocity: project.current_velocity

      pivotal.listenForProjectUpdates project.id, project.version, =>
        @_update()

      @_update()

  _update: ->
    updates =
      iterations: pivotal.getIterations @props.id
      backlogCount: pivotal.getBacklogCount @props.id
      iceboxCount: pivotal.getIceboxCount @props.id

    RSVP.hash(updates).then (result)=>
      @setState
        iterations: result.iterations
        backlogCount: result.backlogCount
        iceboxCount: result.iceboxCount
      , =>
        @props.onUpdate()

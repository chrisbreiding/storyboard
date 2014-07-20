React = require 'react'
pivotal = require '../data/pivotal'
Iteration = require '../iteration/iteration'

module.exports = React.createClass

  getInitialState: ->
    iterations: []

  render: ->
    React.DOM.div
      className: 'project'
    ,
      @state.iterations.map (iteration)->
        iteration.key = iteration.number
        Iteration iteration

  componentDidMount: ->
    @_updateProject()

  componentDidUpdate: (prevProps)->
    if prevProps.id isnt @props.id
      @_updateProject()

  _updateProject: ->
    pivotal.getProject(@props.id).then (project)=>
      @setState version: project.version

      @_updateIterations()
      pivotal.listenForProjectUpdates project.id, project.version, =>
        @_updateIterations()

  _updateIterations: ->
    pivotal.getIterations(@props.id).then (iterations)=>
      @setState {iterations}

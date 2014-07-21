React = require 'react'
RSVP = require 'rsvp'
_ = require 'lodash'
pivotal = require '../data/pivotal'
Iteration = require '../iteration/iteration'

inProgressStoryTypes = ['started', 'finished', 'delivered', 'rejected']

module.exports = React.createClass

  getInitialState: ->
    iterations: []

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
    return 0 unless @state.iterations.length and @state.iterations[0].stories.length

    stories = @state.iterations[0].stories
    storiesInProgress = _.filter stories, (story)->
      _.contains inProgressStoryTypes, story.current_state

    storiesInProgress.length

  _updateProject: ->
    pivotal.getProject(@props.id).then (project)=>
      @setState version: project.version

      pivotal.listenForProjectUpdates project.id, project.version, =>
        @_updateIterations()

      @_updateIterations().then =>
        @props.onUpdate()

  _updateIterations: ->
    pivotal.getIterations(@props.id).then (iterations)=>
      new RSVP.Promise (resolve)=>
        @setState {iterations}, resolve

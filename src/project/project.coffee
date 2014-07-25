React = require 'react'
_ = require 'lodash'
Stats = require '../stats/stats'
Iteration = require '../iteration/iteration'

module.exports = React.createClass

  render: ->
    React.DOM.div
      className: 'project'
    ,
      Stats _.extend {}, @props
    ,
      React.DOM.div null,
        @props.iterations.map (iteration)=>
          iteration.key = iteration.number
          iteration.showAcceptedType = @props.showAcceptedType
          iteration.showAcceptedValue = @props.showAcceptedValue
          Iteration iteration

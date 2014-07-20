React = require 'react'

module.exports = React.createClass

  render: ->
    React.DOM.section
      className: 'login-container'
    ,
      React.DOM.h2 null, 'Please Authenticate'
    ,
      React.DOM.form
        onSubmit: @login
      ,
        React.DOM.input ref: 'apiToken', placeholder: "API Token"
      ,
        React.DOM.button type: 'submit', 'Authenticate'

  login: (e)->
    e.preventDefault()
    @props.onLogin @refs.apiToken.getDOMNode().value

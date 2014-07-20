React = require 'react'
moment = require 'moment'
Story = require '../story/story'

formatDate = (date)-> moment(date).format 'MMM D'

module.exports = React.createClass

  render: ->
    React.DOM.div
      className: 'iteration'
    ,
      React.DOM.h4 null, "#{formatDate @props.start} - #{formatDate @props.finish}"
    ,
      React.DOM.ul
        className: 'stories'
      ,
        @props.stories.map (story)->
          story.key = story.id
          Story story

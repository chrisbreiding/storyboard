React = require 'react'
moment = require 'moment'
_ = require 'lodash'
Story = require '../story/story'

formatDate = (date)-> moment(date).format 'MMM D'

module.exports = React.createClass

  render: ->
    stories = @props.stories
    filteredStories = _.filter stories, (story, index)=>
      cutoff = if @props.showAcceptedType is 'count'
        numAcceptedStories = (_.filter stories, (story)=> @storyIsAccepted story).length
        cutoff = numAcceptedStories - @props.showAcceptedValue
        if cutoff >= 0 then cutoff else 0
      else
        moment().startOf('day').subtract('days', @props.showAcceptedValue).unix()

      if @storyIsAccepted story
        value = if @props.showAcceptedType is 'count'
          index
        else
          moment(story.accepted_at).startOf('day').unix()

        value >= cutoff
      else
        true

    React.DOM.div
      className: 'iteration'
    ,
      React.DOM.h4 null, "#{formatDate @props.start} - #{formatDate @props.finish}"
    ,
      React.DOM.ul
        className: 'stories'
      ,
        filteredStories.map (story)->
          story.key = story.id
          Story story

  storyIsAccepted: (story)->
    story.current_state is 'accepted'

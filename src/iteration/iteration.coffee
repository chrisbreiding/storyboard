React = require 'react'
moment = require 'moment'
_ = require 'lodash'
Story = require '../story/story'

formatDate = (date)-> moment(date).format 'MMM D'

module.exports = React.createClass

  render: ->
    stories = @props.stories
    filteredStories = _.filter stories, (story, index)=>
      return true unless @storyIsAccepted story

      if @props.showAcceptedType is 'count'
        value = index
        numAcceptedStories = (_.filter stories, (story)=> @storyIsAccepted story).length
        cutoff = numAcceptedStories - @props.showAcceptedValue
        cutoff = if cutoff >= 0 then cutoff else 0
      else
        value = moment().startOf('day').subtract('days', @props.showAcceptedValue).unix()
        cutoff = moment(story.accepted_at).startOf('day').unix()

      value >= cutoff

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

Ember.Handlebars.helper 'story_state', (state)->
  if state
    icon = if state is 'accepted'
      '<i class="fa fa-check"></i>'
    else
      ''

    new Ember.Handlebars.SafeString "<span class='state-meter'>#{icon}</span>"

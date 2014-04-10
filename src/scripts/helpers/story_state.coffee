Ember.Handlebars.helper 'story_state', (state)->
  if state
    icon = if state is 'accepted'
      '<i class="fa fa-check"></i>'
    else
      ''

    el = """
          <span class="state-meter">#{icon}</span>
          <span class="state">#{state}</span>
         """
    new Ember.Handlebars.SafeString el

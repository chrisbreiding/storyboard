Ember.Handlebars.helper 'story_icon', (storyType, estimate)->
  className = switch storyType
    when 'feature' then 'fa-certificate'
    when 'chore' then 'fa-wrench'
    when 'bug' then 'fa-bug'
    when 'release' then 'fa-flag-checkered'
  estimate = if estimate
    "<span class='estimate'>#{estimate}</span>"
  else
    ''
  new Ember.Handlebars.SafeString "<i class='story-type fa #{className}'>#{estimate}</i>"

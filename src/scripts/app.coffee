window.App = Ember.Application.create()

App.VERSION = '0.1.2'
App.NAMESPACE = 'storyboard'

Ember.TextField.reopen
  attributeBindings: ['min']

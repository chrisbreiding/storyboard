$body = Ember.$('body')

App.ApplicationController = Ember.Controller.extend

  needs: 'settings'

  init: ->
    @_super()
    @updateBaseFontSize()

  updateBaseFontSize: (->
    baseFontSize = @get 'controllers.settings.baseFontSize'
    $body.css 'font-size', "#{baseFontSize}px"
  ).observes 'controllers.settings.baseFontSize'

  actions:

    showBanner: (message, type)->
      @set 'banner', message: message, type: type

    hideBanner: ->
      @set 'banner', null

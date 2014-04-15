$body = Ember.$('body')

App.ApplicationController = Ember.Controller.extend

  init: ->
    @_super()
    @updateBaseFontSize App.settings.getValue('baseFontSize', 16)
    App.eventBus.on 'baseFontSizeUpdated', (fontSize)=>
      @updateBaseFontSize fontSize

  updateBaseFontSize: (fontSize)->
    $body.css 'font-size', "#{fontSize}px"

  actions:

    showBanner: (message, type)->
      @set 'banner', message: message, type: type

    hideBanner: ->
      @set 'banner', null

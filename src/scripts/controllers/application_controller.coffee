$body = Ember.$('body')

App.ApplicationController = Ember.Controller.extend

  init: ->
    @_super()

    fontSizeMatch = location.search.match /\?.*fontsize\=(\d+)/i
    if fontSizeMatch and fontSizeMatch[1]
      @updateBaseFontSize fontSizeMatch[1]
      @set 'fontSizeOverridden', true
    else
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

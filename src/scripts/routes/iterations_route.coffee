$body = Ember.$('body')
inProgressStoryTypes = ['started', 'finished', 'delivered', 'rejected']

App.IterationsRoute = App.Route.extend

  model: ->
    $body.addClass 'loading'
    getIterations = App.pivotal.getIterations @modelFor('project').id
    getIterations.then -> $body.removeClass 'loading'
    getIterations

  setupController: (controller, model)->
    controller.set 'model', model

    if model.get 'length'
      @checkInProgressStories model
      @controllerFor('settings').on 'settingsUpdated', =>
        @checkInProgressStories model

    projectModel = @modelFor 'project'
    App.pivotal.listenForProjectUpdates projectModel
    App.pivotal.on 'projectUpdated', =>
      App.pivotal.getIterations(projectModel.id).then (iterations)=>
        controller.set 'model', iterations
        @checkInProgressStories controller.get('model')

  checkInProgressStories: (model)->
    stories = model.get 'firstObject.stories'
    storiesInProgress = _.filter stories, (story)->
      _.contains inProgressStoryTypes, story.current_state
    inProgressMax = App.settings.getValue 'inProgressMax', 5

    appController = @controllerFor 'application'
    if storiesInProgress.length > inProgressMax
      appController.send 'showBanner', "There are over #{inProgressMax} stories in progress", 'warning'
    else
      appController.send 'hideBanner'

  deactivate: ->
    @controllerFor('application').send 'hideBanner'
    @controllerFor('settings').off 'settingsUpdated'
    App.pivotal.off 'projectUpdated'

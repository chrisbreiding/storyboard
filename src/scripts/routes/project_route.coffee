App.ProjectRoute = App.Route.extend

  model: (params)->
    App.pivotal.getProject params.project_id

  redirect: (model)->
    App.settings.updateValue 'projectId', model.id
    Ember.run.later => @transitionTo 'iterations'

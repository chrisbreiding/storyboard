App.ProjectsRoute = App.Route.extend

  model: ->
    App.pivotal.getProjects()

  redirect: ->
    projectId = App.settings.getValue 'projectId'
    if projectId
      @transitionTo 'project', projectId

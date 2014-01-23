App.migrator.registerMigration '0.1.2', ->

  new Ember.RSVP.Promise (resolve, reject)->
    console.log 'running migration for version 0.1.2'

    keysAndDefaults = [
      { key: 'apiToken',          default: 'null' }
      { key: 'baseFontSize',      default: '20' }
      { key: 'inProgressMax',     default: '5' }
      { key: 'projectId',         default: 'null' }
      { key: 'showAcceptedType',  default: '"count"' }
      { key: 'showAcceptedValue', default: '2' }
    ]

    keysAndValues = _.map keysAndDefaults, (keyAndDefault)->
      key: keyAndDefault.key
      value: JSON.parse(localStorage[keyAndDefault.key] || keyAndDefault.default)

    _.each keysAndValues, (keyAndValue)->
      App.settings.updateValue keyAndValue.key, keyAndValue.value
      localStorage.removeItem keyAndValue.key

    localStorage.removeItem 'appVersion'

    resolve()

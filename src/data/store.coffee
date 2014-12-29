NAMESPACE = 'storyboard'

module.exports = class Store

  constructor: (@namespace)->
    @data = JSON.parse(localStorage[@namespace] or '{}')

  fetch: (key)->
    @data[key]

  save: (key, value)->
    if typeof key is 'string'
      @data[key] = value
    else
      for itemKey, value of key
        @data[itemKey] = value
    localStorage[@namespace] = JSON.stringify @data
    value

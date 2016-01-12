module.exports =

  config:
    folder:
      type: 'array'
      default: []
      items:
        type: 'string'
    scope:
      type: 'string'
      default: '.source.gfm'

  provider: null
  ready: false

  activate: ->
    @ready = true

  deactivate: ->
    @provider = null

  getProvider: ->
    return @provider if @provider?
    PathsProvider = require('./paths-provider')
    @provider = new PathsProvider()
    return @provider

  provide: ->
    return {provider: @getProvider()}

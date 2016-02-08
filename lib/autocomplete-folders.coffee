module.exports =

  config:
    folders:
      type: 'array'
      default: []
      items:
        type: 'string'
    scope:
      type: 'string'
      default: '.source.gfm, .source.pfm, .source.md'

  provider: null
  ready: false

  activate: ->
    @ready = true

  deactivate: ->
    @provider = null

  getProvider: ->
    return @provider if @provider?
    FoldersProvider = require('./folders-provider')
    @provider = new FoldersProvider()
    return @provider

  provide: ->
    return {provider: @getProvider()}

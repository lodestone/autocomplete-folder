{Range}  = require('atom')
fuzzaldrin = require('fuzzaldrin')
path = require('path')
fs = require('fs')

module.exports =
class FoldersProvider
  id: 'autocomplete-folders-foldersprovider'
  selector: '*'
  # wordRegex: /[{}a-zA-Z0-9\.\/_-]*\/[a-zA-Z0-9\.\/_-]*/g
  wordRegex: /\w+/g
  cache: []

  requestHandler: (options = {}) =>
    return [] unless options.editor? and options.buffer? and options.cursor?
    basePath = atom.config.get("autocomplete-folders.folders")

    return [] unless basePath?

    prefix = @prefixForCursor(options.editor, options.buffer, options.cursor, options.position)
    return [] unless prefix.length

    suggestions = @findSuggestionsForPrefix(options.editor, basePath, prefix)
    return [] unless suggestions.length
    return suggestions

  prefixForCursor: (editor, buffer, cursor, position) =>
    return '' unless buffer? and cursor?
    start = @getBeginningOfCurrentWordBufferPosition(editor, position, {wordRegex: @wordRegex})
    end = cursor.getBufferPosition()
    return '' unless start? and end?
    buffer.getTextInRange(new Range(start, end))

  getBeginningOfCurrentWordBufferPosition: (editor, position, options = {}) ->
    return unless position?
    allowPrevious = options.allowPrevious ? true
    currentBufferPosition = position
    scanRange = [[currentBufferPosition.row, 0], currentBufferPosition]
    beginningOfWordPosition = null
    editor.backwardsScanInBufferRange (options.wordRegex), scanRange, ({range, stop}) ->
      if range.end.isGreaterThanOrEqual(currentBufferPosition) or allowPrevious
        beginningOfWordPosition = range.start
      if not beginningOfWordPosition?.isEqual(currentBufferPosition)
        stop()

    if beginningOfWordPosition?
      beginningOfWordPosition
    else if allowPrevious
      [currentBufferPosition.row, 0]
    else
      currentBufferPosition

  findSuggestionsForPrefix: (editor, basePaths, prefix) ->

    console.log basePaths

    return [] unless basePaths?

    suggestions = []

    for basePath in basePaths
      prefixPath = path.resolve(basePath, prefix)

      directory = basePath

      console.log directory

      # if prefix.endsWith('/')
      #   directory = prefixPath
      #   prefix = ''
      # else
      #   if basePath is prefixPath
      #     directory = prefixPath
      #   else
      #     directory = path.dirname(prefixPath)
      #   prefix = path.basename(prefix)

      # Is this actually a directory?
      try
        stat = fs.statSync(directory)
        continue unless stat.isDirectory()
      catch e
        continue
        # return []

      # Get files
      # try
      files = fs.readdirSync(directory)
      # catch e
      # return []
      results = fuzzaldrin.filter(files, prefix)


      for result in results

        # console.log result

        resultPath = path.resolve(directory, result)

        # Check for type
        # try
        #   stat = fs.statSync(resultPath)
        # catch e
        #   continue
        # if stat.isDirectory()
        #   label = 'Dir'
        #   result += path.sep
        # else if stat.isFile()
        #   label = 'File'
        # else
        #   continue

        dirFound = resultPath.split("/")
        dirFound.pop()
        dirFound = dirFound.join("/")
        label = "in " + path.basename(dirFound)

        suggestion =
          word: result
          prefix: prefix
          label: label
          data:
            body: result
        # if suggestion.label isnt 'File'
        #   suggestion.onDidConfirm = ->
        #     atom.commands.dispatch(atom.views.getView(editor), 'autocomplete-plus:activate')

        # console.log suggestion

        suggestions.push suggestion

    console.log suggestions

    return suggestions

  dispose: =>
    @editor = null
    @basePath = null

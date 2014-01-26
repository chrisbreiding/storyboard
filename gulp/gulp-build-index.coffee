handlebars = require 'handlebars'
through = require 'through2'
_ = require 'underscore'
glob = require 'glob'
gutil = require 'gulp-util'

PLUGIN_NAME = 'gulp-build-index'

module.exports = (scriptGlobs)->
  scriptFiles = _.flatten _.map scriptGlobs, (jsFileGlob)->
    glob.sync "src/scripts/#{jsFileGlob}.+(js|coffee|hbs)"

  jsFiles = _.map scriptFiles, (scriptFile)->
    gutil.replaceExtension(scriptFile, '.js').replace('src/scripts', 'scripts')

  scripts = (_.map jsFiles, (jsFile)-> "<script src=\"#{jsFile}\"></script>").join('\n')

  through.obj (file, enc, callback)->
    if file.isStream()
      @emit 'error', new gutil.PluginError(PLUGIN_NAME,  'Streaming not supported')
      return callback()

    try
      template = handlebars.compile file.contents.toString()
      compiled = template scripts: new handlebars.SafeString(scripts)
    catch err
      @emit 'error', new gutil.PluginError(PLUGIN_NAME, err)
      return callback()

    file.path = gutil.replaceExtension file.path, '.html'
    file.contents = new Buffer compiled

    @push file
    callback()


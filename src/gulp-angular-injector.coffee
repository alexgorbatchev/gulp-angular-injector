es = require 'event-stream'
angularInjector = require 'angular-injector'

module.exports = (opts) ->
  es.map (file, cb) ->
    return cb null, file unless /\.js$/.test file.path

    try
      file.contents = new Buffer angularInjector.annotate file.contents.toString(), opts
      cb null, file
    catch err
      cb err

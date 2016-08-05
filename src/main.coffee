# out: ../lib/main.js

fs = require "fs"
path = require "path"

module.exports = (samjs) ->
  debug = samjs.debug("files-auth")
  throw new Error "samjs-files not found - must be loaded before samjs-files-auth" unless samjs.files
  throw new Error "samjs-auth not found - must be loaded before samjs-files-auth" unless samjs.auth
  samjs.files.plugins auth: (options) ->
    @addHook "beforeGet", ({file, client}) =>
      read = file.read
      read ?= @read
      samjs.auth.isAllowed(client,read,@permissionCheckers)
      return file: file, client:client
    @addHook "beforeSet", ({data,file, client}) =>
      write = file.write
      write ?= @write
      samjs.auth.isAllowed(client,write,@permissionCheckers)
      return data: data, file:file, client:client
    return @

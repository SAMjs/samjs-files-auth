# out: ../lib/main.js

fs = require "fs"
path = require "path"

module.exports = (samjs) ->
  debug = samjs.debug("files-auth")
  throw new Error "samjs-files not found - must be loaded before samjs-files-auth" unless samjs.files
  throw new Error "samjs-auth not found - must be loaded before samjs-files-auth" unless samjs.auth
  samjs.files.plugins auth: (options) ->
    @addHook "beforeGet", ({file, client}) ->
      samjs.auth.isAllowed(client,file.read,@permissionCheckers)
      return file: file, client:client
    @addHook "beforeSet", ({data,file, client}) ->
      if file.isNew
        permission = file.insert
      else
        permission = file.update
      samjs.auth.isAllowed(client,permission,@permissionCheckers)
      return data: data, file:file, client:client
    @addHook "beforeDelete", ({file, client}) ->
      samjs.auth.isAllowed(client,file.delete,@permissionCheckers)
      return file: file, client:client

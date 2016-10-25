# out: ../lib/main.js

fs = require "fs"
path = require "path"

module.exports = (samjs) ->
  debug = samjs.debug("files-auth")
  throw new Error "samjs-files not found - must be loaded before samjs-files-auth" unless samjs.files
  throw new Error "samjs-auth not found - must be loaded before samjs-files-auth" unless samjs.auth
  samjs.files.plugins auth: (options) ->
    @addHook "beforeGet", (obj) ->
      samjs.auth.isAllowed(obj.socket,obj.file.read,@permissionCheckers)
      return obj
    @addHook "beforeSet", (obj) ->
      if obj.file.isNew
        permission = obj.file.insert
      else
        permission = obj.file.update
      samjs.auth.isAllowed(obj.socket,permission,@permissionCheckers)
      return obj
    @addHook "beforeDelete", (obj) ->
      samjs.auth.isAllowed(obj.socket,obj.file.delete,@permissionCheckers)
      return obj

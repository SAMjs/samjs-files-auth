(function() {
  var fs, path;

  fs = require("fs");

  path = require("path");

  module.exports = function(samjs) {
    var debug;
    debug = samjs.debug("files-auth");
    if (!samjs.files) {
      throw new Error("samjs-files not found - must be loaded before samjs-files-auth");
    }
    if (!samjs.auth) {
      throw new Error("samjs-auth not found - must be loaded before samjs-files-auth");
    }
    return samjs.files.plugins({
      auth: function(options) {
        this.addHook("beforeGet", function(obj) {
          samjs.auth.isAllowed(obj.socket, obj.file.read, this.permissionCheckers);
          return obj;
        });
        this.addHook("beforeSet", function(obj) {
          var permission;
          if (obj.file.isNew) {
            permission = obj.file.insert;
          } else {
            permission = obj.file.update;
          }
          samjs.auth.isAllowed(obj.socket, permission, this.permissionCheckers);
          return obj;
        });
        return this.addHook("beforeDelete", function(obj) {
          samjs.auth.isAllowed(obj.socket, obj.file["delete"], this.permissionCheckers);
          return obj;
        });
      }
    });
  };

}).call(this);

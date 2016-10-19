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
        this.addHook("beforeGet", function(arg) {
          var client, file;
          file = arg.file, client = arg.client;
          samjs.auth.isAllowed(client, file.read, this.permissionCheckers);
          return {
            file: file,
            client: client
          };
        });
        this.addHook("beforeSet", function(arg) {
          var client, data, file, permission;
          data = arg.data, file = arg.file, client = arg.client;
          if (file.isNew) {
            permission = file.insert;
          } else {
            permission = file.update;
          }
          samjs.auth.isAllowed(client, permission, this.permissionCheckers);
          return {
            data: data,
            file: file,
            client: client
          };
        });
        return this.addHook("beforeDelete", function(arg) {
          var client, file;
          file = arg.file, client = arg.client;
          samjs.auth.isAllowed(client, file["delete"], this.permissionCheckers);
          return {
            file: file,
            client: client
          };
        });
      }
    });
  };

}).call(this);

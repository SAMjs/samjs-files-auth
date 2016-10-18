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
        this.addHook("beforeGet", (function(_this) {
          return function(arg) {
            var client, file, read;
            file = arg.file, client = arg.client;
            read = file.read;
            if (read == null) {
              read = _this.read;
            }
            samjs.auth.isAllowed(client, read, _this.permissionCheckers);
            return {
              file: file,
              client: client
            };
          };
        })(this));
        this.addHook("beforeSet", (function(_this) {
          return function(arg) {
            var client, data, file, write;
            data = arg.data, file = arg.file, client = arg.client;
            write = file.write;
            if (write == null) {
              write = _this.write;
            }
            samjs.auth.isAllowed(client, write, _this.permissionCheckers);
            return {
              data: data,
              file: file,
              client: client
            };
          };
        })(this));
        return this;
      }
    });
  };

}).call(this);

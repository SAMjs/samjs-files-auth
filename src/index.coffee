# out: ../lib/main.js

processAccess = (cb, {socket, data}) =>
  return if cb == true
  throw new Error "not logged in" if socket? and not (user = socket.client.auth?.user)?
  cb(user, data) if user?

getCallback = (access, name, allow) =>
  return cb if (cb = access?[name])?
  return => throw new Error "forbidden" unless allow
  return false

hierarchy = [
        connect: 
          cmds: ["listen"]
          children:[
            { write: children: ["update", "insert", "delete"] }
            { read: children: ["list"] }
            ]
        ]

module.exports = (samjs) =>
  samjs.after.models.call
    prio: samjs.prio.POST_PROCESS
    hook: (models) =>
      for name, model of models
        if model.db == "files" and not ~model.plugins.indexOf("noAuth")
          samjs.auth.parseAccess model, hierarchy
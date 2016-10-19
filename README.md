# samjs-files-auth

Adds authorization for [samjs-files](https://github.com/SAMjs/samjs-files).

## Getting Started
```sh
npm install --save samjs-files-auth
```

## Usage

```js
// server-side
samjs
.plugins([
  require("samjs-auth"),
  require("samjs-files"),
  require("samjs-files-auth")
])
.options()
.configs()
.models({
  name: "someFile",
  db: "files",
  files: "package.json",
  plugins: {
    // (optional) to manually activate auth.
    // auth will be activated by default for all models
    auth: {}
    // to disable auth plugin use this instead:
    noAuth: {}
  },
  access:{
    read: true, // allowed for all
    write: "root" // allowed for root only
  }
  // optional, permission checker used for this model
  // can be a name or a custom function
  // see samjs-auth for further information
  permissionChecker: "containsUser"
  }
})
.startup(server)
```

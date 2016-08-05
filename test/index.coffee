chai = require "chai"
should = chai.should()
samjs = require "samjs"
samjsClient = require "samjs-client"
samjsFiles = require "samjs-files"
samjsFilesClient = require "samjs-files-client"
samjsFilesAuth = require "../src/main"
samjsAuth = require "samjs-auth"
samjsAuthClient = require "samjs-auth-client"
fs = samjs.Promise.promisifyAll(require("fs"))
path = require "path"
port = 3060
url = "http://localhost:"+port+"/"
testConfigFile = "test/testConfig.json"

testModel =
  name: "test"
  db: "files"
  files: testConfigFile
  write: "root"
  read: "root"
  plugins:
    auth: null
unlink = (file) ->
  fs.unlinkAsync file
  .catch -> return true
reset = (done) ->
  samjs.reset()
  unlink testConfigFile
  .finally ->
    done()
shutdown = (done) ->

  promises = [unlink(testConfigFile)]
  promises.push samjs.shutdown() if samjs.shutdown?
  samjs.Promise.all promises
  .then -> done()

describe "samjs", ->
  client = null
  clientTest = null
  describe "files-auth", ->
    before reset
    after shutdown
    it "should be accessible", ->
      samjs.plugins(samjsAuth,samjsFiles,samjsFilesAuth)
      should.exist samjs.files
      should.exist samjs.auth
    it "should install", (done) ->
      samjs.options({config:testConfigFile})
      .configs()
      .models(testModel)
      .startup().io.listen(port)
      client = samjsClient({
        url: url
        ioOpts:
          reconnection: false
          autoConnect: false
        })()
      client.plugins(samjsAuthClient,samjsFilesClient)
      client.auth.createRoot "rootroot"
      .then -> done()
      .catch done
    it "should startup", (done) ->
      samjs.state.onceStarted.then -> done()
      .catch done
    describe "client", ->
      clientTest = null
      it "should be unaccessible", (done) ->
        clientTest = new client.Files("test")
        samjs.Promise.any [clientTest.get(),clientTest.set("something")]
        .then (result) ->
          console.log result
        .catch (result) ->
          result.should.be.an.instanceOf Error
          done()
      it "should auth", (done) ->
        client.auth.login {name:"root",pwd:"rootroot"}
        .then (result) ->
          result.name.should.equal "root"
          done()
        .catch done
      it "should be able to set and get", (done) ->
        clientTest.set("something")
        .then ->
          clientTest.get()
        .then (result) ->
          result.should.equal "something"
          done()
        .catch done

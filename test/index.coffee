chai = require "chai"
should = chai.should()
chai.use require "chai-as-promised"
requireAny = require "try-require-multiple"
Samjs = requireAny "samjs/src", "samjs"
SamjsClient = requireAny "samjs/client-src", "samjs/client"
samjsFiles = requireAny "samjs-files/src", "samjs-files"
samjsFilesClient = requireAny "samjs-files/client-src", "samjs-files/client"
samjsFilesAuth = require "../src"
samjsAuth = requireAny "samjs-auth/src", "samjs-auth"
samjsAuthClient = requireAny "samjs-auth/client-src", "samjs-auth/client"

port = 3060
url = "http://localhost:"+port+"/"
testConfigFile = "test/testConfig.json"

testModel =
  name: "test"
  db: "files"
  files: "test/testFile"
  options: "utf8"
  access:
    connect: true
    write: =>
    read: =>


describe "samjs", =>
  describe "files-auth", =>
    samjs = samjsClient = null
    before =>
      samjs = new Samjs
        plugins: [samjsAuth, samjsFiles, samjsFilesAuth]
        options: config: testConfigFile
        models: testModel
      await samjs.finished.then (io) => io.listen(port)
      await samjs.configs.users.set(data:[{name:"root",pwd:"rootroot"}])
    after => 
      samjs.shutdown()
      samjsClient?.close()
    it "should connect", =>
      samjsClient = new SamjsClient
        plugins: [samjsAuthClient, samjsFilesClient]
        url: url
        io: reconnection:false
      await samjsClient.finished
    describe "client", =>
      model = null
      it "should be unaccessible",  =>
        model = await samjsClient.model("test").ready
        model.read().should.be.rejected
        model.write(data: "someData").should.be.rejected
      it "should auth", =>
        samjsClient.auth.login {name:"root",pwd:"rootroot"}
      it "should be able to set", =>
        model.write(data: "something")

      it "should be able to get", =>
        model.read().should.eventually.equal "something"

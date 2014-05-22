config = require 'config'
express = require 'express'
http = require 'http'

app = express()
server = http.createServer app

app.use require('morgan')()
app.use require('body-parser')()
app.use express.static __dirname + '/../dist/'

if config.basicAuth
  app.use require('basic-auth-connect') config.basicAuth.username, config.basicAuth.password

require('./routes')(app)

require('./runner').start()

server.listen 7293, ->
  console.log "[#{Date.now()}] [server] Started"

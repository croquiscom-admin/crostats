express = require 'express'
http = require 'http'

app = express()
server = http.createServer app

app.use express.logger()

app.use express.bodyParser()

app.use express.static __dirname + '/../dist/'

require('./routes')(app)

require('./runner').start()

server.listen 7293, ->
  console.log "[#{Date.now()}] [server] Started"

express = require 'express'
app = express()

app.use express.bodyParser()

if require.main is module
  app.use express.static __dirname + '/../dist/'

require('./routes')(app)

if require.main is module
  app.listen 7293
else
  module.exports = app

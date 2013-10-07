express = require 'express'
app = express()

app.use express.bodyParser()

require('./routes')(app)

module.exports = app

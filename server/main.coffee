express = require('express')
routes = require('./routes')
app = express()

app.use(express.bodyParser())

app.get('/api/awesomeThings', routes.awesomeThings)

app.use (req, res) ->
    res.json({'ok': false, 'status': '404'})

module.exports = app

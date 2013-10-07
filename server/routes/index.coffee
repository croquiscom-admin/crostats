mongodb = require 'mongodb'
server = new mongodb.Server 'localhost', 27017, {}
db = new mongodb.Db 'statistics', server, safe: true
db.open ->

scripts = new mongodb.Collection db, 'scripts'
results = new mongodb.Collection db, 'results'

module.exports = (app) ->
  app.get '/api/scripts', (req, res) ->
    scripts.find {}, (error, cursor) ->
      return res.send 400, error if error
      cursor.toArray (error, result) ->
        return res.send 400, error if error
        res.json result

  app.get '/api/scripts/:id/results', (req, res) ->
    results.find script: req.params.id, (error, cursor) ->
      return res.send 400, error if error
      cursor.toArray (error, result) ->
        return res.send 400, error if error
        res.json result

  app.use (req, res) ->
    res.json 404, ok: false

models = require '../models'
runner = require '../runner'

module.exports = (app) ->
  app.get '/api/scripts', (req, res) ->
    models.scripts.find({}, {_id:1}).toArray (error, result) ->
      return res.send 400, error if error
      res.json result

  app.get '/api/scripts/:id', (req, res) ->
    models.scripts.findOne _id: req.params.id, (error, result) ->
      return res.send 400, error if error
      res.json result

  app.get '/api/scripts/:id/results', (req, res) ->
    models.results.find(script: req.params.id).toArray (error, result) ->
      return res.send 400, error if error
      res.json result

  app.post '/api/scripts/:id/run', (req, res) ->
    runner.run req.params.id, (error, results) ->
      return res.send 400, error if error
      res.json [date: new Date(), result: results]

  app.use (req, res) ->
    res.json 404, ok: false

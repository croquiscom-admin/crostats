models = require '../models'
runner = require '../runner'

module.exports = (app) ->
  app.get '/api/servers', (req, res) ->
    models.servers.find({}, {_id:1}).toArray (error, result) ->
      return res.send 400, error if error
      res.json result

  app.get '/api/programs', (req, res) ->
    models.programs.find({}, {_id:1, title: 1}).toArray (error, result) ->
      return res.send 400, error if error
      res.json result

  app.get '/api/programs/:id', (req, res) ->
    models.programs.findOne _id: req.params.id, (error, result) ->
      return res.send 400, error if error
      res.json result

  app.get '/api/programs/:id/results', (req, res) ->
    models.results.find(program: req.params.id).toArray (error, result) ->
      return res.send 400, error if error
      res.json result

  app.post '/api/programs/:id/run', (req, res) ->
    runner.run req.params.id, (error, results) ->
      return res.send 400, error if error
      res.json [date: new Date(), result: results]

  app.post '/api/runProgram', (req, res) ->
    runner.runProgram req.body, (error, results) ->
      return res.send 400, error if error
      res.json [date: new Date(), result: results]

  app.use (req, res) ->
    res.json 404, ok: false

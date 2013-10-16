models = require '../models'
runner = require '../runner'

module.exports = (app) ->
  app.get '/api/servers', (req, res) ->
    models.servers.find({}, {_id:1}).toArray (error, result) ->
      return res.send 400, error if error
      res.json result

  app.get '/api/programs', (req, res) ->
    models.programs.find({}, {_id:1, title: 1, description: 1}).toArray (error, result) ->
      return res.send 400, error if error
      res.json result

  app.post '/api/programs', (req, res) ->
    id = req.body.id or req.body._id
    title = req.body.title or id
    description = req.body.description or id
    models.programs.insert _id: id, title: title, description: description, type: 'mapreduce', (error) ->
      return res.send 400, error if error
      res.json {}

  app.get '/api/programs/:id', (req, res) ->
    models.programs.findOne _id: req.params.id, (error, result) ->
      return res.send 400, error if error
      res.json result

  app.put '/api/programs/:id', (req, res) ->
    delete req.body._id
    models.programs.update { _id: req.params.id }, { $set: req.body }, safe: true, (error) ->
      return res.send 400, error if error
      res.json {}

  app.del '/api/programs/:id', (req, res) ->
    models.results.remove {program: req.params.id}, safe: true, (error) ->
      return res.send 400, error if error
      models.programs.remove {_id: req.params.id}, safe: true, (error) ->
        return res.send 400, error if error
        res.json {}

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

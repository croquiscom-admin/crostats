models = require '../models'
runner = require '../runner'

_removeIdUnderscore = (item) ->
  if Array.isArray item
    item.forEach _removeIdUnderscore
  else
    item.id = item._id
    delete item._id
  return

module.exports = (app) ->
  app.use (req, res, next) ->
    origin = req.get 'Origin'
    if origin is 'http://localhost:9000' or origin is 'http://127.0.0.1:9000'
      res.set 'Access-Control-Allow-Origin', origin
      res.set 'Access-Control-Allow-Credentials', true
      res.set 'Access-Control-Allow-Headers', 'X-Requested-With, Content-Type'
      res.set 'Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE'
      if req.method is 'OPTIONS'
        return res.json {}
    next()

  app.get '/api/servers', (req, res) ->
    models.Server.getList()
    .then (result) ->
      res.json result
    .catch (error) ->
      res.send 400, error

  app.get '/api/programs', (req, res) ->
    models.Program.getList()
    .then (result) ->
      res.json result
    .catch (error) ->
      res.send 400, error

  app.post '/api/programs', (req, res) ->
    models.Program.add req.body.id, req.body.title, req.body.description
    .then ->
      res.json {}
    .catch (error) ->
      res.send 400, error

  app.get '/api/programs/:id', (req, res) ->
    models.Program.get req.params.id
    .then (result) ->
      res.json result
    .catch (error) ->
      res.send 400, error

  app.put '/api/programs/:id', (req, res) ->
    delete req.body.id

    # reset last_run not to run this program when type is changed from none to daily
    req.body.runner ||= {}
    req.body.runner.last_run = new Date()

    models.Program.update req.params.id, req.body
    .then ->
      res.json {}
    .catch (error) ->
      res.send 400, error

  app.delete '/api/programs/:id', (req, res) ->
    models.Program.delete req.params.id
    .then ->
      res.json {}
    .catch (error) ->
      res.send 400, error

  app.get '/api/programs/:id/results', (req, res) ->
    models.Result.getList req.params.id, req.query
    .then (result) ->
      res.json result
    .catch (error) ->
      res.send 400, error

  app.post '/api/programs/:id/results', (req, res) ->
    models.Result.add req.params.id, req.body.date, req.body.result
    .then ->
      res.json {}
    .catch (error) ->
      res.send 400, error

  app.post '/api/programs/:id/run', (req, res) ->
    runner.run req.params.id
    .then (results) ->
      res.json [date: new Date(), result: results]
    .catch (error) ->
      res.send 400, error

  app.post '/api/runProgram', (req, res) ->
    runner.runProgram req.body
    .then (results) ->
      res.json [date: new Date(), result: results]
    .catch (error) ->
      res.send 400, error

  app.get '/api/oneoffs', (req, res) ->
    models.OneOff.getList()
    .then (result) ->
      res.json result
    .catch (error) ->
      res.send 400, error

  app.post '/api/oneoffs', (req, res) ->
    models.OneOff.add req.body
    .then ->
      res.json {}
    .catch (error) ->
      res.send 400, error

  app.get '/api/oneoffs/:id', (req, res) ->
    models.OneOff.get req.params.id
    .then (result) ->
      res.json result
    .catch (error) ->
      res.send 400, error

  app.use (req, res) ->
    res.json 404, ok: false

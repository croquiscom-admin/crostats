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
    models.servers.find({}, {_id:1}).toArray (error, result) ->
      return res.send 400, error if error
      _removeIdUnderscore result
      res.json result

  app.get '/api/programs', (req, res) ->
    models.programs.find({}, {_id:1, title: 1, description: 1}).toArray (error, result) ->
      return res.send 400, error if error
      _removeIdUnderscore result
      res.json result

  app.post '/api/programs', (req, res) ->
    id = req.body.id
    title = req.body.title or id
    description = req.body.description or id
    models.programs.insert _id: id, title: title, description: description, type: 'mapreduce', (error) ->
      return res.send 400, error if error
      res.json {}

  app.get '/api/programs/:id', (req, res) ->
    models.programs.findOne _id: req.params.id, (error, result) ->
      return res.send 400, error if error
      _removeIdUnderscore result
      res.json result

  app.put '/api/programs/:id', (req, res) ->
    delete req.body.id

    # reset last_run not to run this program when type is changed from none to daily
    req.body.runner ||= {}
    req.body.runner.last_run = new Date()

    models.programs.update { _id: req.params.id }, { $set: req.body }, safe: true, (error) ->
      return res.send 400, error if error
      res.json {}

  app.delete '/api/programs/:id', (req, res) ->
    models.results.remove {program: req.params.id}, safe: true, (error) ->
      return res.send 400, error if error
      models.programs.remove {_id: req.params.id}, safe: true, (error) ->
        return res.send 400, error if error
        res.json {}

  app.get '/api/programs/:id/results', (req, res) ->
    criteria = [ { program: req.params.id } ]
    if req.query.from
      criteria.push date: $gte: new Date(Number req.query.from)
    if req.query.to
      criteria.push date: $lt: new Date(Number req.query.to)
    limit = Number(req.query.limit or 0)
    models.results.find($and: criteria).sort(date:-1).limit(limit).toArray (error, result) ->
      return res.send 400, error if error
      _removeIdUnderscore result
      result.reverse()
      res.json result

  app.post '/api/programs/:id/results', (req, res) ->
    data =
      program: req.params.id
      result: req.body.result
      date: new Date(req.body.date)
    models.results.insert data, safe: true, (error, result) ->
      return res.send 400, error if error
      res.json {}

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
    models.oneoffs.find({}, {_id:1, description: 1}).sort(_id:-1).toArray (error, result) ->
      return res.send 400, error if error
      for item in result
        item.date = item._id.getTimestamp()
      _removeIdUnderscore result
      res.json result

  app.post '/api/oneoffs', (req, res) ->
    models.oneoffs.insert req.body, (error) ->
      return res.send 400, error if error
      res.json {}

  app.get '/api/oneoffs/:id', (req, res) ->
    models.oneoffs.findOne _id: models.ObjectID(req.params.id), (error, result) ->
      return res.send 400, error if error
      _removeIdUnderscore result
      res.json result

  app.use (req, res) ->
    res.json 404, ok: false

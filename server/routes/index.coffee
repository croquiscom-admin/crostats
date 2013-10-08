mongodb = require 'mongodb'
server = new mongodb.Server 'localhost', 27017, {}
db = new mongodb.Db 'statistics', server, safe: true
db.open ->

servers = new mongodb.Collection db, 'servers'
scripts = new mongodb.Collection db, 'scripts'
results = new mongodb.Collection db, 'results'

module.exports = (app) ->
  app.get '/api/scripts', (req, res) ->
    scripts.find({}).toArray (error, result) ->
      return res.send 400, error if error
      res.json result

  app.get '/api/scripts/:id/results', (req, res) ->
    results.find(script: req.params.id).toArray (error, result) ->
      return res.send 400, error if error
      res.json result

  app.post '/api/scripts/:id/run', (req, res) ->
    scripts.findOne _id: req.params.id, (error, script) ->
      return res.send 400, error if error
      servers.findOne _id: script.server, (error, server) ->
        return res.send 400, error if error
        url = server.url
        url = "#{server.user}:#{server.password}@#{url}" if server.user and server.password
        mongodb.MongoClient.connect "mongodb://#{url}", (error, t_db) ->
          return res.send 400, error if error
          t_db.collection(script.collection).mapReduce script.map, script.reduce, out: inline: 1, (error, results) ->
            return res.send 400, error if error
            res.json [date: new Date(), result: results]

  app.use (req, res) ->
    res.json 404, ok: false

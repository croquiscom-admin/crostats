mongodb = require 'mongodb'
server = new mongodb.Server 'localhost', 27017, {}
db = new mongodb.Db 'statistics', server, safe: true
db.open ->

servers = new mongodb.Collection db, 'servers'
scripts = new mongodb.Collection db, 'scripts'
results = new mongodb.Collection db, 'results'

module.exports =
  mongodb: mongodb
  servers: servers
  scripts: scripts
  results: results

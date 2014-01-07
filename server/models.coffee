mongodb = require 'mongodb'
server = new mongodb.Server 'localhost', 27017, {}
db = new mongodb.Db 'statistics', server, safe: true
db.open ->

servers = new mongodb.Collection db, 'servers'
programs = new mongodb.Collection db, 'programs'
results = new mongodb.Collection db, 'results'
oneoffs = new mongodb.Collection db, 'oneoffs'

module.exports =
  mongodb: mongodb
  servers: servers
  programs: programs
  results: results
  oneoffs: oneoffs
  ObjectID: mongodb.ObjectID

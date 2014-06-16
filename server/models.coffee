Promise = require 'bluebird'
mongodb = require 'mongodb'
server = new mongodb.Server 'localhost', 27017, {}
db = new mongodb.Db 'crostats', server, safe: true
db.open ->

servers = new mongodb.Collection db, 'servers'
programs = new mongodb.Collection db, 'programs'
results = new mongodb.Collection db, 'results'
oneoffs = new mongodb.Collection db, 'oneoffs'

_removeIdUnderscore = (item) ->
  if Array.isArray item
    item.forEach _removeIdUnderscore
  else
    item.id = item._id
    delete item._id
  return

class Server
  @getList: ->
    new Promise (resolve, reject) ->
      servers.find({}, {_id:1}).toArray (error, result) ->
        return reject error if error
        _removeIdUnderscore result
        resolve result

  @get: (id) ->
    new Promise (resolve, reject) ->
      servers.findOne _id: id, (error, server) =>
        return reject error if error
        return reject 'no server' if not server
        resolve server

class Program
  @getList: ->
    new Promise (resolve, reject) ->
      programs.find({}, {_id:1, title: 1, description: 1}).toArray (error, result) ->
        return reject error if error
        _removeIdUnderscore result
        resolve result

  @add: (id, title, description) ->
    title = id if not title
    description = id if not description
    new Promise (resolve, reject) ->
      programs.insert _id: id, title: title, description: description, type: 'mapreduce', (error) ->
        return reject error if error
        resolve()

  @get: (id) ->
    new Promise (resolve, reject) ->
      programs.findOne _id: id, (error, result) ->
        return reject error if error
        _removeIdUnderscore result
        resolve result

  @update: (id, data) ->
    new Promise (resolve, reject) ->
      programs.update { _id: id }, { $set: data }, safe: true, (error) ->
        return reject error if error
        resolve()

  @delete: (id) ->
    new Promise (resolve, reject) ->
      results.remove {program: id}, safe: true, (error) ->
        return reject error if error
        programs.remove {_id: id}, safe: true, (error) ->
          return reject error if error
          resolve()

  @findNeedRun: ->
    where = ->
      runner = @runner
      if runner
        if runner.type is 'daily'
          last_run = runner.last_run
          return true if not last_run
          today = new Date()
          today.setHours(0)
          today.setMinutes(0)
          today.setSeconds(0)
          today.setMilliseconds(0)
          return true if last_run.getTime() < today.getTime()
      return false
    new Promise (resolve, reject) ->
      programs.find($where: where.toString(), {_id: 1}).toArray (error, programs) =>
        return reject error if error
        resolve programs

class Result
  @getList: (program_id, options) ->
    criteria = [ { program: program_id } ]
    if options.from
      criteria.push date: $gte: new Date(Number options.from)
    if options.to
      criteria.push date: $lt: new Date(Number options.to)
    limit = Number(options.limit or 0)
    new Promise (resolve, reject) ->
      results.find($and: criteria).sort(date:-1).limit(limit).toArray (error, result) ->
        return reject error if error
        _removeIdUnderscore result
        result.reverse()
        resolve result

  @add: (program_id, date, result) ->
    data =
      program: program_id
      date: new Date(date)
      result: result
    new Promise (resolve, reject) ->
      results.insert data, safe: true, (error, result) ->
        return reject error if error
        resolve()

class Oneoff
  @getList: ->
    new Promise (resolve, reject) ->
      oneoffs.find({}, {_id:1, description: 1}).sort(_id:-1).toArray (error, result) ->
        return reject error if error
        for item in result
          item.date = item._id.getTimestamp()
        _removeIdUnderscore result
        resolve result

  @add: (data) ->
    new Promise (resolve, reject) ->
      oneoffs.insert data, (error) ->
        return reject error if error
        resolve()

  @get: (id) ->
    new Promise (resolve, reject) ->
      oneoffs.findOne _id: mongodb.ObjectID(id), (error, result) ->
        return reject error if error
        _removeIdUnderscore result
        resolve result

module.exports =
  mongodb: mongodb
  Server: Server
  Program: Program
  Result: Result
  Oneoff: Oneoff

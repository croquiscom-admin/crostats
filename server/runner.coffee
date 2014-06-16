coffee = require 'coffee-script'
{exec} = require 'child_process'
fs = require 'fs'
Promise = require 'bluebird'
temp = require 'temp'
temp.track()

models = require './models'

_removeIdUnderscore = (item) ->
  if Array.isArray item
    item.forEach _removeIdUnderscore
  else
    item.id = item._id
    delete item._id
  return

class Runner
  start: ->
    setInterval =>
      @find()
      .then (programs) =>
        promises = programs.map (program) => @runAndUpdate program._id
        Promise.all promises
      , (error) ->
        console.log 'Error while Runner.find : ' + error if error
    , 10 * 1000
    @

  find: ->
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
      models.programs.find($where: where.toString(), {_id: 1}).toArray (error, programs) =>
        return reject error if error
        resolve programs

  runAndUpdate: (program_id) ->
    date = new Date()
    console.log "Run program '#{program_id}' at #{date.toString()}..."
    new Promise (resolve, reject) ->
      models.programs.update {_id: program_id}, {$set: 'runner.last_run': date}, safe: true, (error, count) =>
        return reject error if error
        resolve()
    .then =>
      @run program_id
    .then (results) ->
      new Promise (resolve, reject) ->
        models.results.insert { program: program_id, result: results, date: date }, safe: true, (error, result) ->
          return reject error if error
          resolve()
    .then ->
      console.log "Run program '#{program_id}' Done"
    .catch (error) ->
      console.log "Run program '#{program_id}' Failed: #{error.toString()}"

  run: (program_id) ->
    new Promise (resolve, reject) ->
      models.programs.findOne _id: program_id, (error, program) ->
        return reject error if error
        resolve program
    .then (program) =>
      @runProgram program

  runProgram: (program) ->
    new Promise (resolve, reject) ->
      models.servers.findOne _id: program.server, (error, server) =>
        return reject error if error
        return reject 'no server' if not server
        resolve server
    .then (server) =>
      switch program.type
        when 'shellscript'
          @runScript server, program
        when 'mapreduce'
          @runMapReduce server, program
        else
          Promise.reject 'No program'

  runScript: (server, program) ->
    new Promise (resolve, reject) ->
      temp.open 'mongoscript', (error, info) ->
        return reject error if error
        resolve info
    .then (info) ->
      script = program.script
      if program.using_coffeescript
        script = coffee.compile script, filename: 'crostats', bare: true

      new Promise (resolve, reject) ->
        fs.write info.fd, script
        fs.close info.fd, (error) ->
          return reject error if error
          resolve()
      .then ->
        cmd = 'mongo --quiet '
        if server.user and server.password
          cmd += "-u #{server.user} -p #{server.password} "
        cmd += server.url
        cmd += ' ' + info.path

        new Promise (resolve, reject) ->
          exec cmd, (error, stdout, stderr) ->
            result = stdout.toString()
            return reject result if error
            try result = JSON.parse result
            resolve result

  runMapReduce: (server, program) ->
    map = program.map
    reduce = program.reduce
    if program.using_coffeescript
      map = coffee.compile map, filename: 'crostats', bare: true
      map = map.replace /^\(((.|[\r\n])*)\);\n?$/, '$1'
      reduce = coffee.compile reduce, filename: 'crostats', bare: true
      reduce = reduce.replace /^\(((.|[\r\n])*)\);\n?$/, '$1'

    url = server.url
    url = "#{server.user}:#{server.password}@#{url}" if server.user and server.password
    new Promise (resolve, reject) ->
      models.mongodb.MongoClient.connect "mongodb://#{url}", (error, db) ->
        return reject error if error
        db.collection(program.collection).mapReduce map, reduce, out: inline: 1, (error, results) ->
          return reject error.errmsg if error
          _removeIdUnderscore results
          resolve results

module.exports = new Runner()

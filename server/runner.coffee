{exec} = require 'child_process'
fs = require 'fs'
temp = require 'temp'
temp.track()

models = require './models'

class Runner
  start: ->
    setInterval @find.bind(@), 10 * 1000
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
    models.programs.find($where: where.toString(), {_id: 1}).toArray (error, programs) =>
      return console.log 'Error while Runner.find : ' + error if error
      programs.forEach (program) => @runAndUpdate program._id

  runAndUpdate: (program_id) ->
    date = new Date()
    console.log "Run program '#{program_id}' at #{date.toString()}..."
    models.programs.update {_id: program_id}, {$set: 'runner.last_run': date}, safe: true, (error, count) =>
      return if error
      @run program_id, (error, results) ->
        return if error
        models.results.insert { program: program_id, result: results, date: date }, safe: true, (error, result) ->

  run: (program_id, callback) ->
    models.programs.findOne _id: program_id, (error, program) =>
      return callback error if error
      @runProgram program, callback

  runProgram: (program, callback) ->
    if not callback
      callback = ->
    models.servers.findOne _id: program.server, (error, server) =>
      return callback error if error
      switch program.type
        when 'shellscript'
          @runScript server, program, callback
        when 'mapreduce'
          @runMapReduce server, program, callback
        else
          callback 'No program'

  runScript: (server, program, callback) ->
    temp.open 'mongoscript', (error, info) ->
      return callback error if error

      fs.write info.fd, program.script
      fs.close info.fd, (error) ->
        return callback error if error

        cmd = 'mongo --quiet '
        if server.user and server.password
          cmd += "-u #{server.user} -p #{server.password} "
        cmd += server.url
        cmd += ' ' + info.path

        exec cmd, (error, stdout, stderr) ->
          result = stdout.toString()
          return callback result if error
          try result = JSON.parse result
          callback null, result

  runMapReduce: (server, program, callback) ->
    url = server.url
    url = "#{server.user}:#{server.password}@#{url}" if server.user and server.password
    models.mongodb.MongoClient.connect "mongodb://#{url}", (error, db) ->
      return callback error if error
      db.collection(program.collection).mapReduce program.map, program.reduce, out: inline: 1, (error, results) ->
        return callback error if error
        callback null, results

module.exports = new Runner()

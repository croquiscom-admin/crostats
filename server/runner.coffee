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
    if not callback
      callback = ->
    models.programs.findOne _id: program_id, (error, program) ->
      return callback error if error
      models.servers.findOne _id: program.server, (error, server) ->
        return callback error if error
        url = server.url
        url = "#{server.user}:#{server.password}@#{url}" if server.user and server.password
        models.mongodb.MongoClient.connect "mongodb://#{url}", (error, t_db) ->
          return callback error if error
          t_db.collection(program.collection).mapReduce program.map, program.reduce, out: inline: 1, (error, results) ->
            return callback error if error
            callback null, results

module.exports = new Runner()

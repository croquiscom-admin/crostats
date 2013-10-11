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
    models.scripts.find($where: where.toString(), {_id: 1}).toArray (error, scripts) =>
      scripts.forEach (script) => @runAndUpdate script._id

  runAndUpdate: (script_id) ->
    date = new Date()
    console.log "Run script '#{script_id}' at #{date.toString()}..."
    models.scripts.update {_id: script_id}, {$set: 'runner.last_run': date}, safe: true, (error, count) =>
      return if error
      @run script_id, (error, results) ->
        return if error
        models.results.insert { script: script_id, result: results, date: date }, safe: true, (error, result) ->

  run: (script_id, callback) ->
    if not callback
      callback = ->
    models.scripts.findOne _id: script_id, (error, script) ->
      return callback error if error
      models.servers.findOne _id: script.server, (error, server) ->
        return callback error if error
        url = server.url
        url = "#{server.user}:#{server.password}@#{url}" if server.user and server.password
        models.mongodb.MongoClient.connect "mongodb://#{url}", (error, t_db) ->
          return callback error if error
          t_db.collection(script.collection).mapReduce script.map, script.reduce, out: inline: 1, (error, results) ->
            return callback error if error
            callback null, results

module.exports = new Runner()

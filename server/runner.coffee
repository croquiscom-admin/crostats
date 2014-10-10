config = require 'config'
coffee = require 'coffee-script'
{exec} = require 'child_process'
fs = require 'fs'
nodemailer = require 'nodemailer'
Promise = require 'bluebird'
request = require 'superagent'
temp = require 'temp'
temp.track()

models = require './models'

if config.email
  transport = nodemailer.createTransport config.email.method, config.email.transport

_removeIdUnderscore = (item) ->
  if Array.isArray item
    item.forEach _removeIdUnderscore
  else if item._id and not item.id
    item.id = item._id
    delete item._id
  return

class Runner
  start: ->
    setInterval =>
      models.Program.findNeedRun()
      .map (program) =>
        @runAndUpdate program._id
      .then (results) =>
        @refineResults results
      .then (results) =>
        if results.length > 0
          @sendSlack results
          @sendEmail results
    , 10 * 1000
    @

  refineResults: (results) ->
    results = results.filter (result) ->
      result.program? and result.result?
    if results.length is 0
      return []
    results.sort (a, b) ->
      if a.program.title < b.program.title
        return -1
      if a.program.title > b.program.title
        return 1
      return 0
    return results.map (result) ->
      items = result.result.map (item) ->
        if result.last
          for last_item in result.last
            if last_item.id is item.id
              diff = item.value - last_item.value
              if diff > 0
                diff = '+' + diff
              else if diff is 0
                diff = '='
              return "#{item.id} : #{item.value} (#{diff})"
        "#{item.id} : #{item.value}"
      title: result.program.title, result: items.join('\n')

  sendSlack: (results) ->
    if not (config.slack?.hubothook and config.slack?.room)
      return
    fields = results.map (result) -> title: result.title, value: result.result, short: false
    request.post config.slack.hubothook
    .send room: config.slack.room, fallback: 'CroStats', pretext: 'CroStats', color: config.slack.color, fields: fields
    .end (error, res) ->

  sendEmail: (results) ->
    if not (config.email?.message?.from and config.email?.message?.to)
      return
    message = results.map (result) -> "@@ #{result.title} @@\n\n#{result.result}"
    .join '\n\n--------------------------------------------------\n\n'
    options =
      from: config.email.message.from
      to: config.email.message.to
      subject: 'CroStats'
      text: message
    transport.sendMail options

  runAndUpdate: (program_id) ->
    date = new Date()
    console.log "Run program '#{program_id}' at #{date.toString()}..."
    models.Program.update program_id, 'runner.last_run': date
    .then =>
      @run program_id
    .then (result) ->
      models.Result.getList program_id, limit: 1
      .then (last) ->
        if last.length > 0
          result.last = last[0].result
        models.Result.add program_id, date, result.result
        .then ->
          console.log "Run program '#{program_id}' Done"
          Promise.resolve result
    .catch (error) ->
      console.log "Run program '#{program_id}' Failed: #{error.toString()}"

  run: (program_id) ->
    models.Program.get program_id
    .then (program) =>
      @runProgram program
      .then (result) ->
        Promise.resolve program: program, result: result

  runProgram: (program) ->
    models.Server.get program.server
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
            _removeIdUnderscore result
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

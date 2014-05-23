angular.module('CroStats')
.controller 'ProgramsItemCtrl', (CONFIG, $scope, $http, $stateParams) ->
  results_to = new Date()
  $scope.results_types =
    days_07: 'Recent 7 days'
    days_30: 'Recent 30 days'
    items_10: 'Recent 10 items'
  $scope.results_type = 'items_10'

  $scope.types =
    shellscript: 'MongoDB shell script'
    mapreduce: 'Map-Reduce'

  drawChart = (columns, results) ->
    data = new google.visualization.DataTable()
    data.addColumn 'date', 'Date'
    columns.forEach (column) -> data.addColumn 'number', column
    results.forEach (result) ->
      row = [ new Date(result.date) ]
      row.push.apply row, result.result
      data.addRow row
    chart = new google.visualization.LineChart(document.getElementById('chart'))
    chart.draw data, width: 800, height: 400, pointSize: 3

  setResults = (results) ->
    columns = []
    results.forEach (result) ->
      result.result.forEach (item) ->
        columns.push item.id if columns.indexOf(item.id)<0
    columns.sort (a, b) ->
      a = a.toLowerCase()
      b = b.toLowerCase()
      if a < b then -1
      else if a > b then 1
      else 0
    results.forEach (result) ->
      result.result_for_table = columns.map (column) ->
        value = 'N/A'
        pos = result.result.forEach (item) ->
          value = item.value if item.id is column
        return value
      result.result = result.result_for_table.map (value) -> if value is 'N/A' then 0 else value
      result.total = result.result.reduce ((previousValue, currentValue) -> previousValue + currentValue), 0
    $scope.columns = columns
    $scope.results = results

    drawChart columns, results

  loadResults = ->
    to = results_to.getTime()
    query = 'to=' + to
    query += switch $scope.results_type
      when 'days_07' then '&from=' + (to-7*24*60*60*1000)
      when 'days_30' then '&from=' + (to-30*24*60*60*1000)
      when 'items_10' then '&limit=10'
    $http.get("#{CONFIG.api_base_url}/programs/#{$stateParams.id}/results?#{query}").success (results) ->
      setResults results

  $scope.runProgram = ->
    $scope.show_progress = true
    $http.post("#{CONFIG.api_base_url}/runProgram", $scope.program).success (results) ->
      $scope.show_progress = false
      $scope.show_run_result = true
      $scope.run_result = results[0]
    .error (data) ->
      $scope.show_progress = false
      $scope.show_run_result = false
      alert data

  $scope.updateProgram = ->
    $http.put("#{CONFIG.api_base_url}/programs/#{$stateParams.id}", $scope.program).success ->
      $scope.original = angular.copy $scope.program

      $scope.$parent.programs.forEach (program) ->
        if program.id is $scope.program.id
          program.title = $scope.program.title
          program.description = $scope.program.description

  $scope.resetProgram = ->
    $scope.program = angular.copy $scope.original

  $scope.isClean = ->
    angular.equals $scope.program, $scope.original

  $scope.recordTestResult = ->
    $http.post("#{CONFIG.api_base_url}/programs/#{$stateParams.id}/results", $scope.run_result).success ->
      loadResults()

  $scope.$parent.selected = $stateParams.id

  $scope.beautifyScript = ->
    $scope.program.script = js_beautify $scope.program.script if $scope.program.script
  $scope.beautifyMap = ->
    $scope.program.map = js_beautify $scope.program.map if $scope.program.map
  $scope.beautifyReduce = ->
    $scope.program.reduce = js_beautify $scope.program.reduce if $scope.program.reduce

  $http.get("#{CONFIG.api_base_url}/programs/#{$stateParams.id}").success (program) ->
    if program.runner?.type is 'daily'
      $scope.results_type = 'days_07'
    $scope.program = program
    $scope.original = angular.copy program
    loadResults()

  $scope.onChangeUsingCoffeeScript = ->
    $scope.program.script = ''
    $scope.program.map = ''
    $scope.program.reduce = ''

  $scope.$watch 'results_type', ->
    loadResults()

  $('#results_to').datetimepicker defaultDate: results_to
  $('#results_to').on 'dp.change', (event) ->
    results_to = event.date._d
    loadResults()

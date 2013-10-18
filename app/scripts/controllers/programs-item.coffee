angular.module('CroStats')
  .controller 'ProgramsItemCtrl', ($scope, $http, $stateParams) ->
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
          columns.push item._id if columns.indexOf(item._id)<0
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
            value = item.value if item._id is column
          return value
        result.result = result.result_for_table.map (value) -> if value is 'N/A' then 0 else value
        result.total = result.result.reduce ((previousValue, currentValue) -> previousValue + currentValue), 0
      $scope.columns = columns
      $scope.results = results

      drawChart columns, results

    loadResults = ->
      $http.get("/api/programs/#{$stateParams.id}/results").success (results) ->
        setResults results

    $scope.runProgram = ->
      $http.post("/api/runProgram", $scope.program).success (results) ->
        $scope.show_run_result = true
        $scope.run_result = results[0]
      .error (data) ->
        $scope.show_run_result = false
        alert data

    $scope.updateProgram = ->
      $http.put("/api/programs/#{$stateParams.id}", $scope.program).success ->
        $scope.original = angular.copy $scope.program

        $scope.$parent.programs.forEach (program) ->
          if program._id is $scope.program._id
            program.title = $scope.program.title
            program.description = $scope.program.description

    $scope.resetProgram = ->
      $scope.program = angular.copy $scope.original

    $scope.isClean = ->
      angular.equals $scope.program, $scope.original

    $scope.recordTestResult = ->
      $http.post("/api/programs/#{$stateParams.id}/results", $scope.run_result).success ->
        loadResults()

    $scope.$parent.selected = $stateParams.id
    loadResults()

    $http.get("/api/programs/#{$stateParams.id}").success (program) ->
      program.script = js_beautify program.script if program.script
      program.map = js_beautify program.map if program.map
      program.reduce = js_beautify program.reduce if program.reduce
      $scope.program = program
      $scope.original = angular.copy program

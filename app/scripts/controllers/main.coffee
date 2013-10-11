angular.module('statisticsApp')
  .controller 'MainCtrl', ($scope, $http) ->
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
        result.result = columns.map (column) ->
          value = 'N/A'
          pos = result.result.forEach (item) ->
            value = item.value if item._id is column
          return value
        result.total = result.result.reduce ((previousValue, currentValue) -> previousValue + currentValue), 0
      $scope.columns = columns
      $scope.results = results

      drawChart columns, results

    $http.get('/api/scripts').success (scripts) ->
      $scope.scripts = scripts

    $scope.getClass = (id) ->
      if $scope.selected and $scope.selected._id is id
        return 'active'
      else
        return ''

    $scope.showData = (script) ->
      $scope.selected = script
      $http.get("/api/scripts/#{script._id}/results").success (results) ->
        setResults results

    $scope.runScript = (script) ->
      $http.post("/api/scripts/#{script._id}/run").success (results) ->
        setResults results

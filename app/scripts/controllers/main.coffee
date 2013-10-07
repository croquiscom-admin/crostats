angular.module('statisticsApp')
  .controller 'MainCtrl', ($scope, $http) ->
    $http.get('/api/scripts').success (scripts) ->
      $scope.scripts = scripts

    $scope.showData = (id) ->
      $http.get("/api/scripts/#{id}/results").success (results) ->
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
        $scope.columns = columns
        $scope.results = results

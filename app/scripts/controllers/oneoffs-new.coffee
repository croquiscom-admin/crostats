angular.module('CroStats')
  .controller 'OneoffsNewCtrl', ($scope, $http) ->
    $scope.program = {}

    $scope.runProgram = ->
      $scope.show_progress = true
      $http.post("/api/runProgram", $scope.program).success (results) ->
        $scope.show_progress = false
        $scope.show_run_result = true
        $scope.program.result = results[0].result
      .error (data) ->
        $scope.show_progress = false
        $scope.show_run_result = false
        alert data

    $scope.save = ->
      $http.post("/api/oneoffs", $scope.program).success ->

    $scope.$parent.selected = 'new'

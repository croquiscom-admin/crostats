angular.module('CroStats')
  .controller 'ProgramsOneoffCtrl', ($scope, $http) ->
    $scope.program =
      type: 'shellscript'

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

    $scope.$parent.is_oneoff = true

    $scope.save = ->
      $http.post("/api/oneoffs", $scope.program).success ->

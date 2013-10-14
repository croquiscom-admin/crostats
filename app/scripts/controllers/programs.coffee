angular.module('statisticsApp')
  .controller 'ProgramsCtrl', ($scope, $http) ->
    $http.get('/api/programs').success (programs) ->
      $scope.programs = programs

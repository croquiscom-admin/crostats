angular.module('statisticsApp')
  .controller 'ProgramsCtrl', ($scope, $http) ->
    $http.get('/api/programs').success (programs) ->
      $scope.programs = programs

    $scope.getClass = (id) ->
      if $scope.selected is id
        return 'active'
      else
        return ''

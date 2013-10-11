angular.module('statisticsApp')
  .controller 'ScriptsCtrl', ($scope, $http) ->
    $http.get('/api/scripts').success (scripts) ->
      $scope.scripts = scripts

    $scope.getClass = (id) ->
      if $scope.selected is id
        return 'active'
      else
        return ''

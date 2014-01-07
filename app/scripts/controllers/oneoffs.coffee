angular.module('CroStats')
  .controller 'OneoffsCtrl', ($scope, $http, $state, Restangular) ->
    $http.get('/api/servers').success (servers) ->
      $scope.servers = servers

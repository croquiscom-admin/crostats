angular.module('CroStats')
  .controller 'OneoffsCtrl', (CONFIG, $scope, $http, $state) ->
    $http.get("#{CONFIG.api_base_url}/servers").success (servers) ->
      $scope.servers = servers

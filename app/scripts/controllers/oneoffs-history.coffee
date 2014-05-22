angular.module('CroStats')
.controller 'OneoffsHistoryCtrl', (CONFIG, $scope, $http) ->
  $scope.oneoffs = []
  $http.get("#{CONFIG.api_base_url}/oneoffs").success (oneoffs) ->
    $scope.oneoffs = oneoffs

  $scope.$parent.selected = 'history'

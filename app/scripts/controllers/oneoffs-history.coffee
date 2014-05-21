angular.module('CroStats')
.controller 'OneoffsHistoryCtrl', (CONFIG, $scope) ->
  $scope.oneoffs = []
  $http.get("#{CONFIG.api_base_url}/oneoffs").success (oneoffs) ->
    for item in oneoffs
      item.date = new Date(item.date).toString()
    $scope.oneoffs = oneoffs

  $scope.$parent.selected = 'history'

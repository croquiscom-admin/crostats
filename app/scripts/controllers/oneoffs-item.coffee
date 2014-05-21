angular.module('CroStats')
.controller 'OneoffsItemCtrl', (CONFIG, $scope, $http, $stateParams) ->
  $http.get("#{CONFIG.api_base_url}/oneoffs/#{$stateParams.id}").success (oneoff) ->
    $scope.oneoff = oneoff

  $scope.$parent.selected = ''

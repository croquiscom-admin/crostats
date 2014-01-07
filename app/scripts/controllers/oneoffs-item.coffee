angular.module('CroStats')
  .controller 'OneoffsItemCtrl', ($scope, $http, $stateParams) ->
    $http.get("/api/oneoffs/#{$stateParams.id}").success (oneoff) ->
      $scope.oneoff = oneoff

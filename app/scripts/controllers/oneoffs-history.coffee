angular.module('CroStats')
  .controller 'OneoffsHistoryCtrl', ($scope, Restangular) ->
    oneoffs = Restangular.all('oneoffs')

    $scope.oneoffs = []
    oneoffs.getList().then (oneoffs) ->
      for item in oneoffs
        item.date = new Date(item.date).toString()
      $scope.oneoffs = oneoffs

    $scope.$parent.selected = 'history'

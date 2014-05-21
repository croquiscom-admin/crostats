angular.module('CroStats')
.controller 'ProgramsListCtrl', ($scope) ->
  $scope.$parent.selected = undefined
  $scope.$parent.is_oneoff = false

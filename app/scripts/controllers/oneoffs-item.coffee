angular.module('CroStats')
.controller 'OneoffsItemCtrl', (CONFIG, $scope, $http, $stateParams) ->
  $http.get("#{CONFIG.api_base_url}/oneoffs/#{$stateParams.id}").success (oneoff) ->
    $scope.oneoff = oneoff
    _updateEditors()

  $scope.$parent.selected = ''

  _code_editors = []
  _updateEditors = ->
    _code_editors.forEach (editor) ->
      if $scope.oneoff?.using_coffeescript
        editor.getSession().setMode 'ace/mode/coffee'
      else
        editor.getSession().setMode 'ace/mode/javascript'

  $scope.aceLoaded = (editor) ->
    _code_editors.push editor
    _updateEditors()

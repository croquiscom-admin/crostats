angular.module('CroStats')
.controller 'OneoffsNewCtrl', (CONFIG, $scope, $http) ->
  $scope.oneoff =
    type: 'shellscript'

  $scope.runOneoff = ->
    $scope.show_progress = true
    $http.post("#{CONFIG.api_base_url}/runProgram", $scope.oneoff).success (results) ->
      $scope.show_progress = false
      $scope.show_run_result = true
      $scope.oneoff.result = results[0].result
    .error (data) ->
      $scope.show_progress = false
      $scope.show_run_result = false
      alert data

  $scope.save = ->
    $http.post("#{CONFIG.api_base_url}/oneoffs", $scope.oneoff).success ->

  $scope.$parent.selected = 'new'

  $scope.onChangeUsingCoffeeScript = ->
    $scope.oneoff.script = ''
    _updateEditors()

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

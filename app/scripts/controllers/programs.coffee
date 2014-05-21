angular.module('CroStats')
.controller 'ProgramsCtrl', (CONFIG, $scope, $http, $state) ->
  $scope.programs = []
  $http.get("#{CONFIG.api_base_url}/programs").success (programs) ->
    $scope.programs = programs

  $http.get("#{CONFIG.api_base_url}/servers").success (servers) ->
    $scope.servers = servers

  $scope.getTitleOfProgram = (program_id) ->
    return $.t 'programs.list.oneoff' if $scope.is_oneoff
    return if not $scope.programs or not program_id
    title = 'Unknown'
    $scope.programs.forEach (program) ->
      title = program.title if program.id is program_id
    return title

  $scope.addProgram = ->
    id = prompt $.t 'programs.list.input_program_id'
    if id
      new_program = id: id, title: id, description: id
      programs.post(new_program).then ->
        $scope.programs.push new_program

  $scope.deleteProgram = ->
    if $scope.selected and confirm $.t 'programs.list.delete_program_confirm'
      program_to_delete = _.find $scope.programs, (program) -> program.id is $scope.selected
      program_to_delete.remove().then ->
        $state.go 'programs.list'
        $scope.programs = _.without $scope.programs, program_to_delete

angular.module('CroStats')
  .controller 'ProgramsCtrl', ($scope, $http, $state, Restangular) ->
    programs = Restangular.all('programs')

    $scope.programs = []
    programs.getList().then (programs) ->
      $scope.programs = programs

    $http.get('/api/servers').success (servers) ->
      $scope.servers = servers

    $scope.getTitleOfProgram = (program_id) ->
      return if not $scope.programs or not program_id
      title = 'Unknown'
      $scope.programs.forEach (program) ->
        title = program.title if program._id is program_id
      return title

    $scope.addProgram = ->
      id = prompt $.t 'programs.list.input_program_id'
      if id
        new_program = _id: id, title: id, description: id
        programs.post(new_program).then ->
          $scope.programs.push new_program

    $scope.deleteProgram = ->
      if $scope.selected and confirm $.t 'programs.list.delete_program_confirm'
        program_to_delete = _.find $scope.programs, (program) -> program._id is $scope.selected
        program_to_delete.remove().then ->
          $state.go 'programs.list'
          $scope.programs = _.without $scope.programs, program_to_delete

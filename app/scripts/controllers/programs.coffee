angular.module('statisticsApp')
  .controller 'ProgramsCtrl', ($scope, $http, $state) ->
    $http.get('/api/servers').success (servers) ->
      $scope.servers = servers

    $http.get('/api/programs').success (programs) ->
      programs.forEach (program) ->
        program.title ||= program._id
        program.description ||= program.title
      $scope.programs = programs

    $scope.getTitleOfProgram = (program_id) ->
      return if not $scope.programs or not program_id
      title = 'Unknown'
      $scope.programs.forEach (program) ->
        title = program.title if program._id is program_id
      return title

    $scope.addProgram = ->
      id = prompt $.t 'programs.list.input_program_id'
      if id
        $http.post('/api/programs', id: id).success ->
          $scope.programs.push _id: id, title: id, description: id

    $scope.deleteProgram = ->
      if confirm $.t 'programs.list.delete_program_confirm'
        selected = $scope.selected
        $http.delete("/api/programs/#{selected}").success ->
          $state.go 'programs.list'
          $scope.programs = $scope.programs.filter (program) -> program._id isnt selected

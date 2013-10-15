angular.module('statisticsApp')
  .controller 'ProgramsCtrl', ($scope, $http) ->
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
      id = prompt "Input program's id to add"
      if id
        $http.post('/api/programs', id: id).success ->
          $scope.programs.push _id: id, title: id, description: id

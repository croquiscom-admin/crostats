angular.module('statisticsApp')
  .controller 'ProgramsCtrl', ($scope, $http) ->
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

angular.module('statisticsApp', ['ui.router'])
  .config ($stateProvider, $urlRouterProvider) ->
    $urlRouterProvider.otherwise '/programs'

    $stateProvider
      .state('programs',
        url: '/programs'
        templateUrl: 'views/programs.html'
        controller: 'ProgramsCtrl'
      )
      .state('programs.item',
        url: '/:id'
        templateUrl: 'views/programs-item.html'
        controller: 'ProgramsItemCtrl'
      )

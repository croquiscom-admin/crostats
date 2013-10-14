angular.module('statisticsApp', ['ui.router'])
  .config ($stateProvider, $urlRouterProvider) ->
    $urlRouterProvider.otherwise '/programs'

    $stateProvider
      .state('programs',
        url: '/programs'
        abstract: true
        templateUrl: 'views/programs.html'
        controller: 'ProgramsCtrl'
      )
      .state('programs.list',
        url: ''
        templateUrl: 'views/programs-list.html'
      )
      .state('programs.item',
        url: '/:id'
        templateUrl: 'views/programs-item.html'
        controller: 'ProgramsItemCtrl'
      )

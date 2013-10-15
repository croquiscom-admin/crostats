angular.module('statisticsApp', ['ui.router', 'jm.i18next'])
  .config ($stateProvider, $urlRouterProvider, $i18nextProvider) ->
    $urlRouterProvider.otherwise '/programs'

    $i18nextProvider.options =
      fallbackLng: 'en'

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
        controller: 'ProgramsListCtrl'
      )
      .state('programs.item',
        url: '/:id'
        templateUrl: 'views/programs-item.html'
        controller: 'ProgramsItemCtrl'
      )

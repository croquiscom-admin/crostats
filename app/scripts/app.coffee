angular.module('CroStats', ['ui.router', 'jm.i18next', 'restangular'])
  .config ($stateProvider, $urlRouterProvider, $i18nextProvider, RestangularProvider) ->
    RestangularProvider.setBaseUrl '/api'
    RestangularProvider.setRestangularFields id: '_id'

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
      .state('oneoffs',
        url: '/oneoffs'
        abstract: true
        templateUrl: 'views/oneoffs.html'
        controller: 'OneoffsCtrl'
      )
      .state('oneoffs.new',
        url: ''
        templateUrl: 'views/oneoffs-new.html'
        controller: 'OneoffsNewCtrl'
      )
      .state('oneoffs.history',
        url: '/history'
        templateUrl: 'views/oneoffs-history.html'
        controller: 'OneoffsHistoryCtrl'
      )

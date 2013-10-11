angular.module('statisticsApp', ['ui.router'])
  .config ($stateProvider, $urlRouterProvider) ->
    $urlRouterProvider.otherwise '/scripts'

    $stateProvider
      .state('scripts',
        url: '/scripts'
        templateUrl: 'views/scripts.html'
        controller: 'ScriptsCtrl'
      )
      .state('scripts.item',
        url: '/:id'
        templateUrl: 'views/scripts-item.html'
        controller: 'ScriptsItemCtrl'
      )

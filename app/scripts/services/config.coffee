angular.module('CroStats')
.factory 'CONFIG', ($location) ->
  host = $location.host()
  if host is 'localhost'
    api_base_url = 'http://localhost:7293/api'
  else
    api_base_url = '/api'
  return {
    api_base_url: api_base_url
  }

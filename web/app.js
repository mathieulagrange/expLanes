
var app = angular.module('explanes', []);

app.config(['$compileProvider',
		 function($compileProvider) {   
		     $compileProvider.aHrefSanitizationWhitelist(/^\s*(https?|ftp|mailto|blob|file):/);
		 }]);

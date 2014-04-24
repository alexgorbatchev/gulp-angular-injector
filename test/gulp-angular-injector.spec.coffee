require 'coffee-errors'

path = require 'path'
chai = require 'chai'
gutil = require 'gulp-util'
# using compiled JavaScript file here to be sure module works
gulpAngularInjector = require '../lib/gulp-angular-injector.js'

expect = chai.expect
chai.use require 'sinon-chai'

describe 'gulp-angular-injector', ->
  it 'logs file path using default formatter', (done) ->
    stream = gulpAngularInjector()

    file = new gutil.File path: 'foo.js', contents: new Buffer """
      ng = function($scope, foo) {}
      function ng($scope, foo) {}
      var ng1 = ng.toString();

      var controller = ng(function($scope, foo, bar) {
        console.log(foo, bar);
      });

      app.service('foo', ng(function controller($scope, foo, bar) {
        console.log(foo, bar);
      }));
    """

    stream.on 'end', ->
      expect(file.contents.toString()).to.equal """
        ng = function($scope, foo) {}
        function ng($scope, foo) {}
        var ng1 = ng.toString();

        var controller = ['$scope', 'foo', 'bar', function($scope, foo, bar) {
          console.log(foo, bar);
        }];

        app.service('foo', ['$scope', 'foo', 'bar', function controller($scope, foo, bar) {
          console.log(foo, bar);
        }]);
      """

      done()

    stream.write file
    stream.end()

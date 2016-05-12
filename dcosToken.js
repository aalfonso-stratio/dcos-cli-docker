/* global $:false phantom:false */

const page = require('webpage').create();
const system = require('system');

const jqueryURI = 'http://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js';
const googleLoginUrl = 'https://accounts.google.com/ServiceLogin';

const DCOSAuthPath = '%HOST%/login?redirect_uri=urn:ietf:wg:oauth:2.0:oob';

const args = system.args;

cleanArguments();

const _host = args[1];
const _username = args[2];
const _password = args[3];

var DEBUG;

onTimeout();
loginOnGoogle();

/////////////

function cleanArguments() {
   if (args.indexOf('--debug') === -1) {
      DEBUG = false;
      console.debug = function() {};
   } else {
      DEBUG = true;
      args.splice(args.indexOf('--debug'), 1);
   }
}

function loginOnGoogle() {
   page.open(googleLoginUrl, function(status) {
      if (status !== 'success') {
         console.debug('Fail loading Google.');
         return phantom.exit();
      }
      page.includeJs(jqueryURI, function() {
         return page.evaluate(function(username, password) {
            $('input[type=email]').val(username);
            $('#next').click();

            setTimeout(function() {
               $('input[type=password]').val(password);
               $('#signIn').click();
            }, 1000);
            return true;

         }, _username, _password);
      });
      checkGoogleLoaded();
   });
}

function checkGoogleLoaded() {
   setTimeout(function() {
      if (DEBUG) {
         page.render('debug.1.google-auth.png');
      }
      console.debug('[Google login] debug.1.google-auth.png');

      goToDCOSAuth();
   }, 6000);
}

function goToDCOSAuth() {
   var url = DCOSAuthPath.replace('%HOST%', _host);

   page.open(url, function(status) {
      if (status !== 'success') {
         console.debug('Fail loading DCOS Auth.');
         return phantom.exit(1);
      }
      page.includeJs(jqueryURI, function() {
         page.onPageCreated = function(newPage) {
            newPage.onClosing = function() {
               setTimeout(function() {
                  getDCOSToken();
               }, 2000);
            };
         };
         page.evaluate(function() {
            $('#google-oauth2').click();
         });
         setTimeout(function() {
            if (DEBUG) {
               page.render('debug.2.DCOS-auth.png');
            }
            console.debug('[DCOS auth] debug.2.DCOS-auth.png');
         }, 1000);
      });
   });
}

function getDCOSToken() {
   if (DEBUG) {
      page.render('debug.3.DCOS-token.png');
   }
   console.debug('[DCOS token] debug.3.DCOS-token.png');

   var token = page.evaluate(function() {
      console.debug($('pre.token-snippet').length);
      return $('pre.token-snippet').text();
   });
   console.info(token);
   phantom.exit();
}

function onTimeout() {
   setTimeout(function() {
      console.debug('TIMEOUT');
      phantom.exit();
   }, 30000);
}

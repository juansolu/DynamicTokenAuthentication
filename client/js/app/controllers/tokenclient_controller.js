'use strict';

var SecureClientCtrl = function($scope, $location, $http) {
    
    var SERVER_LOCATION = "http://localhost:3000/";
    var INITIAL_SEED = "bgcdadjoofmejkpnjdcicpfmfoeohjam";
    var ROTATED_TOKEN = "bgcdadjoofmejkpnjdcicpfmfoeohjam";
    
    $scope.msg = "";
    $scope.loggedMessages = "";
    $scope.username = "validuser";
    $scope.tokenList = [];
    $scope.tokenList.push(INITIAL_SEED);
    
    function encryptVigenereToken(content){
      return doCrypt(false, $('input[name=encryptToken]:checked').val(), content);
    }

    function decryptVigenereToken(content){
      return doCrypt(true, $('input[name=encryptToken]:checked').val(), $scope.encryptedMessage);
    }

    function setCharAt(str,index,chr) {
      if(index > str.length-1) return str;
      var replacement = str.charCodeAt(index) + 1;
      return str.substr(0,index) + String.fromCharCode(replacement) + str.substr(index+1);
    }

    function getRandomUUID(){
      $scope.randomUUID = 'xxxxxxxxxxxxjxxxyxxxxxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
          var r = Math.random()*16|0, v = c == 'x' ? r : (r&0x3|0x8);
          //return v.toString(16);
          return String.fromCharCode(97 + v);
      });
    }

    $scope.accessSecureData = function(){
      var msgSendReset = {
        user: $scope.username,
        msgContent: encryptVigenereToken("REQUESTCONFIDENTIALLISTOFUSERS")
      }

      function displaySensitiveData(userdata){
        return userdata["id"] +": "+userdata["username"]+". Email: "+userdata["email"]+" Created: "+ userdata["created_at"];
      }

      $.getJSON(SERVER_LOCATION+'users.json?callback=?', msgSendReset, function(result){

        if(result["error"] != undefined){
          $scope.loggedMessages += result["error"] + "\n";
          $scope.$apply();
          return;
        }
        for(var i=0; i<result["msg"].length; i++){
          $scope.loggedMessages += displaySensitiveData(result["msg"][i]) + "\n";
        }

        $scope.$apply();
      });

    };

    $scope.resetUserToInitState = function(){
      $("#resetUser").modal('hide');
      
      console.log($scope.password);

      var msgSendReset = {
        user: $scope.username,
        msgContent: encryptVigenereToken("RESET|"+$scope.password)
      }

      $.getJSON(SERVER_LOCATION+'resetDemo?callback=?', msgSendReset, function(result){
        $scope.loggedMessages += result["msg"] + "\n";
        $scope.tokenList = [];
        $scope.tokenList.push(INITIAL_SEED);
        ROTATED_TOKEN = INITIAL_SEED;
        $scope.$apply();
      });

    };

    $scope.connect = function(){

      var msgSendConnect = {
        user: $scope.username,
        msgContent: encryptVigenereToken("CONNECT")
      }

    $.getJSON(SERVER_LOCATION+'login?callback=?', msgSendConnect, function(result){
      $scope.loggedMessages += result["msg"] + "\n";
      $scope.$apply();
    });

    };

    $scope.disconnect = function(){
      var msgSendDisconnect = {
        user: $scope.username,
        msgContent: encryptVigenereToken("DISCONNECT")
      }

    $.getJSON(SERVER_LOCATION+'logout?callback=?', msgSendDisconnect, function(result){
      $scope.loggedMessages += result["msg"] + "\n";
      ROTATED_TOKEN = doCryptCeasar(false, $scope.tokenList.length, ROTATED_TOKEN);
      $scope.tokenList.push(ROTATED_TOKEN);
      $scope.$apply();
    });
    };
}

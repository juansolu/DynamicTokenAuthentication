'use strict';

var SecureClientCtrl = function($scope, $location, $http) {
    
    var SERVER_LOCATION = "http://localhost:3000/";
    var INITIAL_SEED = "verysimpleinitialtokensecretkey"
    
    $scope.msg = "";
    $scope.loggedMessages = "";
    $scope.username = "juan";
    $scope.tokenList = [];
    $scope.tokenList.push(INITIAL_SEED);
    
    function encryptVigenereToken(content){
      return doCrypt(false, $('input[name=encryptToken]:checked').val(), content);
    }

    function decryptVigenereToken(content){
      doCrypt(true, $('input[name=encryptToken]:checked').val(), $scope.encryptedMessage);
    }

    $scope.sendMsg = function(){
      $scope.encryptedMessage = encryptVigenereToken($('#msg').val());
      console.log("Encrypted: "+ $scope.encryptedMessage);
      $scope.decryptedMessage = decryptVigenereToken($scope.encryptedMessage);
      console.log("Decrypted: "+$scope.decryptedMessage);
      
      $('#msg').val(''); 
      $('#msg').focus();
    };

    function getRandomUUID(){
      return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
          var r = Math.random()*16|0, v = c == 'x' ? r : (r&0x3|0x8);
          return v.toString(16);
      });
    }

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
        msgContent: "DISCONNECT"
      }

    $.getJSON(SERVER_LOCATION+'logout?callback=?', msgSendDisconnect, function(result){
      $scope.loggedMessages += result["msg"] + "\n";
      $scope.$apply();
    });
    };

    console.log(getRandomUUID());

}

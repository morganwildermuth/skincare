skincareApp.controller("searchCtrl", ["$scope", function($scope) {

  $scope.searchTerm = "";

  $scope.search = function(){
    var location = window.location.protocol + "//" + window.location.host + "?" + "searchTerm=" + $scope.searchTerm;
    window.location.href = location;
  }

}]);
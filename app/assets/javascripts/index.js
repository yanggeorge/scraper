/**
 * Created by ym on 2016/10/9 0009.
 */

app.directive("contextInfo", function () {
    return {
        restrict: 'A',
        link: function (scope, ele, attrs) {
            scope.$on("show-context-info", function(e, obj){
               ele.addClass("visible");
            });

            scope.$on("hide-context-info", function(e, obj){
                ele.removeClass("visible");
            });
        }
    };
});

app.controller('indexController', function($scope){
    var node1 = new ym.rpa.TreeNode();
    node1.name = "finance.com.cn";
    node1.style = "visible";
    var node2 = new ym.rpa.TreeNode();
    node2.name = "www.baidu.com";
    var treeNodes = [node1, node2];

    $scope.treeNodes = treeNodes ;

});
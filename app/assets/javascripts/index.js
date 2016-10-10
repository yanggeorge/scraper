/**
 * Created by ym on 2016/10/9 0009.
 */

app.directive("contextInfo", function () {
    return {
        restrict: 'A',
        link: function (scope, ele, attrs) {

            scope.active_node = null;
            scope.$on("toggle_context_info", function(e, node) {
                if (scope.active_node === null || scope.active_node.id !== node.id){
                    ele.addClass("visible");
                    console.log(node);
                    scope.active_node = node;
                    scope.$emit("set_treenode_active", node);
                }else{
                    ele.removeClass("visible");
                    console.log(scope.active_node);
                    scope.active_node = null;
                    scope.$emit("set_all_treenode_no_active");
                }

            });

            scope.$on("close_context_info", function(e, obj){
                ele.removeClass("visible");
                console.log(scope.active_node);
                scope.active_node = null;
                scope.$emit("set_all_treenode_no_active");
            });
        }
    };
});

app.controller('indexController', function($scope){


    var node1 = new ym.rpa.TreeNode();
    node1.name = "finance.com.cn";

    var node2 = new ym.rpa.TreeNode();
    node2.name = "www.baidu.com";
    var treeNodes = [node1, node2];

    $scope.treeNodes = treeNodes ;

    $scope.toggle_context_info = function(node) {
        $scope.$emit("toggle_context_info",node);
    };

    $scope.close_context_info = function(){
        $scope.$emit("close_context_info");
    };

    $scope.$on("set_all_treenode_no_active",function(){
        var n = _.size($scope.treeNodes);
        for(var i = 0 ; i < n; i++){
            $scope.treeNodes[i].style = "";
        }
    });

    $scope.$on("set_treenode_active", function(evt, active_node){
        var n = _.size($scope.treeNodes);
        for(var i = 0 ; i < n; i++){
            var node = $scope.treeNodes[i];
            if(node.id === active_node.id){
                node.style = "active";
            }else{
                node.style = "";
            }
        }
    });
});
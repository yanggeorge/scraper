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


app.controller('indexController', function($scope, $http){

    var init_treeNodes = function(robots_json) {
        console.log(robots_json);
        var nodes = [];
        var robots = JSON.parse(robots_json);
        _.each(robots, function(r) {
            var node = new ym.rpa.TreeNode();
            node.id = r.robot_id;
            node.name = r.robot_name;
            nodes.push(node);
        });
        return nodes;
    };
    $scope.treeNodes = init_treeNodes(window.ym.all_robots) ;

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

    $scope.delete_robot = function(robot_id) {
        $scope.close_context_info();
        var path = '/index/delete_robot';
        var ramdom = Math.uuid();
        var promise = $http.post(path, {robot_id: robot_id, random : ramdom}, {timeout:5000})
            .success(function(data, status, headers, config)
            {
                $scope.treeNodes = init_treeNodes(data.result);
                return false;
            })
            .error(function(data, status, headers, config)
            {
                console.log("robot delete error ...");
                return false;
            }
        );
    };

});

app.expand_controller_MainCtrl = function($scope, $http, $q, getXpath, $timeout){
    console.log("expand MainCtrl in index.js");

    $scope.create_robot_dialog = { visible : false };

    $scope.create_robot_dialog.show = function() {
        clear_input();
        this.visible = true;
        var options = {
            title: "Create New Robot",
            resizable: true,
            closable: true,
            minWidth: 650,
            modal: true,
            buttons: [],
            close: function () {
                console.log("close dialog");
                $scope.create_robot_dialog.visible = false;
            }
        };
        this.dlog = jQuery("#new_dialog");
        this.dlog.dialog(options);
    };

    $scope.create_robot_dialog.cancel = function() {
        this.visible = false;
        this.dlog.dialog("close");
    };

    var clear_input = function(){
        $scope.robot_url = "http://";
        $scope.robot_name = "";
    };
    $scope.create_robot_dialog.create = function() {
        this.visible = false;
        this.dlog.dialog("close");
        var form = jQuery("#create_robot_form");
        form.submit();
    };

    $scope.$watch("robot_url", function(v){
        console.log("change" + v);
        var parser = document.createElement('a');
        parser.href = v;
        var host_name = parser.hostname;
        var name = $scope.robot_name ;
        if(v && (_.startsWith(host_name,name) ||  _.startsWith(name,host_name))) {
            $scope.robot_name = host_name;
        }
    }, true);

};

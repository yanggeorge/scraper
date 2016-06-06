/**
 * Created by ym on 2016/5/16 0016.
 */
var app = angular.module('myApp',['templates']);

app.directive("tabPane",function(){
    return {
        restrict : 'C',
        transclude : false,
        scope : {},
        controller : function(){
            this.removeAll = function ($scope, $element, $attrs) {
                $element.find("> .tab-buttons > .button ").removeClass("active");
                $element.find(".tab-pane, .tab-page").removeClass('active');
            };
            this.hi = function(){console.log("tabPane ....")};
        },
        link : function(scope,element,attrs, ctrl){
            scope.hash = {};
            element.find("> .tab-buttons > .button").click(function(e){
                ctrl.removeAll(scope, element);
                var ele = angular.element(e.target);
                ele.addClass("active");
                var page = scope.hash[ele.attr("tab-id")] ;
                angular.element(page).addClass("active");
            });
            var eles = element.find("> .tab-buttons > .button");
            var pages = element.find(".tab-pane , .tab-page");
            for (var i = 0; i < eles.length ; i++){
                var e = angular.element(eles[i]);
                console.log(e.attr("tab-id"));
                scope.hash[e.attr("tab-id")] = pages[i];
            }
        }
    }
});

app.controller('MainCtrl', function($scope){
    $scope.closeSidePane1 = function(){
        toggle();
    };
    $scope.closeSidePane2 = function(){
        toggle_sidepane2();
    };
    $scope.sidePaneView1 = 'contextmenu1.html';
    $scope.sidePaneView2 = 'contextmenu2.html';

    var menu1 = {'name':'Extract from element', 'invoke':function(){
        $scope.sidePaneView1 = 'fields.html';
    } };
    $scope.contextMenu1 = [menu1];
    var menu2 = {'name':'Extract from element', 'invoke':function(){
        $scope.sidePaneView2 = 'fields.html';
    } };
    $scope.contextMenu2 = [menu2];

    $scope.svgs = init_svgs();
    $scope.nodes = init_nodes();
});

var init_svgs = function(){
    var svgs = [];
    var svg1={},svg2={},svg3={},svg4={};
    svg1.id = Math.uuid();
    svg1.svg_id = Math.uuid();
    svg1.marker_id = Math.uuid();
    svg1.path_id = Math.uuid();
    svg1.is_end = false;
    svg1.color = "#2ecc71"; //表示active
    svg1.points = "125,45 190,45 195,45";

    svg2.id = Math.uuid();
    svg2.svg_id = Math.uuid();
    svg2.marker_id = Math.uuid();
    svg2.path_id = Math.uuid();
    svg2.is_end = false;
    svg2.color = "#666";
    svg2.points = "315,45 380,45 385,45";

    svg3.id = Math.uuid();
    svg3.svg_id = Math.uuid();
    svg3.marker_id = Math.uuid();
    svg3.path_id = Math.uuid();
    svg3.is_end = false;
    svg3.color = "#666";
    svg3.points = "505,45 570,45 575,45";

    svg4.id = Math.uuid();
    svg4.svg_id = Math.uuid();
    svg4.marker_id = Math.uuid();
    svg4.path_id = Math.uuid();
    svg4.is_end = true;
    svg4.color = "#666";
    svg4.points = "695,45 720,45";
    svgs.push(svg1);
    svgs.push(svg2);
    svgs.push(svg3);
    svgs.push(svg4);
    return svgs;
};

var init_nodes = function(){
    var nodes = [];
    var node1= {},node2={}, node3={}, node4={};
    node1.title = "Go to URL";
    node1.position = {left: 25+'px', top: 25+'px', width: 90+'px', height: 40+'px'};
    node1.desc = "node1 desc";

    node2.title = "Click";
    node2.position = {left: 215+'px', top: 25+'px', width: 90+'px', height: 40+'px'};
    node2.desc = "node1 desc";

    node3.title = "Extract";
    node3.position = {left: 405+'px', top: 25+'px', width: 90+'px', height: 40+'px'};
    node3.desc = "node1 desc";

    node4.title = "Save";
    node4.position = {left: 595+'px', top: 25+'px', width: 90+'px', height: 40+'px'};
    node4.desc = "node1 desc";
    nodes.push(node1);
    nodes.push(node2);
    nodes.push(node3);
    nodes.push(node4);
    return nodes;
};
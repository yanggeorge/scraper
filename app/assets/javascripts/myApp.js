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

    var robot = init_robot();
    console.log(robot.to_s());

    var svgs = init_svgs(robot);
    console.log(svgs.length);
    var nodes = init_nodes(robot);
    console.log(svgs.length);
    $scope.robot = robot;
    $scope.svgs = svgs;
    $scope.nodes = nodes;
});
app.controller('nodeCtrl', function($scope){
    $scope.addStepAfter = function(node){
        console.log(node);
    };

    $scope.addStepBefore= function(node) {
        console.log(node);
    };
});
var init_robot = function() {
    var robot = new ym.rpa.Robot("test");

    var step1 = new ym.rpa.Step(ym.rpa.ACTION_VISIT);
    step1.options.push("aa");
    step1.options.push("aa");
    var step2 = new ym.rpa.Step(ym.rpa.ACTION_EXTRACT);
    var step3 = new ym.rpa.Step(ym.rpa.ACTION_CLICK);
    var step4 = new ym.rpa.Step(ym.rpa.ACTION_FLUSH);
    step1.next.push( step2.id );
    step2.next.push( step3.id );
    step3.next.push( step4.id );
    robot.steps[step1.id] = step1;
    robot.steps[step2.id] = step2;
    robot.steps[step3.id] = step3;
    robot.steps[step4.id] = step4;
    var output = new ym.rpa.Ouput("test");
    output.options.push("bbb");
    output.options.push("bbb");
    robot.outputs[output.id] = output;
    robot.first_step = step1.id;
    return robot;
};

var init_svgs = function(robot) {
    var svgs = [];

    var steps = robot.steps;
    var step_id = robot.first_step;
    var step_ids = Object.keys(steps);
    while (step_ids.includes(step_id) && steps[step_id] != null) {
        var step = steps[step_id];
        var svg = new ym.rpa.Node_svg(step_id);
        svgs.push(svg);
        step_id = step.next[0];
    }
    return compute_svg_position(svgs);
};

var compute_svg_position = function(svgs) {
    svgs.forEach(function (svg, index, array) {
        if (index == array.length - 1) {
            svg.is_end = true;
            var p1 = 125 + index * 190;
            var p2 = p1 + 25;
            svg.points = p1 + ",45 " + p2 + ",45";
        } else {
            var p1 = 125 + index * 190;
            var p2 = 190 + index * 190;
            var p3 = 195 + index * 190;
            svg.points = p1 + ",45 " + p2 + ",45 " + p3 + ",45";
        }

    });
    return svgs;
};
var init_nodes = function(robot) {
    var nodes = [];

    var steps = robot.steps;
    var step_id = robot.first_step;
    var step_ids = Object.keys(steps);
    while (step_ids.includes(step_id) && steps[step_id] != null) {
        var step = steps[step_id];
        var node = new ym.rpa.Node(step.title);
        node.id = step.id;
        var next = step.next;
        if (next.length == 1) {
            step_id = next[0];
            nodes.push(node);
        } else {
            node.is_end = true;
            nodes.push(node);
            break;
        }
    }
    nodes = compute_node_position(nodes);
    return nodes;
};

var compute_node_position = function(nodes) {
    nodes.forEach(function(node,index,array){
        node.left = 25 + 190 * index;
        node.top = 25;
        node.width = 90;
        node.height = 40;
        node.compute_position();
    });

    return nodes;
};

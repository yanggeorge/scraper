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

app.directive("flowEditor",function(){
    return {
        restrict : 'C',
        transclude : false,
        scope : {},
        controller : function(){

        },
        link : function(scope,element,attrs, ctrl){
            element.click(function(){
                //console.log("flowEditor ...");
                //scope.$parent.nodes.forEach(function(n,index,array){
                //    n.style = "";
                //});
                //scope.$parent.$apply();
                //toggle_sidepane2_state(0);
                scope.$emit("flowEditorClick");
            });
        }
    }
});

app.controller('FormCtrl',function($scope){

    $scope.save = function($event){
        //可以把更新过的robot_def存入数据库。暂时不实现。
        console.log("save ...");
        console.log($scope.stepData);
        console.log($scope.currentNode);
        refresh_robot($scope);
        toggle_sidepane2_state(0);
    };

    $scope.close = function(){
        toggle_sidepane2_state(0);
    };

    $scope.$watch('stepData.type',function(){
        console.log("stepData type change ...");
        $scope.has_url = false;
        $scope.has_output = false;
        $scope.has_tag = false;
        switch ($scope.stepData.type){
            case "42" :
            {
                $scope.has_url = true;
                $scope.stepData.title = "Go to URL";
                break;
            }
            case "0":
            {
                $scope.has_tag = true;
                $scope.has_output = true;
                $scope.stepData.title = "Extract";
                break;
            }
            case "18":
            {
                $scope.has_tag = true;
                $scope.stepData.title = "Click";
                break;
            }
            case "15":
            {
                $scope.stepData.title = "Save";
                break;
            }
            case "49" :
            {
                $scope.stepData.title = "Do nothing";
                break;
            }
            default :
            {

            }
        }
    });

});
var refresh_robot = function($scope){
    // 根据录入的stepData 更新robot
    var currentNode = $scope.$parent.currentNode;
    var step = new ym.rpa.Step();
    step.title = $scope.stepData.title;
    console.log($scope.stepData.type);
    switch ($scope.stepData.type ){
        case  "42" : // VISIT
        {
            step.value = $scope.stepData.url;
            step.action = ym.rpa.ACTION_VISIT ;
            break;
        }
        case "18": // CLICK
        {
            step.tags[0] =$scope.stepData.tag ;
            step.action = ym.rpa.ACTION_CLICK ;
            break;
        }
        case "0": // EXTRACT
        {
            step.tags[0] =$scope.stepData.tag ;
            step.value = $scope.stepData.output ;
            step.action = ym.rpa.ACTION_EXTRACT ;
            break;
        }
        case "15": // FLUSH
        {
            step.action = ym.rpa.ACTION_FLUSH ;
            break;
        }
        case "49": // NOTHING
        {
            step.action = ym.rpa.ACTION_NOTHING ;
            break;
        }
        default :
        {
            throw "editNode is error ...";
        }
    }
    step.id = $scope.$parent.currentNode.id;
    step.next = $scope.$parent.robot.steps[step.id].next ;
    $scope.$parent.robot.steps[step.id] = step ;
    console.log($scope.$parent.robot.to_s());
};

var set_stepData = function($scope, node){
    var step = $scope.robot.steps[node.id];
    $scope.has_output = false;
    $scope.has_url = false;
    $scope.has_tag = false;
    $scope.stepData = {};
    var stepData = $scope.stepData ;
    stepData.title = step.title;
    switch (step.action ){
        case  ym.rpa.ACTION_VISIT :
        {
            stepData.url = step.value;
            stepData.type = "42";
            $scope.has_url = true;
            break;
        }
        case ym.rpa.ACTION_CLICK:
        {
            stepData.tag = step.tags[0];
            stepData.type = "18";
            $scope.has_tag = true;
            break;
        }
        case ym.rpa.ACTION_EXTRACT:
        {
            stepData.tag = step.tags[0];
            stepData.output = step.value;
            stepData.type = "0";
            $scope.has_tag = true;
            $scope.has_output = true;
            break;
        }
        case ym.rpa.ACTION_FLUSH:
        {
            stepData.type = "15";
            break;
        }
        case ym.rpa.ACTION_NOTHING:
        {
            stepData.type = "49";
            break;
        }
        default :
        {
            throw "editNode is error ...";
        }
    }
};
app.controller('MainCtrl', function($scope){
    $scope.closeSidePane1 = function(){
        toggle_sidepane1_state(0);
    };
    $scope.closeSidePane2 = function(){
        toggle_sidepane2_state(0);
    };
    $scope.sidePaneView1 = 'contextmenu1.html';
    $scope.sidePane2Title = 'sidePane2Title not set!';
    $scope.sidePaneView2 = 'contextmenu2.html';

    var menu1 = {'name':'Extract from element', 'invoke':function(){
        $scope.sidePaneView1 = 'fields.html';
    } };
    $scope.contextMenu1 = [menu1];
    var menu2 = {'name':'Extract from element', 'invoke':function(){
        $scope.sidePaneView2 = 'fields.html';
    } };
    $scope.contextMenu2 = [menu2];

    $scope.robot = init_robot();
    $scope.svgs = init_svgs($scope.robot);
    $scope.svg_width = compute_svg_width($scope.svgs);
    $scope.nodes = init_nodes($scope.robot);

    $scope.$watch("robot" , function () {
        console.log("robot change ...");
        $scope.nodes = init_nodes($scope.robot);
        $scope.svgs = init_svgs($scope.robot);
        $scope.svg_width = compute_svg_width($scope.svgs);
    }, true);



    $scope.addStepAfter = function(node){

        var new_step = new ym.rpa.Step(ym.rpa.ACTION_NOTHING);
        var step = $scope.robot.steps[node.id];
        $scope.robot.add_step_after(new_step,step);
    };

    $scope.addStepBefore= function(node) {
        var new_step = new ym.rpa.Step(ym.rpa.ACTION_NOTHING);
        var step = $scope.robot.steps[node.id];
        $scope.robot.add_step_before(new_step,step);
    };

    $scope.clickNode = function(node){
        $scope.nodes.forEach(function(n,index,array){
            n.style = "";
            if (n.id == node.id){
                n.style = "selected";
            }
        });
        toggle_sidepane2_state(0);
        setTimeout(function(){toggle_sidepane2_state(1);},100);
        $scope.sidePane2Title='1 steps selected';
        $scope.sidePaneView2 = 'contextmenu2.html';
        var menus = init_context_menu2(node, $scope);
        console.log(menus);
        $scope.contextMenu2 = menus;
        console.log($scope.contextMenu2);

    };

    // 监听事件。
    $scope.$on("flowEditorClick",function(){
        $scope.nodes.forEach(function(n,index,array){
            n.style = "";
        });
        $scope.$apply();
        toggle_sidepane2_state(0);
    });


});

var compute_svg_width = function(svgs){
    var svg_width = 125 + svgs.length * 190 + 30 ;
    if(svg_width < 1200){
        svg_width = 1200;
    }
    return svg_width;
};

var init_context_menu2 = function(node , $scope){
    var menus = [];
    var menu1 = {'name':'Edit', 'invoke':function(){
        $scope.sidePaneView2 = 'edit_node.html';
        $scope.sidePane2Title = 'Edit step';
        $scope.currentNode = node;
        toggle_sidepane2_state(2);
        set_stepData($scope, node);

    } };
    var menu2 = {'name':'Delete', 'invoke':function(){
        console.log($scope.robot.to_s());
        var step = $scope.robot.steps[node.id];
        $scope.robot.remove_step(step);
        toggle_sidepane2_state(0);
    } };
    var menu3 = {'name':'Add step after', 'invoke':function(){
        var new_step = new ym.rpa.Step(ym.rpa.ACTION_NOTHING);
        var step = $scope.robot.steps[node.id];
        $scope.robot.add_step_after(new_step,step);
        toggle_sidepane2_state(0);
    } };
    var menu4 = {'name':'Add step before', 'invoke':function(){
        var new_step = new ym.rpa.Step(ym.rpa.ACTION_NOTHING);
        var step = $scope.robot.steps[node.id];
        $scope.robot.add_step_before(new_step,step);
        toggle_sidepane2_state(0);
    } };
    menus.push(menu1,menu2,menu3,menu4);
    return menus;
};

var init_robot = function() {
    //var robot = new ym.rpa.Robot("test");
    //var step1 = new ym.rpa.Step(ym.rpa.ACTION_VISIT);
    //step1.options.push("aa");
    //step1.options.push("aa");
    //var step2 = new ym.rpa.Step(ym.rpa.ACTION_EXTRACT);
    //var step3 = new ym.rpa.Step(ym.rpa.ACTION_CLICK);
    //var step4 = new ym.rpa.Step(ym.rpa.ACTION_FLUSH);
    //step1.next.push( step2.id );
    //step2.next.push( step3.id );
    //step3.next.push( step4.id );
    //robot.steps[step1.id] = step1;
    //robot.steps[step2.id] = step2;
    //robot.steps[step3.id] = step3;
    //robot.steps[step4.id] = step4;
    //var output = new ym.rpa.Ouput("test");
    //output.options.push("bbb");
    //output.options.push("bbb");
    //robot.outputs[output.id] = output;
    //robot.first_step = step1.id;
    var robot = ym.rpa.Robot.from_json_string(window.ym.robot_string);
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

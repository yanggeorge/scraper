/**
 * Created by ym on 2016/5/16 0016.
 */
var app = angular.module('myApp',['templates']);
jQuery.fn.view = function() {
    return this[0].ownerDocument.defaultView
};
app.factory("kcSleep",function($timeout){
    return function(ms) {
        return function(value) {
            return $timeout(function() {
                return value;
            }, ms);
        };
    };
});
app.factory("getXpath",function(){
    return function(element) {
        console.log("in getXpath service:", element);
        var xpath = '';
        for ( ; element && element.nodeType == 1; element = element.parentNode )
        {
            var id = jQuery(element.parentNode).children(element.tagName).index(element) + 1;
            id >= 1 ? (id = '[' + id + ']') : (id = '');
            xpath = '/' + element.tagName.toLowerCase() + id + xpath;
        }
        console.log(xpath);
        parts = xpath.split("/");
        parts.shift() ; // 弹出 html
        xpath = "//" + parts.join("/") ;  // 使用相对路径
        return xpath;
    };
});


app.directive("title",function(){
    return {
        restrict : 'A',
        link : function(a,b,c){
            if (c.title) {
                var d = $('<div class="button-hover-title" />');
                b.on("mouseenter", function (a) {
                    if (c.title) {
                        try {
                            d.html(c.title.replace("\n", "<br />")).hide()
                        } catch (e) {
                            d = $('<div class="button-hover-title" />'), d.html(c.title.replace("\n", "<br />")).hide()
                        }
                        var f = b.offset(), g = (c.title.match(/\n/g) || []).length + 1;
                        b.hasClass("below") || f.top < 50 ? f.top += 15 + b.height() : g > 1 ? f.top -= b.height() * g - 16 * (g - 1) - 3 : f.top -= 38, b.closest("body").append(d);
                        var h = d.width();
                        if ("block" !== b.css("display")) {
                            var i = (h - b.width()) / 2;
                            f.left += -1 * i
                        }
                        d.css(f).show();
                        var j = $(b.view()).width(), k = d.outerWidth() + f.left;
                        k > j && d.css("left", j - d.outerWidth());
                        //console.log(d.css("left"));
                    }
                }).on("mouseleave mousewheel wheel mousedown", function (a) {
                    d.detach()
                }), a.$on("windowed", function () {
                    d.detach()
                }), a.$on("unwindowed", function () {
                    d.detach()
                }), a.$on("$destroy", function () {
                    d.remove()
                })
            }
        }
    }
});
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
app.directive('loading',   ['$http' ,function ($http)
    {
        return {
            restrict: 'A',
            link: function (scope, elm, attrs)
            {
                scope.isLoading = function () {
                    return $http.pendingRequests.length > 0;
                };

                scope.data_complete = false;

                scope.$on("set_data_complete_true",function(){
                    scope.data_complete = true;
                });

                scope.$on("set_data_complete_false",function(){
                    scope.data_complete = false;
                });

                scope.$watch(scope.data_complete, function(v){
                    if(v && scope.isLoading() == false){
                        setTimeout(function () {
                            elm.hide();
                        }, 1200);
                    }
                });

                scope.$watch(scope.isLoading, function (v)
                {
                    if(v ){
                        elm.show();
                    }else{
                        if (v == false && scope.data_complete == true) {
                            setTimeout(function () {
                                elm.hide();
                            }, 1200);
                        }
                    }
                });
            }
        };

    }]);
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

app.directive('markerContainer', ['$window','$q','$timeout', function($window,$q,$timeout){
    return {
        restrict : "C",
        scope: {},
        link: function(scope, element, attrs){
            scope.list_div = [];
            scope.selected_div = [];
            element.bind('scroll', function(){
                scope.$emit("scroller_event",{left:element.scrollLeft(),top:element.scrollTop()});
            });
            var ele = element.find(".scroller");
            ele.bind('mousemove',function(e){
                var point = {x: e.pageX - ele.scrollLeft() , y: e.pageY - ele.scrollTop() };
                scope.$emit("trigger_mousemove",point);
            });
            ele.bind('mousedown',function(e){
                if(is_left_click(e)) {
                    var point = {x: e.pageX - ele.scrollLeft(), y: e.pageY - ele.scrollTop()};
                    scope.$emit("trigger_selected", point);
                }else if(is_right_click(e)){
                    redo();
                }
            });
            ele.bind("contextmenu",function(e){
                e.preventDefault();
            });
            var redo = function(){
                clean_selected();
                var defer = $q.defer();
                var promise = defer.promise;
                defer.resolve("redo");
                toggle_sidepane1_state(0);
            };
            var is_left_click = function(e){
                return (e.which && e.which == 1) || (e.button && e.button == 1);
            };
            var is_right_click = function(e){
                return  (e.which && e.which == 3) || (e.button && e.button == 2);
            };

            function clean_selected() {
                scope.selected_div.forEach(function (e) {
                    e.remove()
                });
                scope.selected_div = [];
            }
            function clean_list() {
                scope.list_div.forEach(function (e) {
                    e.remove()
                });
                scope.list_div = [];
            }

            element.bind('mouseout',function(e){
                clean_list();
            });


            scope.$on("create_div",function(evt,obj){
                //console.log(obj);
                var div = jQuery('<div></div>');
                div.width(obj.width);
                div.height(obj.height);
                div.css('postion', 'absolute');
                div.css('top',obj.top);
                div.css('left',obj.left);
                div.css('pointer-events','none');
                div = angular.element(div).addClass('marker suggestion');
                clean_list();
                var ele = element.find("> .container ,.scroll");
                ele.append(div);
                scope.list_div.push(div);
            });
            scope.$on("selected_div",function(evt,obj){
                console.log(obj);
                var div = jQuery('<div></div>');
                div.width(obj.width);
                div.height(obj.height);
                div.css('postion', 'absolute');
                div.css('top',obj.top);
                div.css('left',obj.left);
                div.css('pointer-events','none');
                div = angular.element(div).addClass('marker suggestion selected');
                clean_selected();
                var ele = element.find("> .container ,.scroll");
                ele.append(div);
                scope.selected_div.push(div);
            });

            scope.$on("reposition_created_div",function(evt,ele_list){
                console.log("reposition", scope.selected_div.length);
                scope.selected_div.forEach(function(created_div,i){
                    var ele = jQuery(ele_list[i]);
                    var new_offset = ele.offset();
                    console.log(new_offset);
                    created_div.css('top',new_offset.top);
                    created_div.css('left',new_offset.left);
                });
            });
        }
    }}]);
app.directive('inner', ['$window', function($window){
    return {
        restrict : "C",
        scope: {},
        link: function(scope, element, attrs){
            var w = angular.element($window);
            scope.$watch(
                function(){
                    return {
                        height : element.parent().height(),
                        width : element.parent().width()
                    }
                },
                function(obj){//监听父窗口的高宽，并设置为相等，而宽度与父窗口的父窗口相等。
                    console.log("inner ....");
                    element.height(obj.height);
                    element.width(element.parent().parent().width());
                },
                true
            );
            w.bind('resize', function () {//监听window的resize事件。并重新检验与父窗口的高和宽。
                console.log("resize ....");
                scope.$apply();
                scope.$emit("window_resize");
            });
        }
    }}]);
app.directive('iframeOnload',  ['$window', function($window){
    return {
        scope: {},
        link: function(scope, element, attrs){
            element.on('load', function(){
                var height = document.getElementById("modified_page").contentWindow.document.body.scrollHeight;
                var width = document.getElementById("modified_page").contentWindow.document.body.scrollWidth;
                console.log(height,width);
                scope.$emit("iframe_resize",{height:height,width:width});
            });
            var w = angular.element($window);
            w.bind('resize', function(e){
                w.resizeEvt;
                w.bind("resize",function(){
                    clearTimeout(w.resizeEvt);
                    w.resizeEvt = setTimeout(function()
                    {
                        //code to do after window is resized
                        var height = document.getElementById("modified_page").contentWindow.document.body.scrollHeight;
                        var width = document.getElementById("modified_page").contentWindow.document.body.scrollWidth;
                        console.log("window resize ",height,width);
                        scope.$emit("iframe_resize",{height:height,width:width});

                    }, 250);
                });
            });
        }
    }}]);

app.controller('MarkerCtrl', function($scope){

    $scope.$on("iframe_resize", function(e,obj){
       console.log(obj);
        $scope.iframe_height = obj.height + "px";
        $scope.iframe_width = obj.width + "px";
        $scope.$apply(); // ng-style没有及时更新，需要强制更新。
    });
    // 实现iframe和上层的div联合滚动 sync scroll
    $scope.$on("scroller_event",function(evt, obj){
        var iframe = jQuery("#modified_page");
        iframe.contents().scrollTop(obj.top);
        iframe.contents().scrollLeft(obj.left);
    });

    $scope.tmp_ele = jQuery("<div></div>");
    $scope.$on("trigger_mousemove",function(evt,point){
        //console.log(point);
        var doc = document.getElementById("modified_page").contentWindow.document;
        var ele = doc.elementFromPoint(point.x, point.y);
        //console.log(ele);
        if ( $scope.tmp_ele !== ele){
            //console.log(ele);
            $scope.tmp_ele = ele;
            var offset = jQuery(ele).offset();
            //console.log(offset);
            var obj = {width: jQuery(ele).outerWidth(), height : jQuery(ele).outerHeight(),
                left:offset.left, top:offset.top};
            $scope.$broadcast("create_div",obj);
        }
    });
    $scope.selected_ele_list = [];
    $scope.$on("trigger_selected",function(evt,point){
        var doc = document.getElementById("modified_page").contentWindow.document;
        var ele = doc.elementFromPoint(point.x, point.y);
        console.log(ele);

        //console.log(ele);
        $scope.selected_ele_list = [];
        $scope.selected_ele_list.push(ele);
        var offset = jQuery(ele).offset();
        //console.log(offset);
        var obj = {width: jQuery(ele).outerWidth(), height : jQuery(ele).outerHeight(),
            left:offset.left, top:offset.top};
        $scope.$broadcast("selected_div",obj);
        $scope.$emit("decide_sidepane",ele);

    });
    $scope.$on("window_resize",function(evt){
        //iframe中的元素的offset已经发生改变。
        $scope.$broadcast("reposition_created_div",$scope.selected_ele_list);
    });
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

    $scope.change = function(){
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
    };

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
            step.field = $scope.stepData.output ;
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
            stepData.output = step.field;
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
app.controller('MainCtrl', function($scope, $http, $q, getXpath, $timeout){
    angular.element(document).ready(function () {
        window.sidepane_state = 0; // 0 : 关闭 ,1 : 270px, 2: 520px
        window.sidepane2_state = 0;
        size();
        setTimeout(function(){
            $scope.player.stepForward();//angular scope need time to initialize.
        },300);

    });

    $scope.get_visit_url = function(){
      return $scope.robot.steps[$scope.robot.first_step].value ;
    };

    $scope.load_url = function( url ,env){
        console.log("load_url");
        var path = '/scrape/get_page' ;
        var doc = document.getElementById('modified_page').contentWindow.document;
        doc.open();
        doc.write("<body></body>");
        //doc.close();
        var ramdom = Math.uuid();
        $scope.$broadcast("set_data_complete_false");
        var promise = $http.post(path, {url: url, random : ramdom}, {timeout:50000})
            .success(function(data, status, headers, config)
            {
                //doc.open();
                doc.write(data.page);
                doc.close();
                env.url_page = data.page;
                return false;
            })
            .error(function(data, status, headers, config)
            {
                console.log("post error ...");
                return false;
            }
        );
        promise.then(function(){
            $scope.$broadcast("set_data_complete_true");
        });
        var promise1 = promise.then(function(){
           return $timeout(1200); // 与关闭 elm.hide的等待时间相同。
        });
        return promise1;
    };
    $scope.extract_data = function( url, tag ,env, field){
        console.log("extract_data");
        var path = '/scrape/extract_data' ;
        var ramdom = Math.uuid();
        $scope.$broadcast("set_data_complete_false");
        var promise = $http.post(path, {url: url, tag:tag, random : ramdom}, {timeout:50000})
            .success(function(data, status, headers, config)
            {
                // results change
                console.log(data);
                env[field] = data.result;
                return false;
            })
            .error(function(data, status, headers, config)
            {
                console.log("extract error ...");
                return false;
            }
        );
        promise.then(function(){
            $scope.$broadcast("set_data_complete_true");
        });
        var promise1 = promise.then(function(){
           return $timeout(1200); // 与关闭 elm.hide的等待时间相同。
        });
        return promise1;
    };

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
        toggle_sidepane1_state(2);
    } };
    $scope.contextMenu1 = [menu1];
    var menu2 = {'name':'Extract from element', 'invoke':function(){
        $scope.sidePaneView2 = 'fields.html';
        toggle_sidepane1_state(2);
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
        $scope.player.fresh_with($scope.robot);
        $scope.render_color_before_current_play();
        $scope.$broadcast("robot_change");
    }, true);
    $scope.render_color_before_current_play = function(){
        var current_id = $scope.player.current.step.id;
        var first_id = $scope.player.first.step.id ;
        var is_end = $scope.player.is_end;
        if(current_id != first_id && is_end != true) {
            var pre_id = $scope.player.current.pre.id;
            $scope.svgs.forEach(function (svg, index, array) {
                if (svg.from_node == pre_id) {
                    svg.is_active = true;
                    svg.init_color();
                } else {
                    svg.is_active = false;
                    svg.init_color();
                }
            });
        }else if(is_end == true){
            // 说明当前节点指向最后一个，并且应该显示结束。
            $scope.svgs.forEach(function (svg, index, array) {
                if (svg.from_node == current_id) {
                    svg.is_active = true;
                    svg.init_color();
                } else {
                    svg.is_active = false;
                    svg.init_color();
                }
            });
        }else{
            $scope.svgs.forEach(function(svg, index, array){
                svg.is_active = false;
                svg.init_color();
            });
        }
    };


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
    $scope.$on("play_start", function(e, node_id){
        console.log($scope.player);
        console.log(node_id);
        $scope.nodes.forEach(function(n,index,array){
            if(n.id == node_id){
                n.style = "playing";
            }else{
                n.style = "";
            }
        });
        $scope.svgs.forEach(function(svg, index, array){
            svg.is_active = false;
            svg.init_color();
        });

    });
    $scope.$on("play_stop", function(e, node_id){
        console.log(node_id);
        $scope.nodes.forEach(function(n,index,array){
            if(n.id == node_id){
               n.style = "";
            }
        });
        $scope.svgs.forEach(function(svg, index, array){
            if (svg.from_node == node_id){
                svg.is_active = true;
                svg.init_color();
            }else{
                svg.is_active = false;
                svg.init_color();
            }
        });

    });
    $scope.$on("decide_sidepane",function(e,element){
        var extract_xpath = $scope.getXpath_from_element(element);
        console.log(extract_xpath);
        $scope.extract_xpath = extract_xpath;
        $scope.sidepane1_title = $scope.get_title_from_element(element);
        $scope.sidepane1_view = 'contextmenu1.html';
        $scope.contextMenu1 = $scope.get_contextmenu1(element);
        toggle_sidepane1_state(1);
        $scope.$apply();
    });
    $scope.getXpath_from_element = function(element){
        //计算element的xpath
        return getXpath(element);
    };
    $scope.get_title_from_element = function(element){
        return "1 element selected";
    };
    $scope.get_contextmenu1 = function(element) {
        var menus = [];
        var menu1 = {'name':'Extract from element', 'invoke':function(){
            $scope.sidepane1_title = 'Configure step';
            $scope.sidepane1_view = 'sidepane1_configure.html';
            toggle_sidepane1_state(2);
        } };
        var menu2 = {'name':'Click element', 'invoke':function(){
            // robot 增加一个step
            toggle_sidepane1_state(0);
        } };
        menus.push(menu1,menu2);
        return menus;
    };

    var player = new ym.rpa.Player($scope.robot);
    player.stepForward = function(){
        if(this.playing == false ){
            this.playing = true;
            console.log("step forward ...");
            var play_promise =  this.play();
            play_promise.then(function(){
                $scope.player.playing = false;
            });
        }
    };
    player.stepBack = function(){
      if(this.playing == false){
          this.pre_step();
          $scope.render_color_before_current_play();
      }
    };

    player.restart = function(){
        this.restart_init();
        this.togglePlay();
    };
    player.togglePlay = function(){
      if(this.playing == false){
          this.playing = true;
          player.auto_play();
      }else{
          this.playing = false;
      }
    };

    player.auto_play = function(){
        if(this.playing && this.is_end == false){
            var play_promise =  this.play();
            play_promise.then(function(){
                console.log("auto_play..");
                if($scope.player.playing && $scope.player.is_end == false){
                    $scope.player.auto_play();
                }else{
                    $scope.player.playing = false;
                }
            });
        }else if(this.playing && this.is_end == true){
            this.playing = false;
        }
    };
    //play()是个返回一个promise
    player.play = function(){

        if(this.is_end == true){
            console.log("this is end.");
            var defer = $q.defer();
            var promise = defer.promise;
            defer.resolve("this is end.");
            return promise;
        }
        console.log(this.current.pre);
        console.log(this.current.step);
        console.log(this.current.next);

        $scope.$emit("play_start",this.current.step.id);

        var type = this.current.step.action ;
        var play_promise = null;
        console.log(type);
        switch (type) {
            case ym.rpa.ACTION_VISIT :
            {
                play_promise = this.play_action_visit();
                break;
            }
            case ym.rpa.ACTION_CLICK :
            {
                break;
            }
            case ym.rpa.ACTION_EXTRACT :
            {
                play_promise = this.play_action_extract();
                break;
            }
            case ym.rpa.ACTION_FLUSH :
            {
                play_promise = this.play_action_flush();
                break;
            }
            case ym.rpa.ACTION_NOTHING :
            {
                play_promise = this.play_action_nothing();
                break;
            }
            default :
                throw("play has error.")
        }

        play_promise.then(function(){
            console.log("play_promise...");
            $scope.$emit("play_stop",$scope.player.current.step.id);
            if ($scope.player.next != null){
                console.log("next is not null");
                $scope.player.next.pre_state = $scope.player.current.post_state;
                console.log($scope.player.current.step.id);
                console.log($scope.player.next.step.id);
                $scope.player.current = $scope.player.next;
                if($scope.player.next.next != null){
                    var next_id = $scope.player.next.next.id ;
                    $scope.player.next = $scope.player.play_steps[$scope.player.play_step_ids.indexOf(next_id)] ;
                }else{
                    $scope.player.next = null;
                }
            }else{
                $scope.player.is_end = true;
                $scope.player.next = null;
                console.log("next step is null.");
            }
        });

        return play_promise;

    };
    player.play_action_visit = function(){
        var env = jQuery.extend(true,{},this.current.pre_state);
        var step = this.current.step;
        console.log(step.to_s());
        var url = step.value;
        var promise = $scope.load_url(url , env);

        env.url = url;
        this.current.post_state = env ;
        return promise;
    };
    player.play_action_extract = function(){
        var env = jQuery.extend(true,{},this.current.pre_state);
        var step = this.current.step;
        var field = step.field;
        var tag = step.tags[0];
        var promise = $scope.extract_data(env.url, tag, env, field);

        this.current.post_state = env ;
        return promise;
    };
    player.play_action_flush = function(){
        var env = jQuery.extend(true,{},this.current.pre_state);
        var defer = $q.defer();
        var promise = defer.promise;
        defer.resolve("flush");
        promise.then(function(){
            var row = {};
            _.forEach($scope.robot.outputs,function(value,key){
                var field = value.id;
               if(env[field] || env[field] !== undefined){
                   row[field] = env[field];
                   delete env[field];
               }
            });
            $scope.$broadcast("resultsCtrl_flush_data",row);
        });
        var promise1 =  promise.then(function(){
            return $timeout(1000);
        });
        this.current.post_state = env ;
        return promise1 ;
    };
    player.play_action_nothing = function(){
        var env = jQuery.extend(true,{},this.current.pre_state);
        console.log(this);
        var defer = $q.defer();
        var promise = defer.promise;
        defer.resolve("nothing");

        var player = this;
        var promise1 =  promise.then(function(){
             return $timeout(1000);
        });

        this.current.post_state = env ;
        return promise1;
    };
    console.log(player);
    player.fresh_with($scope.robot);
    console.log(player);
    $scope.player = player ;


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
    var output = new ym.rpa.Output("test");
    robot.outputs[output.id] = output;
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
app.controller('fieldsCtrl',function($scope){

});
app.controller('fieldCtrl',function($scope){

});
app.directive("csValidate", ["$parse", function (a) {
    return {
        restrict: "A", require: "ngModel", link: function (b, c, d, f) {
            function g(a) {
                try {
                    return h(b, {$value: a})
                } catch (c) {
                    console.warn("Validator threw exception: ", c.stack || c)
                }
                return !1
            }

            var h = a(d.csValidate), i = d.csValidate.replace(/[^a-z0-9]+/gi, "").toLowerCase(), j = function (a) {
                return g(a) ? f.$setValidity(i, !0) : f.$setValidity(i, !1), a
            };
            f.$parsers.unshift(j), f.$setValidity(i, !0), b.$on("$destroy", function () {
                _.pull(f.$parsers, j)
            })
        }
    }
}]);
app.controller('OutputsCtrl',function($scope){
    $scope.fieldTypes = {string:'Text',number:'Number',boolean:'True / False'};

    $scope.fieldIsUnique = function(field_name){
        var flag = true;
        _.forEach($scope.robot.outputs, function(n,key){
           if (field_name == key ){
               flag = false;
           }
        });
        return flag
    };

    var field1 = ym.rpa.Output.from_hash({defaultValue: null,
        title: "asbc",
        type: "string",
        options: [],
        id: "asbc"
    });

    var init_outputFields = function(){
        var list = [];
        _.forEach($scope.robot.outputs,function(value,key){
            list.push(value);
        });
        return list;
    };
    $scope.outputFields = init_outputFields() ;
    $scope.$on("robot_change",function(evt){
        $scope.outputFields = init_outputFields() ;
    });

    $scope.is_boolean = function(type){
        return  type == 'boolean';
    };
    $scope.checkForChange = function(){
        $scope.robot.outputs={};
        _.forEach($scope.outputFields,function(ele){
            $scope.robot.outputs[ele.id] = ele;
        });
    };
    $scope.move = function(list, item, n){
        var d = _.indexOf(list, item);
        _.remove(list, item), list.splice(d + n, 0, item)
    };
    $scope.remove = function(list,item){
        _.remove(list,item);
    };
    $scope.addOutputField = function(){
        var field = new ym.rpa.Output("");
        $scope.outputFields.push(field);
    };
});

app.controller('fieldElementsCtrl',function($scope){
    $scope.get_outputs = function(){
        var steps = [];
        var step = new ym.rpa.Step(ym.rpa.ACTION_EXTRACT);
        step.tags.push($scope.extract_xpath);

        steps.push(step);
        return steps;
    };
    $scope.fieldSteps = $scope.get_outputs();



    $scope.save = function(event){
        var current_step = $scope.robot.steps[$scope.player.current.step.id];
        if($scope.player.is_end) {
            $scope.robot.add_step_after($scope.fieldSteps[0], current_step);
        }else{
            $scope.robot.add_step_before($scope.fieldSteps[0], current_step);
        }
        $scope.$broadcast("save_extract_field");
        toggle_sidepane1_state(0);
    };
});

app.controller('fieldCtrl',function($scope){
    $scope.addField = false;
    $scope.fieldTypes = {string:'Text',number:'Number',boolean:'True / False'};

    $scope.fieldDef = new ym.rpa.Output("");
    $scope.fields = (function(){
        var map = {};
        _.forEach($scope.robot.outputs,function(value,key){
            map[key] = value.id;
        });
        return map;
    })();

    $scope.$on("save_extract_field",function(e){

        if($scope.addField){
            console.log($scope.fieldDef);
            $scope.step.field = $scope.fieldDef.id;
            $scope.robot.outputs[$scope.fieldDef.id]=$scope.fieldDef;
        }else{

        }
    });
});

app.controller('resultsCtrl',function($scope){
    $scope.output_rows = [];
    $scope.$on("resultsCtrl_flush_data",function(evt,row){
        $scope.output_rows.push(row);
        update_formattedOutput(row);
    });

    var init_outputFields = function(){
        var list = [];
        _.forEach($scope.robot.outputs,function(value,key){
            list.push(value);
        });
        return list;
    };
    $scope.outputFields = init_outputFields() ;

    var init_formattedOutput = function(){
        var header = [];
        var rows = [];
        var data = [];
        _.forEach($scope.robot.outputs,function(value,key){
            header.push(value.id);
            data.push("");
        });
        rows.push({data:data});
        return {header:header, rows :rows};
    };
    var update_formattedOutput = function(row){
        var header = $scope.formattedOutput.header;
        var rows = $scope.formattedOutput.rows;
        var last_row = _.last(rows); // 只更新最后一行数据
        var data = [];
        var i = 0;
        _.forEach($scope.robot.outputs,function(value,key){
            var field = value.id;
            if ( row[field] || row[field] !== undefined){
                last_row.data[i] = row[field]
            }else{
                last_row.data[i] = ""
            }
            data.push("");
            i ++ ;
        });
        rows.push({data:data});
        $scope.formattedOutput =  {header : header, rows : rows} ;
    };
    $scope.formattedOutput = init_formattedOutput();
    var update_formattedOutput_for_robot_change = function(){
        var new_formattedOutput = init_formattedOutput();
        var new_header = new_formattedOutput.header;
        var new_rows = [];
        var old_header = $scope.formattedOutput.header ;
        var old_rows = $scope.formattedOutput.rows ;

        var i = 0;
        _.forEach(old_rows, function(row){
            if(i < old_rows.length - 1) {
                var map = {};
                var j = 0;
                _.forEach(old_header, function (field) {
                    map[field] = row.data[j];
                    j++;
                });
                var data = [];
                _.forEach(new_header, function (new_field) {
                    if (map[new_field] || map[new_field] !== undefined) {
                        data.push(map[new_field]);
                    } else {
                        data.push("");
                    }
                });
                new_rows.push({data: data});
            }
            i++;
        });
        var last_row = [];
        _.forEach(new_header, function(new_field){
            last_row.push("");
        });
        new_rows.push({data : last_row}); // 插入一个空行。
        return {header : new_header, rows : new_rows};
    };
    $scope.$on("robot_change",function(evt){
        $scope.outputFields = init_outputFields() ;
        $scope.formattedOutput = update_formattedOutput_for_robot_change();
    });

    $scope.resetOutput = function(){
      $scope.formattedOutput = init_formattedOutput();
    };
});
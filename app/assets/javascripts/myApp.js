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
    $scope.closeSidePane = function(){
        toggle();
    };
    $scope.sidePaneView = 'contextmenu.html';

    var menu = {'name':'Extract from element', 'invoke':function(){
        $scope.sidePaneView = 'fields.html';
    } };
    var contextMenu = [menu];
    $scope.contextMenu = contextMenu;

});
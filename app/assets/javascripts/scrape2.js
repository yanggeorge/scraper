/**
 * Created by ym on 2016/5/31 0031.
 */
function size() {
    if (window.innerWidth)
        winWidth = window.innerWidth;
    else if ((document.body) && (document.body.clientWidth))
        winWidth = document.body.clientWidth;
    if (window.innerHeight)
        winHeight = window.innerHeight;
    else if ((document.body) && (document.body.clientHeight))
        winHeight = document.body.clientHeight;

    var p0 = document.getElementById("p0");
    var p1 = document.getElementById("p1");
    var p2 = document.getElementById("p2");

    //p0.style.width = String(winWidth) + "px";
    //p0.style.height = String(winHeight - 300) + "px";
    $('#p0').css("width", String(winWidth) + "px");
    $('#p0').css("height", String(winHeight - 300) + "px");

    var p2_width = $("#p2").width();
    $('#p1').css("width", String(winWidth - p2_width) + "px");

    var p4_width = $("#p4").width();
    $('#p3').css("width", String(winWidth - p4_width) + "px");


}

//jQuery(document).ready(function () {
//    window.sidepane_state = 0; // 0 : 关闭 ,1 : 270px, 2: 520px
//    window.sidepane2_state = 0;
//    size();
//
//});

var load_page =  function(){
    var option = {
        url: "/scrape/get_page",
        type: "post",
        data: {url: 'http://www.he-n-tax.gov.cn/hbgsww_new/hbgsgkml/ajxxgk/201511/t20151113_1014250.html'},
        success: function (data) {
            console.log(data);
            document.getElementById('modified_page').contentWindow.document.open();
            document.getElementById('modified_page').contentWindow.document.write(data.page);
            document.getElementById('modified_page').contentWindow.document.close();
        },
        error: function (data) {
            return false;
        }
    };
    jQuery.ajax(option);
};


var toggle = function () {
    var state = window.sidepane_state;
    if (state == 0) {
        window.sidepane_state = 1;
        toggle_state(1,"#p1", "#p2",1);
    } else {
        window.sidepane_state = 0;
        toggle_state(0,"#p1", "#p2",1);
    }
};

var toggle_sidepane2 = function () {
    var state = window.sidepane2_state;
    if (state == 0) {
        window.sidepane2_state = 1;
        toggle_state(1,"#p3", "#p4", 2);
    } else {
        window.sidepane2_state = 0;
        toggle_state(0,"#p3", "#p4", 2);
    }
};

var toggle_sidepane1_state = function(state){
    toggle_state(state, "#p1","#p2",1);
};
var toggle_sidepane2_state = function(state){
    toggle_state(state, "#p3","#p4",2);
};
// 三种状态之间进行切换。
var toggle_state = function(state, main_id, sidepane_id, flag){
    var main = $(main_id);
    var side = $(sidepane_id);
    var current_state ;
    var current_sidpane_width = side.width();
    switch (current_sidpane_width){
        case 0 : {current_state = 0; break;}
        case 270 : {current_state = 1; break;}
        case 520 : {current_state = 2; break;}
        default:{
            current_state = 0;
            console.log("current_sidepane_width = " + current_sidpane_width);
        }
    }
    if (flag == 1){
        animate_sidepane_mainpane = animate_sidepane_mainpane1;
    }else if(flag == 2){
        animate_sidepane_mainpane = animate_sidepane_mainpane2;
    }else{
        throw "error flag";
    }
    var sidepane_width, main_width;
    if (current_state == 0) {
        switch (state) {
            case 0 :
            {
                break;
            }
            case 1 :
            {
                sidepane_width = 270;
                main_width = main.width() - 270;
                animate_sidepane_mainpane(main, side, main_width, sidepane_width);
                side.show();
                break;
            }
            case 2:
            {
                sidepane_width = 520;
                main_width = main.width() - 520;
                animate_sidepane_mainpane(main, side, main_width, sidepane_width);
                side.show();
                break;
            }
            default:

        }

    } else if (current_state == 1) {
        switch (state) {
            case 0 :
            {
                sidepane_width = 0;
                main_width = main.width() + 270;
                animate_sidepane_mainpane(main, side, main_width, sidepane_width);
                side.hide();
                break;
            }
            case 1 :
            {
                break;
            }
            case 2:
            {
                sidepane_width = 520;
                main_width = main.width() - 520 + 270;
                animate_sidepane_mainpane(main, side, main_width, sidepane_width);
                side.show();
                break;
            }
            default:

        }

    } else if (current_state == 2) {
        switch (state) {
            case 0 :
            {
                sidepane_width = 0;
                main_width = main.width() + 520;
                animate_sidepane_mainpane(main, side, main_width, sidepane_width);
                side.hide();
                break;
            }
            case 1 :
            {
                sidepane_width = 270;
                main_width = main.width() - 270 + 520;
                animate_sidepane_mainpane(main, side, main_width, sidepane_width);
                break;
            }
            case 2:
            {
                break;
            }
            default:

        }
    }
};
var animate_sidepane_mainpane1 = function(main , side, target_main_width, target_side_width){
    var speed = 50;
    side.animate({width:target_side_width +"px"}, speed);
    main.animate({width:target_main_width + "px", right : target_side_width + "px"},speed);
    var inner_div = jQuery("p1-inner");
    inner_div.animate({width:target_main_width + "px", right : target_side_width + "px"},speed);
};
var animate_sidepane_mainpane2 = function(main , side, target_main_width, target_side_width){
    var speed = 50;
    side.animate({width:target_side_width +"px"}, speed);
    main.animate({width:target_main_width + "px", right : target_side_width + "px"},speed);
};


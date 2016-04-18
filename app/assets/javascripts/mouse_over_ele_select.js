//DOM ISO.v.0.2.8.4.bookmarklet
//bookmarklet for isolating an element on a page.
//two sections:
//section 1:  Mouseover DOM, setup and handle mouse events and show information about element in div.
//            Click to select, Any key to cancel.
//section 2:  Element Isolation with help of XPath.  prompt user for (very) simple XPath expression  e.g., DIV[@id='post-body'].
//            then use XPath to select all element not(ancestor or descendant or self), then delete those elements.
//            also ignore self-or-descendants of head and title.
//currently only a single, simple XPath expression is supported, this code needs more work, but on the right track.
//tools:
//Ruderman's javascript development environment:  https://www.squarefree.com/bookmarklets/webdevel.html#jsenv
//Mielczarek's js to bookmarklet generator:  http://ted.mielczarek.org/code/mozilla/bookmarklet.html
window.ym = window.ym || {};
window.ym.mos = (function () {
    //GLOBALS
    //globals for classMausWork
    var gSelectedElement;	//currently only one selection
    var gHoverElement;		//whatever element the mouse is over
    var gHovering = false;	//mouse is over something
    var gObjArrMW = [];	//global array of classMausWork objects.  for removing event listeners when done selecting.

    //extended
    var infoDiv;		//currently just container for InfoDivHover, might add more here
    var infoDivHover;	//container for hoverText text node.
    var hoverText;		//show information about current element that the mouse is over
    //const EXPERIMENTAL_NEW_CODE=true;	//debugging. new features.

    var gCallback;  // 对prompt返回值进行处理
    //START
    //SetupDOMSelection();

    //(Section 1) Element Selection
    function SetupDOMSelection() {
        {

            //setup event listeners
            //var pathx="//div | //span | //table | //td | //tr | //ul | //ol | //li | //p";
            var pathx = "//div | //span | //table | //th | //td | //tr | //ul | //ol | //li | //p | //iframe";
            var selection = $XPathSelect(pathx);
            for (var element, i = 0; element = selection(i); i++) {
                if (element.tagName.match(/^(div|span|table|td|tr|ul|ol|li|p)$/i))	//redundant check.
                {
                    var m = new classMausWork(element);
                    gObjArrMW.push(m);
                    attachMouseEventListeners(m);
                }
            }
            document.body.addEventListener('mousedown', MiscEvent, false);
            document.body.addEventListener('mouseover', MiscEvent, false);
            document.body.addEventListener('mouseout', MiscEvent, false);
            document.addEventListener('keypress', MiscEvent, false);
        }
        {
            //setup informational div to show which element the mouse is over.
            infoDiv = document.createElement('div');
            var s = infoDiv.style;
            s.position = 'fixed';
            s.top = '0';
            s.right = '0';

            s.display = 'block';
            s.width = 'auto';
            s.padding = '0px';
            document.body.appendChild(infoDiv);
            infoDivHover = document.createElement('div');
            s = infoDivHover.style;
            s.fontWeight = 'bold';
            s.padding = '3px';
            s.Opacity = '0.8';
            s.borderWidth = 'thin';
            s.borderStyle = 'solid';
            s.borderColor = 'white';
            s.backgroundColor = 'black';
            s.color = 'white';

            infoDiv.appendChild(infoDivHover);
            hoverText = document.createTextNode('selecting');
            infoDivHover.appendChild(hoverText);
        }
    }

    function CleanupDOMSelection() {
        for (var m; m = gObjArrMW.pop();) {
            detachMouseEventListeners(m);
        }
        ElementRemove(infoDiv);
        document.body.removeEventListener('mousedown', MiscEvent, false);
        document.body.removeEventListener('mouseover', MiscEvent, false);
        document.body.removeEventListener('mouseout', MiscEvent, false);
        document.removeEventListener('keypress', MiscEvent, false);
    }

    function attachMouseEventListeners(c) {
        //c is object of class classMausWork
        c.element.addEventListener("mouseover", c.mouse_over, false);
        c.element.addEventListener("mouseout", c.mouse_out, false);
        c.element.addEventListener("mousedown", c.mouse_click, false);
    }

    function detachMouseEventListeners(c) {
        //c is object of class classMausWork
        c.resetElementStyle();
        c.element.removeEventListener("mouseover", c.mouse_over, false);
        c.element.removeEventListener("mouseout", c.mouse_out, false);
        c.element.removeEventListener("mousedown", c.mouse_click, false);
    }

    //mouse event  handling class for element, el.
    function classMausWork(element) {
        //store information about the element this object is assigned to handle. element,  original style, etc.
        this.element = element;
        var defaultbgc = element.style.backgroundColor;
        var defaultStyle = element.getAttribute('style');

        this.mouse_over = function (ev) {
            if (gHovering)return;
            if (ev.target != element)return;
            var e = element;		//var e=ev.target;
            var s = e.style;
            s.backgroundColor = 'yellow';
            s.borderWidth = 'thin';
            s.borderColor = 'lime';
            s.borderStyle = 'solid';
            InfoMSG(ElementInfo(e), 'yellow', 'blue', 'yellow');
            gHoverElement = e;		//gHoverElement=ev.target;	//gHoverElement=e;
            gHovering = true;
            ev.stopPropagation();
        };
        this.mouse_out = function (ev) {
            if (ev.target != gHoverElement)return;
            var e = element;		//var e=ev.target;
            e.setAttribute('style', defaultStyle);	// ev.target.setAttribute('style',defaultStyle);
            InfoMSG('-', 'white', 'black', 'white');
            gHoverElement = null;
            gHovering = false;
            //ev.stopPropagation();
        };
        this.mouse_click = function (ev) {
            if (ev.target != gHoverElement)return;
            var e = element;		//var e=ev.target;
            e.setAttribute('style', defaultStyle);  //ev.target.setAttribute('style',defaultStyle);
            gSelectedElement = e;		//gSelectedElement=ev.target;		//=ev.target;
            ev.stopPropagation();
            CleanupDOMSelection();
            gHoverElement = null;
            gHovering = false;
            ElementSelected(gSelectedElement);	//finished selecting, cleanup then move to next part, element isolation.
        };
        this.resetElementStyle = function () {
            if (gHovering && gHoverElement && gHoverElement == this.element) {
                this.element.setAttribute('style', defaultStyle);
            }
        };
    }

    function MiscEvent(ev)		//keypress, and mouseover/mouseout/mousedown event on body.  cancel selecting.
    {
        if (ev.type == 'mouseout') {
            InfoMSG('-', 'white', 'black', 'white');
        }
        else if (ev.type == 'mouseover') {
            InfoMSG('cancel', 'yellow', 'red', 'yellow');
        }
        else //keypress on document or mousedown on body, cancel ops.
        {
            CleanupDOMSelection();
        }
    }

    function InfoMSG(text, color, bgcolor, border) {

        var s = infoDivHover.style;
        //var s=infoDiv.style;
        if (color)s.color = color;
        if (bgcolor)s.backgroundColor = bgcolor;
        if (border)s.borderColor = border;
        if (text)hoverText.data = text;
    }


    //(Section 2) Element Isolation
    function ElementSelected(element)	//finished selecting element.  setup string to prompt user.
    {
        //PromptUserXpath(ElementInfo(element));
        //PromptUserXpath(getXPath(element));
        var xpath = getXPath(element);
        var html = element.innerHTML;
        gCallback(xpath, html);
    }


    function PromptUserXpath(xpath)		//prompt user, isolate element.
    {
        var userpath = prompt("XPath of element : ", xpath);
        if (userpath && userpath.length > 0) {
            console.log(xpath);
            try {
                window.ym.mos.SetupDOMSelection();
                if (gCallback){
                    gCallback(userpath);
                }
            }
            catch (err) {
                console.log(err);
            }
        }
    }

    //(under construction) work on this function
    //currently only simple expressions are converted.
    function TransformToNonIsolatePath(u) {
        var i = "";
        i += "//*[count(./descendant-or-self::";
        i += u;
        i += ")=0][count(./ancestor-or-self::";
        i += u;
        i += ")=0]";
        i += "[count(./ancestor-or-self::head)=0][count(./ancestor-or-self::title)=0]";
        return i;
    }


    //support
    function $XPathSelect(p, context) {
        if (!context) context = document;
        var i, arr = [], xpr = document.evaluate(p, context, null, XPathResult.UNORDERED_NODE_SNAPSHOT_TYPE, null);
        return function (x) {
            return xpr.snapshotItem(x);
        };	//closure.  wooot!  returns function-type array of elements (usually elements, or something else depending on the xpath expression).
    }

    function ElementRemove(e) {
        e.parentNode.removeChild(e);
    }

    // get from http://stackoverflow.com/questions/3454526/how-to-calculate-the-xpath-position-of-an-element-using-javascript
    function getXPath( element )
    {
        var xpath = '';
        for ( ; element && element.nodeType == 1; element = element.parentNode )
        {
            var id = $(element.parentNode).children(element.tagName).index(element) + 1;
            id > 1 ? (id = '[' + id + ']') : (id = '');
            xpath = '/' + element.tagName.toLowerCase() + id + xpath;
        }
        return xpath;
    }

    function getHTML(who, deep)
    {
        if(!who || !who.tagName) return '';
        var txt, ax, el= document.createElement("div");
        el.appendChild(who.cloneNode(false));
        txt= el.innerHTML;
        if(deep){
            ax= txt.indexOf('>')+1;
            txt= txt.substring(0, ax)+who.innerHTML+ txt.substring(ax);
        }
        el= null;
        return txt;
    }

    function ElementInfo(element) {
        var txt = '';
        txt = element.tagName;
        txt = attrib(txt, element, 'id');
        txt = attrib(txt, element, 'class');
        return txt;

        function attrib(t, e, a) {
            if (e.hasAttribute(a)) {
                t += "[@" + a + "='" + e.getAttribute(a) + "']";
            }
            return t;
        }

    }

    function SetCallback(callback){
        gCallback = callback;
    }

    return {
        SetupDOMSelection : SetupDOMSelection,
        CleanupDOMSelection : CleanupDOMSelection,
        SetCallback :SetCallback
    }

})();
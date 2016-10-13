/**
 * Created by ym on 2016/10/12 0012.
 */

(function () {

     JSON.json_escape = function (s) {
        var result = "";
        var n = _.size(s);
        var i = 0;
        while (i < n) {
            c = s[i];
            if (c === "\"") {
                result += "\\\"";
            } else if (c === "\\") {
                result += "\\\\";
            } else if (c === "\b") {
                result += "\\b";
            } else if (c === "\f") {
                result += "\\f";
            } else if (c === "\n") {
                result += "\\n";
            } else if (c === "\r") {
                result += "\\r";
            } else if (c === "\t") {
                result += "\\t";
            } else {
                result += c;
            }
            i += 1;
        }
        return result;
    };

    JSON.json_unescape = function (s) {
        var result = "";
        var n = _.size(s);
        var i = 0;
        while (i < n) {
            if (s[i] === "\\") {
                if (s[i + 1] === "\"") {
                    result += "\"";
                } else if (s[i + 1] === "b") {
                    result += "\b";
                } else if (s[i + 1] === "f") {
                    result += "\f";
                } else if (s[i + 1] === "n") {
                    result += "\n";
                } else if (s[i + 1] === "r") {
                    result += "\r";
                } else if (s[i + 1] === "t") {
                    result += "\t";
                }
                i += 2;
            } else {
                result += s[i];
                i += 1;
            }
        }
        return result;
    };



})();
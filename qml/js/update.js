/*
 * Foursquare API bindings
 */

var UPDATE_BASE = "http://thecust.net/nelisquare/";

function getUpdateInfo(updatetype, callback) {
    var platform = configuration.platform;
    var url = UPDATE_BASE + platform + "/build." + updatetype

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
            var status = doc.status;
            if(status!=200) {
                console.log("Auto-update returned " + status + " " + doc.statusText);
            }
        } else if (doc.readyState == XMLHttpRequest.DONE && doc.status == 200) {
            var contentType = doc.getResponseHeader("Content-Type");
            var data = doc.responseText.split(";");
            var build = data[0].split(" = ")[1].replace(/(\r\n|\n|\r|\"|\')/gm,"");
            var version = data[1].split(" = ")[1].replace(/(\r\n|\n|\r|\"|\')/gm,"");
            var changelog = "";
            if (data[2] !== undefined) {
                changelog = data[2].split(" = ")[1].replace(/(\r\n|\n|\r|\"|\')/gm,"");
                changelog = changelog.replace(/  - /g,'<br> - ');
            }
            var url = UPDATE_BASE + platform + "/nelisquare";
            if (updatetype == "developer") {
                url += "-devel.deb";
            } else if (updatetype == "alpha") {
                url += "-alpha.deb";
            } else {
                url += "_" + version + "_armel.deb"
            }
            callback(build,version,changelog,url);
        }
    }

    doc.open("GET", url);
    doc.send();
}

/*
 * General utility functions
 */

.pragma library

api.log("loading utils...");

function submitDebugInfo(content, callback) {
    var data = encodeURIComponent(JSON.stringify(content));
    api.debug(function(){return "SUBMIT DEBUG: " + data});

    var url = api.DEBUG_URL + data;

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
            var status = doc.status;
            if(status!=200) {
                console.log("Routes returned " + status + " " + doc.statusText);
                callback(false, doc.statusText);
            }
        } else if (doc.readyState == XMLHttpRequest.DONE && doc.status == 200) {
            var contentType = doc.getResponseHeader("Content-Type");
            var result = JSON.parse(doc.responseText);
            callback(result.status,result.message);
        }
    }

    doc.open("GET", url);
    doc.send();
}

function getRoutePoints(pointA,pointB,callback) {
    //dirflg =
    //d - driver
    //w - walk
    var url = "http://maps.google.com/maps/nav?output=js&dirflg=d&hl=en&mapclient=jsapi&q=from%3A%20"
        + pointA.lat + "%2C" + pointA.lng
        + "%20to%3A%20"
        + pointB.lat + "%2C" + pointB.lng;

    //console.log("ROUTE URL: " + url);

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
            var status = doc.status;
            if(status!=200) {
                console.log("Routes returned " + status + " " + doc.statusText);
            }
        } else if (doc.readyState == XMLHttpRequest.DONE && doc.status == 200) {
            var contentType = doc.getResponseHeader("Content-Type");
            var data = JSON.parse(doc.responseText);

            callback(data);
        }
    }

    doc.open("GET", url);
    doc.send();
}

function getCurrentTime() {
    return Math.ceil((new Date()).getTime()/1000);
}

function isXmas() {
    var date = new Date();
    if (date.getTime() > new Date(2012, 11, 22).getTime()
            && date.getTime() < new Date(2013, 0 ,5).getTime()) {
        return true;
    }
    return false
}

function makeTime(date) {
    var pretty = prettyDate(new Date(parseInt(date,10)*1000));
    return pretty;
}

function prettyDate(date){
    try {
        var diff = (((new Date()).getTime() - date.getTime()) / 1000);
        var day_diff = Math.floor(diff / 86400);

        if ( isNaN(day_diff) || day_diff >= 31 ) {
            //console.log("Days: " + day_diff);
            return date.toLocaleDateString();//"some time ago";
        } else if (day_diff < 0) {
            //console.log("day_diff: " + day_diff);
            return "just now";
        }

        return day_diff == 0 && (
                    diff < 60 && "just now" ||
                    diff < 120 && "1 minute ago" ||
                    diff < 3600 && Math.floor( diff / 60 ) + " min ago" ||
                    diff < 7200 && "1 hour ago" ||
                    diff < /*86400*/28800 && Math.floor( diff / 3600 ) + " hours ago") ||
                date.toLocaleDateString();
                /*day_diff == 1 && "Yesterday" ||
                day_diff < 7 && day_diff + " days ago" ||
                day_diff < 31 && Math.ceil( day_diff / 7 ) + " weeks ago";
        day_diff >= 31 && Math.ceil( day_diff / 30 ) + " months ago";*/
    } catch(err) {
        console.log("Error: " + err);
        return "some time ago";
    }
}

// 2011-01-24T18:48:00Z
function parseDate(stamp)
{
    try {
        //console.log("stamp: " + stamp);
        var parts = stamp.split("T");
        var day;
        var time;
        var hours;
        var minutes;
        var seconds = 0;
        var year;
        var month;

        var dates = parts[0].split("-");
        year = parseInt(dates[0]);
        month = parseInt(dates[1])-1;
        day = parseInt(dates[2]);

        var times = parts[1].split(":");
        hours = parseInt(times[0]);
        minutes = parseInt(times[1]);

        var dt = new Date();
        dt.setUTCDate(day);
        dt.setYear(year);
        dt.setUTCMonth(month);
        dt.setUTCHours(hours);
        dt.setUTCMinutes(minutes);
        dt.setUTCSeconds(seconds);

        //console.log("day: " + day + " year: " + year + " month " + month + " hour " + hours);

        return dt;
    } catch(err) {
        //console.log("Error while parsing date: " + err);
        return new Date();
    }
}



function getRoutePoints(pointA,pointB,callback) {
    //dirflg =
    //d - driver
    //w - walk
    waiting.show();
    var url = "http://maps.google.com/maps/nav?output=js&dirflg=w&hl=en&mapclient=jsapi&q=from%3A%20"
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

            waiting.hide();
            callback(data);
        }
    }

    doc.open("GET", url);
    doc.send();
}

/*
function drawMap(settings,route) {
    var url = "";

    //DBG
    if (window.mapprovider == "google") {
        url = "http://maps.googleapis.com/maps/api/staticmap?"+
                "zoom="+settings.zoom+"&size="+settings.width+"x"+settings.height+"&maptype=roadmap"+
                "&center="+settings.center.lat+","+settings.center.lng;
        if (settings.user.lng!==undefined) {
            url += "&markers=color:blue|label:U|"+settings.user.lat+","+settings.user.lng;
        }
        url += "&markers=color:red|"+settings.lat+","+settings.lng;
        if (route!==undefined) {
            url += "&path=color:0x0000ff|weight:5";
            route.Directions.Routes[0].Steps.forEach(function(step) {
                url += "|" + step.Point.coordinates[1] + "," + step.Point.coordinates[0];
            });
        }
        url += "&sensor=false";
    } else if (window.mapprovider == "openstreetmap") {
        //NOTE: lng and lat inverted at API
        url = "http://pafciu17.dev.openstreetmap.org/?module=map"+
                "&zoom="+settings.zoom+"&type=mapnik&width="+settings.width+"&height="+settings.height+
                "&center="+settings.center.lng+","+settings.center.lat+
                "&points="+settings.lng+","+settings.lat;// + ",pointImagePattern:sight_point";
        if (settings.user.lng!==undefined) {
            url += ";"+settings.user.lng+","+settings.user.lat + ",pointImagePattern:redU";
        }
        if (route!==undefined) {
            url += "&paths=";
            route.Directions.Routes[0].Steps.forEach(function(step) {
                url += step.Point.coordinates[0] + "," + step.Point.coordinates[1] + ",";
            });
            url += "thickness:5,transparency:80;-90,40,-80,40,color:0:255:0";
        }
    }
    //console.log("MAP URL: " + url);
    return url;
}
*/
/*
function createMapUrl(map, settings) {
    //console.log("MAP SETTINGS: " + JSON.stringify(settings));
    if (settings.user.lng!==undefined) {
        if (map.route !== undefined) {
            map.venueMapUrl = drawMap(settings,map.route);
        } else {
            waiting.show();
            getRoutePoints(settings.user,settings,
                function(route){
                    waiting.hide();
                    map.route = route;
                    map.venueMapUrl = drawMap(settings,route);
                });
        }
    } else {
        map.venueMapUrl = drawMap(settings);
    }
}*/

function getCurrentTime() {
    return (new Date()).getTime()/1000;
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
                    diff < 86400 && Math.floor( diff / 3600 ) + " hours ago") ||
                day_diff == 1 && "Yesterday" ||
                day_diff < 7 && day_diff + " days ago" ||
                day_diff < 31 && Math.ceil( day_diff / 7 ) + " weeks ago";
        day_diff >= 31 && Math.ceil( day_diff / 30 ) + " months ago";
    } catch(err) {
        //console.log("Error: " + err);
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

function stringToBytes ( str ) {
  var ch, st, re = [];
  for (var i = 0; i < str.length; i++ ) {
    ch = str.charCodeAt(i);  // get char
    st = [];                 // set up "stack"
    do {
      st.push( ch & 0xFF );  // push byte to stack
      ch = ch >> 8;          // shift value down by 1 byte
    }
    while ( ch );
    // add stack contents to result
    // done because chars have "wrong" endianness
    re = re.concat( st.reverse() );
  }
  // return an array of bytes
  return re;
}

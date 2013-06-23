/*
 * Foursquare API bindings
 */

.pragma library

api.log("loading api-core...");

api.MAX_NEARBY_DISTANCE = 100000; //100km
api.MAX_FEED_SIZE = 40;

api.DEBUG_URL = "http://thecust.net/debug-nelisquare.php?content="

var API_VERSION = "20120910";
/*
//Nelisquare V1
var CLIENT_ID = "4IFSW3ZXR4BRBXT3IIZMB13YPNGSIOK4ANEM0PP3T2CQQFWI";
var CALLBACK_URL = "http://nelisquare.substanceofcode.com/callback.php";
*/

//Nelisquare V2
var CLIENT_ID = "SF1OZJLHW0EIP5IKCSAQTNCSYECFJ3QZMCYO31BZMLRVF3WH";
var CALLBACK_URL = "https://nelisquare.herokuapp.com/authcallback";

var AUTHENTICATE_URL = "https://foursquare.com/oauth2/authenticate" +
    "?client_id=" + CLIENT_ID +
    "&response_type=token" +
    "&display=touch" +
    "&v=" + API_VERSION +
    "&redirect_uri=" + CALLBACK_URL;

var API_URL = "https://api.foursquare.com/v2/";



var defaultVenueIcon = {"prefix":"https://foursquare.com/img/categories_v2/none_","suffix":".png"}

/** Parse parameter from given URL */
function parseAuth(data, parameterName) {
    var parameterIndex = data.indexOf(parameterName + "=");
    if(parameterIndex<0) {
        // We didn't find parameter
        return undefined;
    }
    var equalIndex = data.indexOf("=", parameterIndex);
    if(equalIndex<0) {
        return undefined;
    }

    //var lineBreakIndex = data.indexOf("\n", equalIndex+1)

    var value = "";
    value = data.substring(equalIndex+1);
    return value;
}


api.request = function(method, url, page, callback) {
    api.log(method + " " + url.replace(/oauth\_token\=([A-Z0-9]+).*\&v\=.*/gm,""));
    url = API_URL + url;

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
            var status = doc.status;
            if(status!=200) {
                page.show_error("API returned " + status + " " + doc.statusText);
            }
        } else if (doc.readyState == XMLHttpRequest.DONE) {
            if (doc.status == 200) {
                var data;
                var contentType = doc.getResponseHeader("Content-Type");
                var ratelimit = {
                    "limit": doc.getResponseHeader("x-ratelimit-limit"),
                    "remaining": doc.getResponseHeader("x-ratelimit-remaining")
                }
                if (ratelimit.limit !== "0")
                    page.updateRateLimit(ratelimit);
                data = doc.responseText;
                callback(data,page);
            } else {
                if (doc.status == 0) {
                    page.show_error("Network connection error");
                } else {
                    page.show_error("General error: " + doc.status + "<br>" + doc.statusText);
                }
            }
        }
    }

    doc.open(method, url);
    doc.setRequestHeader("Accept-Language",api.locale);
    doc.send();
}

api.process = function(response, page) {
    var data = eval("[" + response + "]")[0];
    var meta = data.meta;
    if (meta.code != 200) {
        if (page!==undefined) {
            page.show_error("<span>API Error: " + meta.code
                            + "<br/>Error type: " + meta.errorType
                            + "<br/>" + meta.errorDetail + "<br/></span>");
        }
    }
    //console.log("DATA: " + JSON.stringify(data));
    var notifications = data.notifications;
    if (notifications!==undefined){
        //console.log("NOTIFICATIONS: " + JSON.stringify(notifications));
        notifications.forEach(function(notification) {
                if (parse(notification.type) == "notificationTray") {
                    if (page !== undefined)
                        page.updateNotificationCount(notification.item.unreadCount);
                }
            });
    }
    return data.response;
}

function doNothing(response,page) {
    // Nothing...
    api.process(response, page);
}

function setPositionSource(source) {
    api.debug(function(){return "setting position source"});
    api.positionSource = source;
}

function setLocale(locale) {
    api.locale = locale;
}

function getLocationParameter() {
    var lat = api.positionSource.position.coordinate.latitude;
    var lon = api.positionSource.position.coordinate.longitude;
    var result = "ll=" + lat + "," + lon;
    api.debug(function(){return "location: " + result});
    return result;
}

function setAccessToken(token) {
    //api.debug(function(){return"SET TOKEN: " + token});
    api.accessToken = token;
}
function getAccessTokenParameter() {
    var token = api.accessToken;
    //api.debug(function(){return"GET TOKEN: " + token});
    return "oauth_token=" + token + "&v=" + API_VERSION;
}

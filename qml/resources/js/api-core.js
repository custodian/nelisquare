/*
 * Foursquare API bindings
 */
//.pragma library

Qt.include("utils.js")

var MAX_NEARBY_DISTANCE = 100000; //100km

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

var defaultVenueIcon = {"prefix":"https://foursquare.com/img/categories_v2/none_","suffix":".png"}

/** Parse parameter from given URL */
function parseAuth(data, parameterName) {
    var parameterIndex = data.indexOf(parameterName + "=");
    if(parameterIndex<0) {
        // We didn't find parameter
        //console.log("Didn't find Auth");
        //showError("Didn't find Auth");
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


function doWebRequest(method, url, params, callback) {
    console.log(method + " " + url.replace(/oauth\_token\=([A-Z0-9]+).*\&v\=.*/gm,""));
    url = "https://api.foursquare.com/v2/" + url;

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
            var status = doc.status;
            if(status!=200) {
                showError("API returned " + status + " " + doc.statusText);
            }
        } else if (doc.readyState == XMLHttpRequest.DONE) {
            if (doc.status == 200) {
                var data;
                var contentType = doc.getResponseHeader("Content-Type");
                data = doc.responseText;
                callback(data,params);
            } else {
                if (doc.status == 0) {
                    showError("Network connection error");
                } else {
                    showError("General error: " + doc.status);
                }
            }
        }
    }

    doc.open(method, url);
    doc.send();
}

function processResponse(response) {
    var data = eval("[" + response + "]")[0];
    var meta = data.meta;
    if (meta.code != 200) {
        showError("ErrorType: " + meta.errorType + "\n" + meta.errorDetail);
    }
    var notifications = data.notifications;
    if (notifications!==undefined){
        //console.log("NOTIFICATIONS: " + JSON.stringify(notifications));
        notifications.forEach(function(notification) {
                if (parse(notification.type) == "notificationTray") {
                    //TODO: change it somehow to make library
                    window.updateNotificationCount(notification.item.unreadCount);
                }
            });
    }
    return data.response;
}

function doNothing(response,page) {
    // Nothing...
    processResponse(response);
}

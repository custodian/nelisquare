/*
 * Foursquare API bindings
 */
.pragma library

console.log("loading api...");

function ApiObject() {
    this.name = "4SQ JS API for QML";
    this.debuglevel = 0; //0 = log, 1 = debug
    this.log = function(msg) {
        if (this.debuglevel >= 0) {
            //console.log("LOG: " + msg)
            console.log(msg)
        }
    }
    this.debug = function(callback) {
        if (this.debuglevel > 0 && api.debugenabled) {
            console.debug(callback());
        }
    }
}
var api = new ApiObject();
api.accessToken = "";
api.inverted = false; //TODO: have to move this somewhere to make common function with icons work
api.locale = "en";

Qt.include("private.js")
Qt.include("debug.js")

Qt.include("api-core.js")
Qt.include("api-common.js")

Qt.include("api-feed.js")
Qt.include("api-checkin.js")
Qt.include("api-notifications.js")
Qt.include("api-photo.js")
Qt.include("api-tip.js")
Qt.include("api-user.js")
Qt.include("api-venue.js")

Qt.include("utils.js")

console.log("api loaded.");

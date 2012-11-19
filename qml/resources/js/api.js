/*
 * Foursquare API bindings
 */
Qt.include("api-core.js")
Qt.include("api-common.js")

function getLocationParameter() {
    var lat = positionSource.position.coordinate.latitude;
    var lon = positionSource.position.coordinate.longitude;
    return "ll=" + lat + "," + lon;
}

function setAccessToken(token) {
    //console.log("SET TOKEN: " + token);
    configuration.accessToken = token;
}
function getAccessTokenParameter() {
    var token = configuration.accessToken;
    //console.log("GET TOKEN: " + token);
    return "oauth_token=" + token + "&v=" + API_VERSION;
}

function showError(msg) {
    waiting.hide();
    console.log("Error: "+ msg);
    //error.state = "shown";
    //error.reason = msg;
    notificationDialog.message += msg + "<br/>"
    notificationDialog.state = "shown";
}

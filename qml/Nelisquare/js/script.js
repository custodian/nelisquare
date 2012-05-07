
var CLIENT_ID = "4IFSW3ZXR4BRBXT3IIZMB13YPNGSIOK4ANEM0PP3T2CQQFWI";
var CALLBACK_URL = "http://nelisquare.substanceofcode.com/callback.php";
var AUTHENTICATE_URL = "https://foursquare.com/oauth2/authenticate" +
    "?client_id=" + CLIENT_ID +
    "&response_type=token" +
    "&display=touch" +
    "&redirect_uri=" + CALLBACK_URL;

var accessToken = "";

function doWebRequest(method, url, params, callback) {
    var doc = new XMLHttpRequest();
    console.log(method + " " + url);

    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
            var status = doc.status;
            if(status!=200) {
                showError("API returned " + status + " " + doc.statusText);
            }
        } else if (doc.readyState == XMLHttpRequest.DONE) {
            var data;
            var contentType = doc.getResponseHeader("Content-Type");
            data = doc.responseText;
            callback(data);
        }
    }

    doc.open(method, url);
    if(params.length>0) {
        //console.log("Sending: " + params);
        doc.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        doc.setRequestHeader("Content-Length", String(params.length));
        doc.send(params);
    } else {
        doc.send();
    }
}

function setAccessToken(token) {
    accessToken = token;
}

/** Parse parameter from given URL */
function parseAuth(data, parameterName) {
    var parameterIndex = data.indexOf(parameterName + "=");
    if(parameterIndex<0) {
        // We didn't find parameter
        console.log("Didn't find Auth");
        addError("Didn't find Auth");
        return "";
    }
    var equalIndex = data.indexOf("=", parameterIndex);
    if(equalIndex<0) {
        return "";
    }

    var lineBreakIndex = data.indexOf("\n", equalIndex+1)

    var value = "";
    value = data.substring(equalIndex+1, lineBreakIndex);
    return value;
}

function getAccessTokenParameter() {
    return "oauth_token=" + accessToken;
}

function loadFriends() {
    var url = "https://api.foursquare.com/v2/checkins/recent?" + getAccessTokenParameter();
    doWebRequest("GET", url, "", parseFriends);
    waiting.state = "shown";
}

function loadNearbyFriends() {
    var url = "https://api.foursquare.com/v2/checkins/recent?" +
        getLocationParameter() + "&" + getAccessTokenParameter();
    doWebRequest("GET", url, "", parseFriends);
    waiting.state = "shown";
}

function parseFriends(response) {
    //console.log("Response: " + response);
    var data = eval("[" + response + "]")[0].response;
    var count = 0;
    friendsModel.clear();
    for(var i in data.recent) {
        var checkin = data.recent[i];
        var userName = checkin.user.firstName + " " + checkin.user.lastName[0] + ".";
        var createdAt = new Date(parseInt(checkin.createdAt,10)*1000);
        var createdAgo = prettyDate(createdAt);
        console.log("User checkin: " + userName);
        var venueName = "";
        var venueID = "";
        var venueAddress = "";
        var venueCity = "";
        var venueCheckinsCount = "";
        var venueUsersCount = "";
        if(typeof(checkin.venue)!="undefined") {
            venueName = checkin.venue.name;
            venueID = checkin.venue.id;
            venueAddress = parse(checkin.venue.location.address);
            venueCity = parse(checkin.venue.location.city);
            venueCheckinsCount = checkin.venue.stats.checkinsCount;
            venueUsersCount = checkin.venue.stats.usersCount;
        }

        friendsModel.append({
                           "id": checkin.id,
                           "shout": parse(checkin.shout),
                           "user": userName,
                           "photo": checkin.user.photo,
                           "venueName": venueName,
                           "venueID": venueID,
                           "createdAt": createdAgo,
                           "venueAddress": venueAddress,
                           "venueCity": venueCity,
                           "venueCheckinsCount": venueCheckinsCount,
                           "venueUsersCount": venueUsersCount
        });
        count++;
    }
    waiting.state = "hidden";
    if(count==0) {
        //showDone("No visible albums");
    }
}

function getLocationParameter() {
    var lat = positionSource.position.coordinate.latitude;
    var lon = positionSource.position.coordinate.longitude;
    return "ll=" + lat + "," + lon;
}

function loadPlaces(query) {
    var url = "https://api.foursquare.com/v2/venues/search?" +
        getLocationParameter();
    if(query!=null && query.length>0) {
        url += "&query=" + query;
    }
    url += "&" + getAccessTokenParameter();
    doWebRequest("GET", url, "", parsePlaces);
    waiting.state = "shown";
}

function parse(item) {
    if(typeof(item)!="undefined") {
        return item;
    } else {
        return "";
    }
}

function parsePlaces(response) {
    //console.log("Response: " + response);
    var data = eval("[" + response + "]")[0].response;
    var count = 0;
    placesModel.clear();
    waiting.state = "hidden";
    for(var i in data.groups[0].items) {
        var place = data.groups[0].items[i];
        var icon = "";
        if(place.categories!=null && typeof(place.categories[0])!="undefined") {
            icon = place.categories[0].icon;
        }
        placesModel.append({
                           "id": place.id,
                           "name": place.name,
                           "todoComment": "",
                           "distance": place.location.distance,
                           "address": parse(place.location.address),
                           "city": parse(place.location.city),
                           "lat": place.location.lat,
                           "lng": place.location.lng,
                           "hereNow": place.hereNow.count,
                           "icon": icon,
                           "venueCheckinsCount": place.stats.checkinsCount,
                           "venueUsersCount": place.stats.usersCount
        });
        count++;
    }
    if(count==0) {
        //showDone("No visible albums");
    }
}

function loadVenue(venueID) {
    var url = "https://api.foursquare.com/v2/venues/" + venueID + "?" + getAccessTokenParameter();
    waiting.state = "shown";
    placeDialog.venueID = venueID;
    placeDialog.venueName = "";
    placeDialog.venueAddress = "";
    placeDialog.venueCity = "";
    placeDialog.venueMajor = "";
    doWebRequest("GET", url, "", parseVenue);
}

function parseVenue(response) {
    //console.log("VENUE: " + response);
    var data = eval("[" + response + "]")[0].response;
    waiting.state = "hidden";
    var venue = data.venue;
    var icon = "";
    if(venue.categories!=null && typeof(venue.categories[0])!="undefined") {
        icon = venue.categories[0].icon;
    }
    placeDialog.venueID = venue.id;
    placeDialog.venueName = venue.name;
    placeDialog.venueAddress = parse(venue.location.address);
    placeDialog.venueCity = parse(venue.location.city);
    placeDialog.venueMajor = "";
    if(typeof(venue.mayor)!="undefined") {
        placeDialog.venueMajor = venue.mayor.user.firstName + " " + venue.mayor.user.lastName[0] + ".";
        placeDialog.venueMajorPhoto = venue.mayor.user.photo;
    }
    // Parse venue tips
    tipsModel.clear();
    console.log("tips: " + venue.tips.count);
    if(venue.tips.count>0) {
        var tipCounter = 0;
        for(var i in venue.tips.groups[0].items) {
            var tip = venue.tips.groups[0].items[i];
            console.log("tip: " + tip);
            var createdAt = new Date(parseInt(tip.createdAt,10)*1000);
            var createdAgo = prettyDate(createdAt);
            tipsModel.append({
                             "tipID": tip.id,
                             "tipText": tip.text,
                             "tipAge": "Added " + createdAgo
            });
            tipCounter++;
            if(tipCounter>0) {
                break;
            }
        }
    }
}

function addTip(venueID, text) {
    waiting.state = "shown";
    var url = "https://api.foursquare.com/v2/tips/add?";
    url += "venueId=" + venueID + "&";
    url += "text=" + encodeURIComponent(text) + "&";
    url += getAccessTokenParameter();
    doWebRequest("POST", url, "", showDone);
}

function markVenueToDo(venueID, text) {
    var url = "https://api.foursquare.com/v2/venues/" + venueID + "/marktodo?";
    if(text!="" && text.length>0) {
        url += "text=" + encodeURIComponent(text) + "&";
    }
    url += getAccessTokenParameter();
    doWebRequest("POST", url, "", showDone);
}

function loadMyCheckins() {
    var url = "";
}

function checkin(venueID, comment, friends, facebook, twitter) {
    var url = "https://api.foursquare.com/v2/checkins/add?";
    if(venueID!=null) {
        url += "venueId=" + venueID;
    }
    if(typeof(comment)!="undefined" && comment!=null && comment.length>0) {
        url += "&shout=" + encodeURIComponent(comment);
    }
    var broadcast = "private";
    if(friends) {
        broadcast = "public"
    }
    if(facebook) {
        broadcast += ",facebook";
    }
    if(twitter) {
        broadcast += ",twitter";
    }
    url += "&broadcast=" + broadcast;
    url += "&" + getLocationParameter();
    url += "&" + getAccessTokenParameter();

    //console.log("Checkin URL: " + url);
    waiting.state = "shown";
    doWebRequest("POST", url, "", parseCheckin);
}

function parseCheckin(response) {
    //console.log("CHECKIN ===== " + response);
    waiting.state = "hidden";
    var data = eval("[" + response + "]")[0];
    notification.message = "<span>";
    for(var i in data.notifications) {
        var noti = data.notifications[i];
        if(typeof(noti.item.message)!="undefined") {
            if(notification.message.length>6) {
                notification.message += "<br/><br/>"
            }
            notification.message += noti.item.message;
        }
    }
    notification.message += "</span>";
    notification.state = "shown";
}

function loadLeaderBoard() {
    var url = "https://api.foursquare.com/v2/users/leaderboard?" + getAccessTokenParameter();
    waiting.state = "shown";
    doWebRequest("GET", url, "", parseLeaderBoard);
}

function parseLeaderBoard(response) {
    waiting.state = "hidden";
    var data = eval("[" + response + "]")[0];
    boardModel.clear();
    for(var i in data.response.leaderboard.items) {
        var ranking = data.response.leaderboard.items[i];
        boardModel.append({
                           "id": ranking.user.id,
                           "name": ranking.user.firstName + " " + ranking.user.lastName,
                           "photo": ranking.user.photo,
                           "recent": ranking.scores.recent,
                           "max": ranking.scores.max,
                           "checkinsCount": ranking.scores.checkinsCount,
                           "rank": ranking.rank
        });
        if(ranking.user.relationship=="self") {
            leaderBoard.rank = ranking.rank;
        }
    }
}

function loadToDo() {
    var url = "https://api.foursquare.com/v2/users/self/todos?" +
        getLocationParameter() + "&" +
        getAccessTokenParameter();
    waiting.state = "shown";
    doWebRequest("GET", url, "", parseToDo);
}

function parseToDo(response) {
    waiting.state = "hidden";
    var data = eval("[" + response + "]")[0];
    placesModel.clear();
    for(var i in data.response.todos.items) {
        var todo = data.response.todos.items[i];
        var place = todo.tip.venue;
        var icon = "";
        if(place.categories!=null && typeof(place.categories[0])!="undefined") {
            icon = place.categories[0].icon;
        }
        placesModel.append({
                           "id": place.id,
                           "name": place.name,
                           "todoComment": todo.tip.text,
                           "distance": place.location.distance,
                           "address": parse(place.location.address),
                           "city": parse(place.location.city),
                           "lat": place.location.lat,
                           "lng": place.location.lng,
                           "hereNow": "",
                           "icon": icon,
                           "venueCheckinsCount": place.stats.checkinsCount,
                           "venueUsersCount": place.stats.usersCount
        });
    }
}

function loadUser(user) {
    var url = "https://api.foursquare.com/v2/users/" + user + "?" + getAccessTokenParameter();
    waiting.state = "shown";
    doWebRequest("GET", url, "", parseUser);
}

function parseUser(response) {
    console.log("USER: " + response);
    var data = eval("[" + response + "]")[0].response;
    waiting.state = "hidden";
    var user = data.user;
    userDetails.userName = user.firstName + " " + user.lastName;
    userDetails.userPhoto = user.photo;
    userDetails.userBadgesCount = user.badges.count;
    userDetails.userCheckinsCount = user.checkins.count;
    userDetails.userFriendsCount = user.friends.count;
    userDetails.userID = user.id;
    userDetails.userMayorshipsCount = user.mayorships.count;
}

function showError(msg) {
    waiting.state = "hidden";
    console.log("Error: "+ msg);
    error.state = "shown";
    error.reason = msg;
}

function removeLinks(original) {
    var txt = original;
    txt = txt.replace(/<a /g, "<span ");
    txt = txt.replace(/<\/a>/g, "</span>");
    return txt;
}

function parseToken(data) {
    sid = parseAuth(data, "Auth");
    //console.log("Auth=" + sid);
    sidToken = parseAuth(data, "SID");
    //console.log("SID=" + sidToken);
    logo.state = "hidden"; //.visible = false;
    if(sid.length>0) {
        navigation.state = "menu";
        waiting.state = "hidden";
        //loadUnreadNews();
    } else {
        addError("Couldn't parse SID");
        waiting.state = "hidden";
    }
}

function getNodeValue(node, name) {
    var nodeValue = "";
    for(var i=0; i<node.childNodes.length; i++) {
        var nodeName = node.childNodes[i].nodeName;
        if(nodeName==name) {
            nodeValue = node.childNodes[i].firstChild.nodeValue;
        }
    }
    return nodeValue;
}

function getToken() {
    var url = "http://www.google.com/reader/api/0/token";
    doWebRequest("GET", url, "", parseAccessToken);
}


function showDone(data) {
    console.log("DONE: " + data);
    if(waiting.state!="shown") {
        return;
    }
    waiting.state = "hidden";
    done.status = "";
    if(typeof(data)!=undefined && data!=null) {
        if(action=="read") {
            done.status = "Marked as read " + data;
        } else if(action=="unread") {
            done.status = "Marked as unread " + data;
        } else {
            done.status = "" + data;
        }
    }
    done.state = "shown";
}

function doNothing(data) {
    // Nothing...
}

function prettyDate(date){
    try {
        var diff = (((new Date()).getTime() - date.getTime()) / 1000);
        var day_diff = Math.floor(diff / 86400);

        if ( isNaN(day_diff) || day_diff >= 31 ) {
            //console.log("Days: " + day_diff);
            return "some time ago";
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
        console.log("Error while parsing date: " + err);
        return new Date();
    }
}

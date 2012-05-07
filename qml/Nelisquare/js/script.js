
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

function loadFriendsCheckins() {
    var url = "https://api.foursquare.com/v2/checkins/recent?" + getAccessTokenParameter();
    doWebRequest("GET", url, "", parseFriendsCheckins);
    waiting.state = "shown";
}

function loadNearbyFriendsCheckins() {
    var url = "https://api.foursquare.com/v2/checkins/recent?" +
        getLocationParameter() + "&" + getAccessTokenParameter();
    doWebRequest("GET", url, "", parseFriendsCheckins);
    waiting.state = "shown";
}

function parseFriendsCheckins(response) {
    var data = eval("[" + response + "]")[0].response;
    var count = 0;
    friendsCheckinsModel.clear();
    for(var i in data.recent) {
        var checkin = data.recent[i];
        //console.log("FRIEND CHECKIN: " + JSON.stringify(checkin));
        var userName = checkin.user.firstName;
        if (typeof(checkin.user.lastName)!="undefined")
            userName = userName + " " + checkin.user.lastName[0] + ".";
        var createdAt = new Date(parseInt(checkin.createdAt,10)*1000);
        var createdAgo = prettyDate(createdAt);
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
        var comments = "123";
        if(typeof(checkin.comments)!="undefined"){
            comments = checkin.comments.count;
        }
        friendsCheckinsModel.append({
                           "id": checkin.id,
                           "shout": parse(checkin.shout),
                           "user": userName,
                           "userID": checkin.user.id,
                           "photo": checkin.user.photo,
                           "comments": comments,
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
    if(venue.tips.count>0) {
        for(var i in venue.tips.groups[0].items) {
            var tip = venue.tips.groups[0].items[i];
            //console.log("tip: " + tip);
            var createdAt = new Date(parseInt(tip.createdAt,10)*1000);
            var createdAgo = prettyDate(createdAt);
            tipsModel.append({
                             "tipID": tip.id,
                             "tipText": tip.text,
                             "tipAge": "Added " + createdAgo
            });
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

function addCheckin(venueID, comment, friends, facebook, twitter) {
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
    doWebRequest("POST", url, "", parseAddCheckin);
}

function parseAddCheckin(response) {
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

function loadCheckin(checkin) {
    waiting.state = "shown";
    //var id = "4fa6a2cae4b089a95b316999"; //points
    //var id = "4fa74812e4b0cbe2e15e6ada"; //bages
    //var id = "4fa6634ce4b0fd4c3fb0af77"; //points + badges
    //var id = "4fa3ecd8e4b0ace472d9569c"; //comments + points + badge
    var id = checkin.id
    var url = "https://api.foursquare.com/v2/checkins/" + id + "?" + getAccessTokenParameter();

    checkinDetails.scoreTotal = "--";
    scoresModel.clear();
    badgesModel.clear();
    commentsModel.clear();
    doWebRequest("GET",url,"",parseCheckin);
}

function parseCheckin(response) {
    var data = eval("[" + response + "]")[0].response;
    //console.log("CHECKIN INFO: " + JSON.stringify(data.checkin) + "\n");

    checkinDetails.scoreTotal = data.checkin.score.total;
    for( var i in data.checkin.score.scores) {
        var score = data.checkin.score.scores[i];
        //console.log("CHECKIN SCORE: " + JSON.stringify(score));
        scoresModel.append({
                               "scorePoints": score.points,
                               "scoreImage": score.icon,
                               "scoreMessage": score.message,
                    });
    }
    if(typeof(data.checkin.badges)!="undefined") {
        for( var i in data.checkin.badges.items) {
            var badge = data.checkin.badges.items[i];
            //console.log("CHECKIN BADGE: " + JSON.stringify(badge));
            badgesModel.append({
                                   "badgeTitle":badge.name,
                                   "badgeMessage":badge.description,
                                   "badgeImage":badge.image.prefix + badge.image.sizes[1] + badge.image.name})
        }
    }
    for( var i in data.checkin.comments.items) {
        var comment = data.checkin.comments.items[i];
        console.log("CHECKIN COMMENT: " + JSON.stringify(comment));
        var createdAt = new Date(parseInt(comment.createdAt,10)*1000);
        var createdAgo = prettyDate(createdAt);
        var userID = comment.user.id;
        var userName = comment.user.firstName;
        if (typeof(comment.user.lastName)!="undefined") {
            userName = userName + " " + comment.user.lastName[0] + ".";
        }
        var userPhoto = comment.user.photo;
        var text = comment.text;
        commentsModel.append({
                                 "createdAt":createdAgo,
                                 "user":userName,
                                 "venueName":"",
                                 "userID":userID,
                                 "photo":userPhoto,
                                 "shout":text});
    }

    waiting.state = "hidden";
}

function loadUser(user) {
    var url = "https://api.foursquare.com/v2/users/" + user + "?" + getAccessTokenParameter();
    waiting.state = "shown";
    doWebRequest("GET", url, "", parseUser);
}

function parseUser(response) {
    //console.log("USER: " + response);
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

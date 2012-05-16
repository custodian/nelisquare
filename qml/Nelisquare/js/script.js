Qt.include("utils.js")

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
    url = "https://api.foursquare.com/v2/" + url;
    //console.log(method + " " + url);

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
    if(params.length) {
        doc.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        doc.send(params);
    } else {        
        doc.send();
    }
}

function doNothing(response) {
    // Nothing...
    processResponse(response);
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

function showError(msg) {
    waiting.state = "hidden";
    console.log("Error: "+ msg);
    //error.state = "shown";
    //error.reason = msg;
    notificationDialog.message += msg + "<br/>"
    notificationDialog.state = "shown";
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
    //console.log("DONE: " + data);
    if(waiting.state!="shown") {
        return;
    }
    waiting.state = "hidden";
    done.status = "";
    if(typeof(data)!="undefined" && data!=null) {
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

function makeUserName(user) {
    var username = parse(user.firstName);
    var lastname = parse(user.lastName);
    if(lastname.length>0) {
        username += " " + lastname + ".";
    }
    return username;
}

function thumbnailPhoto(photos, minsize) {
    var url = "";
    var width = 1000;
    photos.sizes.items.forEach(function(photo) {
        if (photo.width < width && photo.width >= minsize ) {
            width = photo.width;
            url = photo.url;
        }
    });
    return url;
}

function makePhoto(photo,minsize) {
    return {
       "objectID": photo.id,
       "photoThumb":thumbnailPhoto(photo,minsize)
   }
}

function processResponse(response) {
    var data = eval("[" + response + "]")[0];
    var meta = data.meta;
    if (meta.code != 200) {
        showError("ErrorType: " + meta.errorType + "\n" + meta.errorDetail);
    }
    var notifications = data.notifications;
    if (typeof(notifications)!="undefined"){
        notifications.forEach(function(notification) {
                if (parse(notification.type) == "notificationTray") {
                    updateNotificationCount(notification.item.unreadCount);
                }
            });
    }
    return data.response;
}

function addTipToModel(tip) {
    //console.log("VENUE TIP: " + JSON.stringify(tip));
    venueDetails.tipsModel.append({
                     "userID": tip.user.id,
                     "userPhoto": tip.user.photo,
                     "tipID": tip.id,
                     "tipText": tip.text,
                     "tipAge": "Added " + makeTime(tip.createdAt)
    });
}

function addCommentToModel(comment) {
    //console.log("CHECKIN COMMENT: " + JSON.stringify(comment));
    var createdAgo = makeTime(comment.createdAt);
    var userID = comment.user.id;
    var userName = makeUserName(comment.user);
    var userPhoto = comment.user.photo;
    var text = comment.text;
    var relationship = parse(comment.user.relationship);

    checkinDetails.commentsModel.append({
                             "commentID":comment.id,
                             "createdAt":createdAgo,
                             "user":userName,
                             "userID":userID,
                             "photo":userPhoto,
                             "shout":text,
                             "owner":relationship
                         });
}

function loadFriendsCheckins() {
    var url = "checkins/recent?" + getAccessTokenParameter();
    doWebRequest("GET", url, "", parseFriendsCheckins);
    waiting.state = "shown";
}

function loadNearbyFriendsCheckins() {
    var url = "checkins/recent?" +
        getLocationParameter() + "&" + getAccessTokenParameter();
    doWebRequest("GET", url, "", parseFriendsCheckins);
    waiting.state = "shown";
}

function parseFriendsCheckins(response) {
    var data = processResponse(response);
    var count = 0;
    friendsCheckinsModel.clear();
    data.recent.forEach(function(checkin) {
        //console.log("FRIEND CHECKIN: " + JSON.stringify(checkin));
        var userName = makeUserName(checkin.user);
        var createdAgo = makeTime(checkin.createdAt);
        var venueName = "";
        var venueID = "";
        if(typeof(checkin.venue)!="undefined") {
            venueName = checkin.venue.name;
            venueID = checkin.venue.id;
        }
        var comments = parse(checkin.comments.count);
        var venuePhoto = "";
        if (checkin.photos.count > 0) {
            venuePhoto = thumbnailPhoto(checkin.photos.items[0], 300);
        }
        friendsCheckinsModel.append({
                           "id": checkin.id,
                           "shout": parse(checkin.shout),
                           "user": userName,
                           "userID": checkin.user.id,
                           "photo": checkin.user.photo,
                           "comments": comments,
                           "venueID": venueID,
                           "venueName": venueName,
                           "createdAt": createdAgo,
                           "venuePhoto": venuePhoto
        });
        count++;
    });
    waiting.state = "hidden";
    if(count==0) {
        showDone("No visible checkins");
    }
}

function getLocationParameter() {
    var lat = positionSource.position.coordinate.latitude;
    var lon = positionSource.position.coordinate.longitude;
    return "ll=" + lat + "," + lon;
}

function loadPlaces(query) {
    var url = "venues/search?" +
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
    var data = processResponse(response);
    var count = 0;
    placesModel.clear();
    waiting.state = "hidden";
    data.groups[0].items.forEach(function(place) {
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
                           "icon": icon,
                           "venueCheckinsCount": place.stats.checkinsCount,
                           "venueUsersCount": place.stats.usersCount
        });
        count++;
    });
    if(count==0) {
        showDone("No visible places");
    }
}

function loadVenue(venueID) {
    var url = "venues/" + venueID + "?" + getAccessTokenParameter();
    waiting.state = "shown";
    venueDetails.venueID = venueID;
    venueDetails.venueName = "";
    venueDetails.venueAddress = "";
    venueDetails.venueCity = "";
    venueDetails.venueMajor = "";
    venueDetails.photosBox.photosModel.clear();
    venueDetails.usersBox.photosModel.clear();
    doWebRequest("GET", url, "", parseVenue);
}

function parseVenue(response) {
    var data = processResponse(response);
    //console.log("VENUE: "+ JSON.stringify(data));
    waiting.state = "hidden";
    var venue = data.venue;
    var icon = "";
    if(venue.categories!=null && typeof(venue.categories[0])!="undefined") {
        icon = venue.categories[0].icon;
    }
    venueDetails.venueID = venue.id;
    venueDetails.venueName = venue.name;
    venueDetails.venueAddress = parse(venue.location.address);
    venueDetails.venueCity = parse(venue.location.city);
    venueDetails.venueMajor = "";
    if(venue.mayor.count>0) {
        venueDetails.venueMajor = makeUserName(venue.mayor.user);
        venueDetails.venueMajorPhoto = venue.mayor.user.photo;
        venueDetails.venueMajorID = venue.mayor.user.id;
    }
    venueDetails.venueMapUrl = "";
    if(typeof(venue.location)!="undefined") {
        venueDetails.venueMapUrl =
        "http://maps.googleapis.com/maps/api/staticmap?center="+
                venue.location.lat+","+venue.location.lng+
                "&zoom=15&size=320x320&maptype=roadmap&markers=size:small|"+
                venue.location.lat+","+venue.location.lng+"&sensor=false";
    }

    // Parse venue tips
    venueDetails.tipsModel.clear();
    if(venue.tips.count>0) {
        venue.tips.groups[0].items.forEach(function(tip) {
            addTipToModel(tip);
        });
    }
    if(venue.photos.count>0) {
        venueDetails.photosBox.caption = venue.photos.summary;
        venue.photos.groups.forEach(function(group) {
            if (group.count>0 && group.type == "venue") {
                group.items.forEach(function(photo){
                    venueDetails.photosBox.photosModel.append(
                        makePhoto(photo,300) );
                });
            }
        });
    }
    if (venue.hereNow.count>0) {
        venueDetails.usersBox.caption = venue.hereNow.summary;
        venue.hereNow.groups.forEach(function(group) {
            if (group.count>0) {
                group.items.forEach(function(user){
                    venueDetails.usersBox.photosModel.append({
                        "objectID": user.user.id,
                        "photoThumb": user.user.photo });
                });
            }
        });

    }
}

function addComment(checkinID, text) {
    waiting.state = "shown";
    var url = "checkins/" + checkinID + "/addcomment?"
    url += "CHECKIN_ID=" + checkinID + "&";
    url += "text=" + encodeURIComponent(text) + "&";
    url += getAccessTokenParameter();
    doWebRequest("POST", url, "", parseAddComment);
}

function parseAddComment(response) {
    var data = processResponse(response);
    waiting.state = "hidden";
    addCommentToModel(data.comment);
}

function deleteComment(checkinID, commentID) {
    waiting.state = "shown";
    var url = "checkins/" + checkinID + "/deletecomment?"
    url += "CHECKIN_ID=" + checkinID + "&";
    url += "commentId=" + commentID + "&";
    url += getAccessTokenParameter();
    doWebRequest("POST", url, "", parseDeleteComment);
}

function parseDeleteComment(response) {
    var data = processResponse(response);
    waiting.state = "hidden";
    commentsModel.clear();
    data.checkin.comments.items.forEach(function(comment) {
        addCommentToModel(comment);
    });
}

function addTip(venueID, text) {
    waiting.state = "shown";
    var url = "tips/add?";
    url += "venueId=" + venueID + "&";
    url += "text=" + encodeURIComponent(text) + "&";
    url += getAccessTokenParameter();
    doWebRequest("POST", url, "", parseAddTip);
}

function parseAddTip(response){
    var data = processResponse(response);
    waiting.state = "hidden";
    addTipToModel(data.tip);
}

function markVenueToDo(venueID, text) {
    var url = "venues/" + venueID + "/marktodo?";
    if(text!="" && text.length>0) {
        url += "text=" + encodeURIComponent(text) + "&";
    }
    url += getAccessTokenParameter();
    doWebRequest("POST", url, "", showDone);
}

function addCheckin(venueID, comment, friends, facebook, twitter) {
    var url = "checkins/add?";
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
    notificationDialog.message = "<span>";
    data.notifications.forEach(function(noti) {
        if(typeof(noti.item.message)!="undefined") {
            if(notificationDialog.message.length>6) {
                notificationDialog.message += "<br/><br/>"
            }
            notificationDialog.message += noti.item.message;
        }
    });
    notificationDialog.message += "</span>";
    notificationDialog.state = "shown";
    window.showCheckinDetails(data.response.checkin.id);
}

function loadLeaderBoard() {
    var url = "users/leaderboard?" + getAccessTokenParameter();
    waiting.state = "shown";
    doWebRequest("GET", url, "", parseLeaderBoard);
}

function parseLeaderBoard(response) {
    waiting.state = "hidden";
    var data = eval("[" + response + "]")[0];
    boardModel.clear();
    data.response.leaderboard.items.forEach(function(ranking) {
        boardModel.append({
                           "id": ranking.user.id,
                           "name": makeUserName(ranking.user),
                           "photo": ranking.user.photo,
                           "recent": ranking.scores.recent,
                           "max": ranking.scores.max,
                           "checkinsCount": ranking.scores.checkinsCount,
                           "rank": ranking.rank
        });
        if(ranking.user.relationship=="self") {
            leaderBoard.rank = ranking.rank;
        }
    });
}

function loadToDo() {
    var url = "users/self/todos?" +
        getLocationParameter() + "&" +
        getAccessTokenParameter();
    waiting.state = "shown";
    doWebRequest("GET", url, "", parseToDo);
}

function parseToDo(response) {
    waiting.state = "hidden";
    var data = eval("[" + response + "]")[0];
    placesModel.clear();
    data.response.todos.items.forEach(function(todo) {
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
                           "icon": icon,
                           "venueCheckinsCount": place.stats.checkinsCount,
                           "venueUsersCount": place.stats.usersCount
        });
    });
}

function loadCheckin(id) {
    waiting.state = "shown";
    //var id = "4fa6a2cae4b089a95b316999"; //points
    //var id = "4fa74812e4b0cbe2e15e6ada"; //bages
    //var id = "4fa6634ce4b0fd4c3fb0af77"; //points + badges
    //var id = "4fa3ecd8e4b0ace472d9569c"; //comments + points + badge
    var url = "checkins/" + id + "?" + getAccessTokenParameter();

    checkinDetails.scoreTotal = "--";
    checkinDetails.scoresModel.clear();
    checkinDetails.badgesModel.clear();
    checkinDetails.commentsModel.clear();
    checkinDetails.photosBox.photosModel.clear();
    doWebRequest("GET",url,"",parseCheckin);
}

function parseCheckin(response) {
    var checkin = processResponse(response).checkin;
    //console.log("CHECKIN INFO: " + JSON.stringify(data.checkin) + "\n");

    checkinDetails.checkinID = checkin.id;
    checkinDetails.scoreTotal = checkin.score.total;
    checkinDetails.owner.userID = checkin.user.id;
    checkinDetails.owner.userName = makeUserName(checkin.user);
    checkinDetails.owner.createdAt = makeTime(checkin.createdAt);
    checkinDetails.owner.userPhoto.photoUrl = checkin.user.photo;
    checkinDetails.owner.venueID = checkin.venue.id;
    checkinDetails.owner.venueName = checkin.venue.name;
    checkinDetails.owner.venueAddress = parse(checkin.venue.location.address);
    checkinDetails.owner.venueCity = parse(checkin.venue.location.city);
    checkinDetails.owner.eventOwner = parse(checkin.user.relationship);
    checkinDetails.owner.userShout = parse(checkin.user.shout);

    checkin.score.scores.forEach(function(score) {
        //console.log("CHECKIN SCORE: " + JSON.stringify(score));
        checkinDetails.scoresModel.append({
                               "scorePoints": score.points,
                               "scoreImage": score.icon,
                               "scoreMessage": score.message,
                    });
    });
    if(typeof(checkin.badges)!="undefined") {
        checkin.badges.items.forEach(function(badge) {
            //console.log("CHECKIN BADGE: " + JSON.stringify(badge));
            checkinDetails.badgesModel.append({
                                   "badgeTitle":badge.name,
                                   "badgeMessage":badge.description,
                                   "badgeImage":badge.image.prefix + badge.image.sizes[1] + badge.image.name})
        });
    }
    checkin.comments.items.forEach(function(comment) {
        addCommentToModel(comment);
    });

    if (checkin.photos.count>0) {
        checkin.photos.items.forEach(function (photo) {
            checkinDetails.photosBox.photosModel.append(
                makePhoto(photo,300));
        });
    }

    waiting.state = "hidden";
}

function loadUser(user) {
    var url = "users/" + user + "?" + getAccessTokenParameter();
    waiting.state = "shown";
    userDetails.friendsBox.photosModel.clear();
    doWebRequest("GET", url, "", parseUser);
}

function parseUser(response) {
    var data = processResponse(response);
    //console.log("USER: " + JSON.stringify(data))
    waiting.state = "hidden";
    var user = data.user;
    userDetails.userName = makeUserName(user);
    userDetails.userPhoto = user.photo;
    userDetails.userBadgesCount = user.badges.count;
    userDetails.userCheckinsCount = user.checkins.count;
    userDetails.userFriendsCount = user.friends.count;
    userDetails.userID = user.id;
    userDetails.userMayorshipsCount = user.mayorships.count;
    var lastVenue = "";
    var lastTime = "";
    if(typeof(user.checkins.items)!="undefined") {
        lastVenue = user.checkins.items[0].venue.name;
        lastTime = makeTime(user.checkins.items[0].createdAt);
    }
    userDetails.lastVenue = lastVenue;
    userDetails.lastTime = lastTime;

    userDetails.scoreRecent = user.scores.recent;
    userDetails.scoreMax = user.scores.max;
    userDetails.userRelationship = parse(user.relationship);

    if (user.friends.count>0) {
        userDetails.friendsBox.caption = "Total friends: " + user.friends.count;
        user.friends.groups.forEach(function(group) {
            if (group.type == "friends") {
                userDetails.friendsBox.caption += " ("+ group.name + " " + group.count + ")";
            }
            if (group.count>0) {
                group.items.forEach(function(user){
                    userDetails.friendsBox.photosModel.append({
                        "objectID": user.id,
                        "photoThumb": user.photo });
                });
            }
        });

    }
}

function addPhoto(checkin, photopath) {
    //notificationDialog.message = "Sorry, this isn't implemented yet!";
    //notificationDialog.state = "shown";
    //TODO: make public photos

    waiting.state = "shown";
    var url = "https://api.foursquare.com/v2/photos/add?";
    //var url = "http://172.17.0.1:8080/";
    url += "checkinId=" + checkin;
    url += "&" + getAccessTokenParameter();
    if (!pictureHelper.upload(url,photopath)) {
        showError("Error uploading photo!");
    }

}

function parseAddPhoto(response) {
    waiting.state = "hidden";
    var photo = processResponse(response).photo;    
    //console.log("ADDED PHOTO: " + JSON.stringify(photo));
    checkinDetails.photosBox.photosModel.append(
                makePhoto(photo,300));
}

function loadPhoto(photoid) {
    var url = "photos/" + photoid + "?" + getAccessTokenParameter();
    waiting.state = "shown";
    doWebRequest("GET", url, "", parsePhoto);
}

function parsePhoto(response) {
    var photo = processResponse(response).photo;
    //console.log("PHOTO: " + JSON.stringify(photo))

    photoDetails.photoUrl = photo.url;
    photoDetails.owner.userID = photo.user.id;
    photoDetails.owner.userName = "<span style='color:#000'>Uploaded by </span>" + makeUserName(photo.user);
    photoDetails.owner.userPhoto.photoUrl = photo.user.photo;
    photoDetails.owner.userShout = "via " + parse(photo.source.name);
    photoDetails.owner.createdAt = makeTime(photo.createdAt);

    waiting.state = "hidden";
}

function loadNotifications() {
    var url = "updates/notifications?" + getAccessTokenParameter();
    waiting.state = "shown";
    doWebRequest("GET",url,"", parseNotifications);
}

function markNotificationsRead(time) {
    var url = "updates/marknotificationsread?";
    url += "highWatermark=" + time;
    url += "&" + getAccessTokenParameter();
    notificationsList.notificationsModel.clear();
    doWebRequest("POST",url,"", doNothing);
}

function parseNotifications(response) {
    var notis = processResponse(response).notifications;
    //console.log("NOTIFICATIONS: " + JSON.stringify(notis));
    waiting.state = "hidden";
    notis.items.forEach(function(noti) {
        //console.log("NOTIFICATIONS: " + JSON.stringify(noti));
        var objectID = noti.target.object.id;
        if (noti.target.type == "tip")
            objectID = noti.target.object.venue.id;
        notificationsList.notificationsModel
            .append({
                        "type": noti.target.type,
                        "objectID": objectID,
                        "userName": makeUserName("asdf"),
                        "createdAt": noti.createdAt,
                        "time": makeTime(noti.createdAt),
                        "text": noti.text,
                        "photo": noti.image.fullPath
                })
        });
}

function addFriend(user) {
    var url = "users/"+user+"/request?";
    url += getAccessTokenParameter();
    doWebRequest("POST",url,"", doNothing);
}

function removeFriend(user) {
    var url = "users/"+user+"/unfriend?";
    url += getAccessTokenParameter();
    doWebRequest("POST",url,"", doNothing);
}

function approveFriend(user) {
    var url = "users/"+user+"/approve?";
    url += getAccessTokenParameter();
    doWebRequest("POST",url,"", doNothing);
}

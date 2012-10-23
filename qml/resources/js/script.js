Qt.include("utils.js")

var MAX_NEARBY_DISTANCE = 100000; //100km

var UPDATE_BASE = "http://thecust.net/nelisquare/"

var API_VERSION = "20120910";
var CLIENT_ID = "4IFSW3ZXR4BRBXT3IIZMB13YPNGSIOK4ANEM0PP3T2CQQFWI";
var CALLBACK_URL = "http://nelisquare.substanceofcode.com/callback.php";
var AUTHENTICATE_URL = "https://foursquare.com/oauth2/authenticate" +
    "?client_id=" + CLIENT_ID +
    "&response_type=token" +
    "&display=touch" +
    "&v=" + API_VERSION +
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
    return "oauth_token=" + accessToken+"&v="+API_VERSION;
}

function showError(msg) {
    waiting.hide();
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
        waiting.hide();
        //loadUnreadNews();
    } else {
        addError("Couldn't parse SID");
        waiting.hide();
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
    waiting.hide();
    done.status = "";
    if(data!==undefined && data!=null) {
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

function makeImageUrl(image, size) {
    return image.prefix + size + image.name;
}

function thumbnailPhoto(photo, width_, height_) {
    var url = "";
    var width = photo.width;
    var height = photo.height;
    if (width_ !== undefined)
        width = width_;
    if (height_ !== undefined)
        height = height_;
    if (width === undefined)
        width = 100;
    if (height === undefined)
        height = width
    url = photo.prefix + width+"x"+height + photo.suffix;
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
    if (notifications!==undefined){
        notifications.forEach(function(notification) {
                if (parse(notification.type) == "notificationTray") {
                    window.updateNotificationCount(notification.item.unreadCount);
                }
            });
    }
    return data.response;
}

function addTipToModel(tip) {
    //console.log("VENUE TIP: " + JSON.stringify(tip));
    venueDetails.tipsModel.append({
                     "userID": tip.user.id,
                     "userPhoto": thumbnailPhoto(tip.user.photo,100),
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
    var userPhoto = thumbnailPhoto(comment.user.photo,100);
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

function processLikes(likebox, data) {
    if (data.like!==undefined) {
        likebox.mylike = data.like;
    }
    if (data.dislike!==undefined) {
        likebox.mydislike = data.dislike;
    }
    likebox.likes = data.likes.count;
    if (data.likes.count > 0) {
        likebox.likeText = data.likes.summary;
    }
}

function loadFriendsFeed() {
    var url = "checkins/recent?" + getAccessTokenParameter();
    doWebRequest("GET", url, "", parseFriendsFeed);
    waiting.show();
}

function loadFriendsFeedNearby() {
    var url = "checkins/recent?" +
        getLocationParameter() + "&" + getAccessTokenParameter();
    doWebRequest("GET", url, "", parseFriendsFeed);
    waiting.show();
}

function parseFriendsFeed(response) {
    var data = processResponse(response);
    var count = 0;
    friendsFeed.friendsCheckinsModel.clear();
    data.recent.forEach(function(checkin) {
        //console.log("FRIEND CHECKIN: " + JSON.stringify(checkin));
        var userName = makeUserName(checkin.user);
        var createdAgo = makeTime(checkin.createdAt);
        var venueName = "";
        var venueID = "";
        var venueDistance = undefined;
        if(checkin.venue!==undefined) {
            venueName = checkin.venue.name;
            venueID = checkin.venue.id;
            venueDistance = checkin.venue.location.distance;
        }
        var commentsCount = 0;
        if (checkin.comments!==undefined) {
            commentsCount = parse(checkin.comments.count);
        }
        var venuePhoto = "";
        if (checkin.photos.count > 0) {
            venuePhoto = thumbnailPhoto(checkin.photos.items[0], 300);
        }
        if (venueDistance === undefined || venueDistance < MAX_NEARBY_DISTANCE) {
            friendsFeed.friendsCheckinsModel.append({
                               "id": checkin.id,
                               "shout": parse(checkin.shout),
                               "user": userName,
                               "userID": checkin.user.id,
                               "mayor": parse(checkin.isMayor),
                               "photo": thumbnailPhoto(checkin.user.photo, 100),
                               "commentsCount": commentsCount,
                               "venueID": venueID,
                               "venueName": venueName,
                               "createdAt": createdAgo,
                               "venuePhoto": venuePhoto
            });
        }
        count++;
    });
    waiting.hide();
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
    waiting.show();
}

function parseIcon(icon, size) {
    if (size === undefined) {
        size = 32
    }
    return icon.prefix+"bg_"+size+icon.suffix;
}

function parse(item) {
    if(item!==undefined) {
        return item;
    } else {
        return "";
    }
}

function parsePlaces(response) {
    var data = processResponse(response);
    var count = 0;
    venuesList.placesModel.clear();
    waiting.hide();
    data.venues.forEach(function(place) {
        //console.log("PLACE: " + JSON.stringify(place));
        var icon = "";
        if(place.categories!=null && place.categories[0]!==undefined) {
            icon = parseIcon(place.categories[0].icon);
        }
        venuesList.placesModel.append({
                           "id": place.id,
                           "name": place.name,
                           "todoComment": "",
                           "distance": place.location.distance,
                           "address": parse(place.location.address),
                           "city": parse(place.location.city),
                           "lat": place.location.lat,
                           "lng": place.location.lng,
                           "icon": icon,
                           "hereNow": parse(place.hereNow.count)
        });
        count++;
    });
    if(count==0) {
        showDone("No visible places");
    }
}

function likeVenue(id, state) {
    //console.log("LIKE VENUE: " + id + " STATE: " + state);
    var url = "venues/"+id+"/like?set="
    if (state) {
        url += "1";
    } else {
        url += "0";
    }
    url += "&" + getAccessTokenParameter();
    doWebRequest("POST", url, "", parseLikeVenue);
}

function parseLikeVenue(response) {
    //console.log("LIKE RESPONSE: " + JSON.stringify(response));
    var data = processResponse(response);

    processLikes(venueDetails.likeBox, data);
}

function loadVenue(venueID) {
    var url = "venues/" + venueID + "?" + getAccessTokenParameter();
    waiting.show();
    venueDetails.venueID = venueID;
    venueDetails.venueName = "";
    venueDetails.venueAddress = "";
    venueDetails.venueCity = "";
    venueDetails.venueMajor = "";
    venueDetails.photosBox.photosModel.clear();
    venueDetails.usersBox.photosModel.clear();
    venueDetails.venueMapUrl = "";
    venueDetails.venueMapLat = "";
    venueDetails.venueMapLng = "";
    //venueDetails.venueMapZoom = 15; //do not reset on each venue
    doWebRequest("GET", url, "", parseVenue);
}

function parseVenue(response) {
    var data = processResponse(response);
    //console.log("VENUE: "+ JSON.stringify(data));
    waiting.hide();
    var venue = data.venue;
    var icon = "";
    if(venue.categories!=null && venue.categories[0]!==undefined) {
        icon = venue.categories[0].icon;
    }
    venueDetails.venueID = venue.id;
    venueDetails.venueName = venue.name;
    venueDetails.venueAddress = parse(venue.location.address);
    venueDetails.venueCity = parse(venue.location.city);
    if (venue.categories[0]!== undefined)
        venueDetails.venueTypeUrl = parseIcon(venue.categories[0].icon);
    if(venue.mayor.count>0) {
        venueDetails.venueMajor = makeUserName(venue.mayor.user);
        venueDetails.venueMajorPhoto = thumbnailPhoto(venue.mayor.user.photo,100);
        venueDetails.venueMajorID = venue.mayor.user.id;
    } else {
        venueDetails.venueMajor = "";
        venueDetails.venueMajorPhoto = "";
        venueDetails.venueMajorID = "";
    }
    if(venue.location!==undefined) {
        venueDetails.venueMapLat = venue.location.lat;
        venueDetails.venueMapLng = venue.location.lng;
    }
    // parse likes
    processLikes(venueDetails.likeBox, venue);

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
                        "photoThumb": thumbnailPhoto(user.user.photo,100) });
                });
            }
        });

    }
}

function addComment(checkinID, text) {
    waiting.show();
    var url = "checkins/" + checkinID + "/addcomment?"
    url += "CHECKIN_ID=" + checkinID + "&";
    url += "text=" + encodeURIComponent(text) + "&";
    url += getAccessTokenParameter();
    doWebRequest("POST", url, "", parseAddComment);
}

function parseAddComment(response) {
    var data = processResponse(response);
    waiting.hide();
    addCommentToModel(data.comment);
}

function deleteComment(checkinID, commentID) {
    waiting.show();
    var url = "checkins/" + checkinID + "/deletecomment?"
    url += "CHECKIN_ID=" + checkinID + "&";
    url += "commentId=" + commentID + "&";
    url += getAccessTokenParameter();
    doWebRequest("POST", url, "", parseDeleteComment);
}

function parseDeleteComment(response) {
    var data = processResponse(response);
    waiting.hide();
    commentsModel.clear();
    data.checkin.comments.items.forEach(function(comment) {
        addCommentToModel(comment);
    });
}

function addTip(venueID, text) {
    waiting.show();
    var url = "tips/add?";
    url += "venueId=" + venueID + "&";
    url += "text=" + encodeURIComponent(text) + "&";
    url += getAccessTokenParameter();
    doWebRequest("POST", url, "", parseAddTip);
}

function parseAddTip(response){
    var data = processResponse(response);
    waiting.hide();
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
    if(comment!==undefined && comment!=null && comment.length>0) {
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
    waiting.show();
    doWebRequest("POST", url, "", parseAddCheckin);
}

function parseAddCheckin(response) {
    waiting.hide();
    var data = processResponse(response);
    notificationDialog.message = "<span>";
    data.notifications.forEach(function(noti) {
        //console.log("NOTIFICATION: "+ JSON.stringify(noti));
        if(noti.item.message!==undefined) {
            if(notificationDialog.message.length>6) {
                notificationDialog.message += "<br/><br/>";
            }
            notificationDialog.message += noti.item.message;
            if (noti.type == "tip") {
                notificationDialog.message += "<br/>" + noti.item.tip.text;
            }
            //TODO: add specials support info
        }
    });
    notificationDialog.message += "</span>";
    notificationDialog.state = "shown";
    window.showCheckinPage(data.checkin.id);
}

function loadLeaderBoard() {
    var url = "users/leaderboard?" + getAccessTokenParameter();
    waiting.show();
    doWebRequest("GET", url, "", parseLeaderBoard);
}

function parseLeaderBoard(response) {
    waiting.hide();
    var data = eval("[" + response + "]")[0];
    leaderBoard.boardModel.clear();
    data.response.leaderboard.items.forEach(function(ranking) {
        leaderBoard.boardModel.append({
                           "id": ranking.user.id,
                           "name": makeUserName(ranking.user),
                           "photo": thumbnailPhoto(ranking.user.photo,100),
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
    waiting.show();
    doWebRequest("GET", url, "", parseToDo);
}

function parseToDo(response) {
    waiting.hide();
    var data = eval("[" + response + "]")[0];
    venuesList.placesModel.clear();
    data.response.todos.items.forEach(function(todo) {
        var place = todo.tip.venue;
        var icon = "";
        if(place.categories!=null && place.categories[0]!==undefined) {
            icon = parseIcon(place.categories[0].icon);
        }
        venuesList.placesModel.append({
                           "id": place.id,
                           "name": place.name,
                           "todoComment": todo.tip.text,
                           "distance": place.location.distance,
                           "address": parse(place.location.address),
                           "city": parse(place.location.city),
                           "lat": place.location.lat,
                           "lng": place.location.lng,
                           "icon": icon,
                           "hereNow": ""
        });
    });
}

function likeCheckin(id, state) {
    //console.log("ID: " + id + " State: " + state);
    var url = "checkins/"+id+"/like?set="
    if (state) {
        url += "1";
    } else {
        url += "0";
    }
    url += "&" + getAccessTokenParameter();
    doWebRequest("POST", url, "", parseLikeCheckin);
}

function parseLikeCheckin(response) {
    //console.log("LIKE RESPONSE: " + JSON.stringify(response));
    var data = processResponse(response);

    processLikes(checkinDetails.likeBox, data);
}

function loadCheckin(id) {
    waiting.show();
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
    checkinDetails.owner.userPhoto.photoUrl = thumbnailPhoto(checkin.user.photo,100);
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
    if(checkin.badges!==undefined) {
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

    processLikes(checkinDetails.likeBox, checkin);

    waiting.hide();
}

function loadMayorships(user) {
    var url = "users/"+user + "/mayorships?" + getAccessTokenParameter();
    waiting.show();
    mayorships.mayorshipsModel.clear();
    doWebRequest("GET", url, "", parseMayorhips);
}

function parseMayorhips(response) {
    var data = processResponse(response);
    waiting.hide();
    mayorships.mayorshipsModel.clear();
    data.mayorships.items.forEach(function(mayorship){
        var place = mayorship.venue;
        var icon = "";
        if(place.categories!=null && place.categories[0]!==undefined) {
            icon = parseIcon(place.categories[0].icon);
        }
        mayorships.mayorshipsModel.append({
            "id": place.id,
            "name": place.name,
            "address": parse(place.location.address),
            "city": parse(place.location.city),
            "lat": place.location.lat,
            "lng": place.location.lng,
            "icon": icon,
            "hereNow": ""
        });
    });
}

function loadCheckinHistory(user) {
    var url = "users/" + user + "/checkins?limit=50&set=newestfirst&" + getAccessTokenParameter();
    waiting.show();
    checkinHistory.checkinHistoryModel.clear();
    doWebRequest("GET", url, "", parseCheckinHistory);
}

function parseCheckinHistory(response) {
    var data = processResponse(response);
    waiting.hide();
    checkinHistory.checkinHistoryModel.clear();
    data.checkins.items.forEach(function(checkin) {
        //console.log("USER CHECKIN: " + JSON.stringify(checkin));
        var createdAgo = makeTime(checkin.createdAt);
        var venueName = "";
        var venueID = "";
        if(checkin.venue!==undefined) {
            venueName = checkin.venue.name;
            venueID = checkin.venue.id;
        }
        var commentsCount = 0;
        if (checkin.comments!==undefined) {
            commentsCount = parse(checkin.comments.count);
        }
        var venuePhoto = "";
        if (checkin.photos.count > 0) {
            venuePhoto = thumbnailPhoto(checkin.photos.items[0], 300);
        }
        checkinHistory.checkinHistoryModel.append({
                           "id": checkin.id,
                           "shout": parse(checkin.shout),
                           "mayor": parse(checkin.isMayor),
                           "photo": parseIcon(checkin.venue.categories[0].icon),
                           "commentsCount": commentsCount,
                           "venueID": venueID,
                           "venueName": venueName,
                           "createdAt": createdAgo,
                           "venuePhoto": venuePhoto
        });
    });
}

function loadBadges(user) {
    var url = "users/" + user + "/badges?" + getAccessTokenParameter();
    waiting.show();
    userBadges.badgeModel.clear();
    doWebRequest("GET", url, "", parseBadges);
}

function parseBadges(response) {
    var data = processResponse(response);
    waiting.hide();
    data.sets.groups.forEach(function(group){
         if (group.type == "all") {
             group.items.forEach(function(item){
                 var badge = data.badges[item];
                 var venue = parse(badge.unlocks[0].checkins[0].venue);
                 userBadges.badgeModel.append({
                    "name":badge.name,
                    "image":makeImageUrl(badge.image,114),
                    "imageLarge":makeImageUrl(badge.image,300),
                    "info":badge.badgeText,
                    "venueName":parse(venue.name),
                    "venueID":parse(venue.id),
                    "time":prettyDate(badge.unlocks[0].checkins[0].createdAt),
                     });
             });
         }
    });
}

function loadUser(user) {
    var url = "users/" + user + "?" + getAccessTokenParameter();
    waiting.show();
    userDetails.boardModel.clear();
    userDetails.friendsBox.photosModel.clear();
    doWebRequest("GET", url, "", parseUser);
    if (user == "self") {
        url = "users/leaderboard?neighbors=2&" + getAccessTokenParameter();
        doWebRequest("GET",url,"", parseUserBoard);
    }
}

function parseUser(response) {
    var data = processResponse(response);
    //console.log("USER: " + JSON.stringify(data))
    waiting.hide();
    var user = data.user;
    userDetails.userName = makeUserName(user);
    userDetails.userPhoto = thumbnailPhoto(user.photo,100);
    userDetails.userBadgesCount = user.badges.count;
    userDetails.userCheckinsCount = user.checkins.count;
    userDetails.userFriendsCount = user.friends.count;
    userDetails.userID = user.id;
    userDetails.userMayorshipsCount = user.mayorships.count;
    var lastVenue = "";
    var lastTime = "";
    if(user.checkins.items!==undefined) {
        lastVenue = user.checkins.items[0].venue.name;
        lastTime = makeTime(user.checkins.items[0].createdAt);
    }
    userDetails.lastVenue = lastVenue;
    userDetails.lastTime = lastTime;

    userDetails.scoreRecent = user.scores.recent;
    userDetails.scoreMax = user.scores.max;
    userDetails.userRelationship = parse(user.relationship);

    if (user.friends.count>0) {
        userDetails.friendsBox.caption = "TOTAL FRIENDS: <b>" + user.friends.count +"</b>";
        user.friends.groups.forEach(function(group) {
            if (group.type == "friends" && user.relationship != "self" ) {
                userDetails.friendsBox.caption += " ("+ group.name + " <b>" + group.count + "</b>)";
            }
            if (group.count>0) {
                group.items.forEach(function(user){
                    userDetails.friendsBox.photosModel.append({
                        "objectID": user.id,
                        "photoThumb": thumbnailPhoto(user.photo,100) });
                });
            }
        });

    }
}

function parseUserBoard(response) {
    var data = processResponse(response);
    //console.log("USER: " + JSON.stringify(data))
    data.leaderboard.items.forEach(function(ranking) {
        if (ranking.user.relationship == "self")
            userDetails.userLeadersboardRank = ranking.rank;
        userDetails.boardModel.append({
               "user": "#" + ranking.rank + ". " +makeUserName(ranking.user),
               "shout": "<b>"+ranking.scores.recent+" "+"points" + "</b> " + ranking.scores.checkinsCount + " " + "checkins",
               "photo": thumbnailPhoto(ranking.user.photo,100),
        });
        if(ranking.user.relationship=="self") {
            leaderBoard.rank = ranking.rank;
        }
    });
}

function addPhoto(checkinID, venueID, photopath, makepublic, facebook, twitter) {
    waiting.show();
    var url = "https://api.foursquare.com/v2/photos/add?";
    if (checkinID!="") {
        url += "checkinId=" + checkinID;
    }
    if (venueID!=""){
        url += "venueId=" +venueID;
    }
    if (makepublic == "1") {
        url += "&public=1";
    }
    var broadcast = "";
    if (facebook) {
        broadcast = "facebook";
    }
    if (twitter) {
        if (broadcast!="") broadcast += ",";
        broadcast += "twitter";
    }
    if (broadcast != "") {
        url += "&broadcast="+broadcast;
    }
    url += "&" + getAccessTokenParameter();
    //console.log("PHOTOUPLOAD: "+url);
    if (!pictureHelper.upload(url,photopath)) {
        showError("Error uploading photo!");
    }
}

function parseAddPhoto(response) {
    waiting.hide();
    var photo = processResponse(response).photo;    
    console.log("ADDED PHOTO: " + JSON.stringify(photo));
    if (photoAdd.checkinID!="") {
        checkinDetails.photosBox.photosModel.insert(0,
                    makePhoto(photo,300));
    }
    if (photoAdd.venueID!="") {
        venueDetails.photosBox.photosModel.insert(0,
                    makePhoto(photo,300));
    }
}

function loadPhoto(photoid) {
    var url = "photos/" + photoid + "?" + getAccessTokenParameter();
    waiting.show();
    doWebRequest("GET", url, "", parsePhoto);
}

function parsePhoto(response) {
    var photo = processResponse(response).photo;
    //console.log("PHOTO: " + JSON.stringify(photo))

    photoDetails.photoUrl = thumbnailPhoto(photo);
    photoDetails.owner.userID = photo.user.id;
    photoDetails.owner.userName = "<span style='color:#000'>Uploaded by </span>" + makeUserName(photo.user);
    photoDetails.owner.userPhoto.photoUrl = thumbnailPhoto(photo.user.photo,100);
    photoDetails.owner.userShout = "via " + parse(photo.source.name);
    photoDetails.owner.createdAt = makeTime(photo.createdAt);

    waiting.hide();
}

function loadNotifications() {
    var url = "updates/notifications?" + getAccessTokenParameter();
    waiting.show();
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
    waiting.hide();
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


function getUpdateInfo(updatetype, callback) {
    var os = windowHelper.isMaemo() ? "maemo" : "meego";
    var url = "http://thecust.net/nelisquare/" + os + "/build." + updatetype

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
                changelog = changelog.replace(/  - /g,'\n - ');
            }
            var url = UPDATE_BASE + os + "/nelisquare";
            if (updatetype == "developer") {
                url += "-devel.deb";
            } else {
                url += "_" + version + "_armel.deb"
            }
            callback(build,version,changelog,url);
        }
    }

    doc.open("GET", url);
    doc.send();
}

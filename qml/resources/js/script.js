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

var defaultVenueIcon = {"prefix":"https://foursquare.com/img/categories_v2/none_","suffix":".png"}

function doWebRequest(method, url, params, callback) {
    //console.log(method + " " + url);
    url = "https://api.foursquare.com/v2/" + url;

    var doc = new XMLHttpRequest();
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
            callback(data,params);
        }
    }

    doc.open(method, url);
    doc.send();
}

function doNothing(response,page) {
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

function makeUserName(user) {
    var username = parse(user.firstName);
    var lastname = parse(user.lastName);
    if(lastname.length>0) {
        username += " " + lastname;// + ".";
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
    //console.log("NOTIFICATIONS: " + JSON.stringify(notifications));
    if (notifications!==undefined){
        notifications.forEach(function(notification) {
                if (parse(notification.type) == "notificationTray") {
                    window.updateNotificationCount(notification.item.unreadCount);
                }
            });
    }
    return data.response;
}

function addTipToModel(page,tip) {
    //console.log("VENUE TIP: " + JSON.stringify(tip));
    page.tipsModel.append({
                     "userID": tip.user.id,
                     "userPhoto": thumbnailPhoto(tip.user.photo,100),
                     "tipID": tip.id,
                     "tipText": tip.text,
                     "tipAge": "Added " + makeTime(tip.createdAt)
    });
}

function addCommentToModel(page, comment) {
    //console.log("CHECKIN COMMENT: " + JSON.stringify(comment));
    var createdAgo = makeTime(comment.createdAt);
    var userID = comment.user.id;
    var userName = makeUserName(comment.user);
    var userPhoto = thumbnailPhoto(comment.user.photo,100);
    var text = comment.text;
    var relationship = parse(comment.user.relationship);

    page.commentsModel.append({
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

function loadFriendsFeed(page) {
    var url = "checkins/recent?"
    if (page.lastUpdateTime!=="0") {
        url += "afterTimestamp="+page.lastUpdateTime+"&";
    } else {
        page.timerFeedUpdate.stop();
        waiting.show();
    }
    url += getAccessTokenParameter();
    doWebRequest("GET", url, page, parseFriendsFeed);    
}

function loadFriendsFeedNearby(page) {
    var url = "checkins/recent?" + getLocationParameter() + "&"
    if (page.lastUpdateTime!=="0") {
        url += "afterTimestamp="+page.lastUpdateTime+"&";
    } else {
        page.timerFeedUpdate.stop();
        waiting.show();
    }
    url += getAccessTokenParameter();
    doWebRequest("GET", url, page, parseFriendsFeed);    
}

function parseFriendsFeed(response, page) {
    var data = processResponse(response);
    var count = 0;
    var currentTime = getCurrentTime();
    var updateTime = page.lastUpdateTime;
    var updating = (updateTime !== "0");
    if (!updating) {
        page.friendsCheckinsModel.clear();
    }
    data.recent.forEach(function(checkin) {
        //console.log("FRIEND CHECKIN: " + JSON.stringify(checkin));
        if (updating && checkin.createdAt <= updateTime)
            return;
        var userName = makeUserName(checkin.user);
        if (updateTime <= checkin.createdAt)
            updateTime = checkin.createdAt;
        var venueName = "";
        var venueID = "";
        var venueDistance = undefined;
        if(checkin.venue!==undefined) {
            venueName = checkin.venue.name;
            venueID = checkin.venue.id;
            venueDistance = checkin.venue.location.distance;
        }
        var venuePhoto = "";
        if (checkin.photos.count > 0) {
            venuePhoto = thumbnailPhoto(checkin.photos.items[0], 300);
        }
        if (venueDistance === undefined || venueDistance < MAX_NEARBY_DISTANCE) {
            var item = {
                "id": checkin.id,
                "shout": parse(checkin.shout),
                "user": userName,
                "userID": checkin.user.id,
                "mayor": parse(checkin.isMayor),
                "photo": thumbnailPhoto(checkin.user.photo, 100),
                "venueID": venueID,
                "venueName": venueName,
                "createdAt": makeTime(checkin.createdAt),
                "timestamp": checkin.createdAt,
                "venuePhoto": venuePhoto,
                "lastUpdate": 0,
                "commentsCount":0,
                "likesCount":0
            };
            if (updating) {
                page.friendsCheckinsModel.insert(count,item)
            }
            else {
                page.friendsCheckinsModel.append(item);
            }
        }
        count++;
    });
    if (!updating) {
        page.timerFeedUpdate.restart();
        waiting.hide();
    } else {
        for (var i=0;i<page.friendsCheckinsModel.count;i++){
            page.friendsCheckinsModel.get(i).createdAt = makeTime(page.friendsCheckinsModel.get(i).timestamp);
        }
    }
    page.lastUpdateTime = updateTime;
}

function loadCheckinInfo(page, id) {
    var url = "checkins/" + id + "?" + getAccessTokenParameter();
    doWebRequest("GET",url,page,parseCheckinInfo);
}

function parseCheckinInfo(response,page) {
    var currentTime = getCurrentTime();
    var checkin = processResponse(response).checkin;
    for (var i=0;i<page.friendsCheckinsModel.count;i++){
        var model = page.friendsCheckinsModel.get(i);
        if (model.id === checkin.id) {
            model.commentsCount = checkin.comments.count;
            model.likesCount = checkin.likes.count;
            if (model.photo === "") {
                if (checkin.photos.count > 0) {
                    model.photo = thumbnailPhoto(checkin.photos.items[0], 300);
                }
            }
            model.lastUpdate = currentTime;
            return;
        }
    }
}

function getLocationParameter() {
    var lat = positionSource.position.coordinate.latitude;
    var lon = positionSource.position.coordinate.longitude;
    return "ll=" + lat + "," + lon;
}

function loadPlaces(page, query) {
    var url = "venues/search?" +
        getLocationParameter();
    if(query!=null && query.length>0) {
        url += "&query=" + query;
    }
    url += "&" + getAccessTokenParameter();
    doWebRequest("GET", url, page, parsePlaces);
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

function parsePlaces(response, page) {
    var data = processResponse(response);
    var count = 0;
    page.placesModel.clear();
    waiting.hide();
    data.venues.forEach(function(place) {
        //console.log("PLACE: " + JSON.stringify(place));
        var icon = "";
        if(place.categories!=null && place.categories[0]!==undefined) {
            icon = parseIcon(place.categories[0].icon);
        } else {
            icon = parseIcon(defaultVenueIcon);
        }
        page.placesModel.append({
                           "id": place.id,
                           "name": place.name,
                           "todoComment": "",
                           "distance": place.location.distance,
                           "address": parse(place.location.address),
                           "city": parse(place.location.city),
                           "lat": place.location.lat,
                           "lng": place.location.lng,
                           "icon": icon,
                           "peoplesCount": parse(place.hereNow.count)
        });
        count++;
    });
}

function likeVenue(page, id, state) {
    console.log("LIKE VENUE: " + id + " STATE: " + state);
    var url = "venues/"+id+"/like?set="
    if (state) {
        url += "1";
    } else {
        url += "0";
    }
    url += "&" + getAccessTokenParameter();
    doWebRequest("POST", url, page, parseLikeVenue);
}

function parseLikeVenue(response, page) {
    //console.log("LIKE RESPONSE: " + JSON.stringify(response));
    var data = processResponse(response);

    processLikes(page.likeBox, data);
}

function loadVenue(page, venueID) {
    var url = "venues/" + venueID + "?" + getAccessTokenParameter();
    waiting.show();
    page.venueID = venueID;
    page.venueName = "";
    page.venueAddress = "";
    page.venueCity = "";
    page.venueMajor = "";
    page.photosBox.photosModel.clear();
    page.usersBox.photosModel.clear();
    page.venueMapUrl = "";
    page.venueMapLat = "";
    page.venueMapLng = "";
    //venueDetails.venueMapZoom = 15; //do not reset on each venue
    doWebRequest("GET", url, page, parseVenue);
}

function parseVenue(response, page) {
    var data = processResponse(response);
    //console.log("VENUE: "+ JSON.stringify(data));
    waiting.hide();
    var venue = data.venue;
    var icon = "";
    if(venue.categories!=null && venue.categories[0]!==undefined) {
        icon = venue.categories[0].icon;
    }
    page.venueID = venue.id;
    page.venueName = venue.name;
    page.venueAddress = parse(venue.location.address);
    page.venueCity = parse(venue.location.city);
    if (venue.categories[0]!== undefined)
        page.venueTypeUrl = parseIcon(venue.categories[0].icon);
    else
        page.venueTypeUrl = parseIcon(defaultVenueIcon);
    if(venue.mayor.count>0) {
        page.venueMajor = makeUserName(venue.mayor.user);
        page.venueMajorPhoto = thumbnailPhoto(venue.mayor.user.photo,100);
        page.venueMajorID = venue.mayor.user.id;
    } else {
        page.venueMajor = "";
        page.venueMajorPhoto = "";
        page.venueMajorID = "";
    }
    if(venue.location!==undefined) {
        page.venueMapLat = venue.location.lat;
        page.venueMapLng = venue.location.lng;
    }
    // parse likes
    processLikes(page.likeBox, venue);

    // Parse venue tips
    page.tipsModel.clear();
    if(venue.tips.count>0) {
        venue.tips.groups.forEach(function (group) {
                group.items.forEach(function(tip) {
                    addTipToModel(page,tip);
                })
            });
    }
    if(venue.photos.count>0) {
        page.photosBox.caption = venue.photos.summary;
        venue.photos.groups.forEach(function(group) {
            if (group.count>0) {
                group.items.forEach(function(photo){
                    page.photosBox.photosModel.append(
                        makePhoto(photo,300) );
                });
            }
        });
    }
    if (venue.hereNow.count>0) {
        page.usersBox.caption = venue.hereNow.summary;
        venue.hereNow.groups.forEach(function(group) {
            if (group.count>0) {
                group.items.forEach(function(user){
                    page.usersBox.photosModel.append({
                        "objectID": user.user.id,
                        "photoThumb": thumbnailPhoto(user.user.photo,100) });
                });
            }
        });
    }
}

function loadVenuePhotos(page, venue) {
    page.photosModel.clear();
    waiting.show();
    var url = "/venues/" + venue + "/photos?group=checkin&limit=100"
    var url2 = "/venues/" + venue + "/photos?group=venue&limit=100"

    var urlfull = "multi?requests="
            + encodeURIComponent(url)
            + "," + encodeURIComponent(url2)
            + "&" + getAccessTokenParameter();

    doWebRequest("GET", urlfull, page, parseVenuePhotos);
}

function parseVenuePhotos(multiresponse, page) {
    var multidata = processResponse(multiresponse);
    waiting.hide();
    multidata.responses.forEach(function(response){
        var data = response.response;
        data.photos.items.forEach(function(photo){
              //console.log("PHOTO: " + JSON.stringify(photo));
              page.photosModel.append(
                  makePhoto(photo,300)
              );
          });
    });
}

function addComment(page, checkinID, text) {
    waiting.show();
    var url = "checkins/" + checkinID + "/addcomment?"
    url += "CHECKIN_ID=" + checkinID + "&";
    url += "text=" + encodeURIComponent(text) + "&";
    url += getAccessTokenParameter();
    doWebRequest("POST", url, page, parseAddComment);
}

function parseAddComment(response, page) {
    var data = processResponse(response);
    waiting.hide();
    addCommentToModel(page, data.comment);
}

function deleteComment(page, checkinID, commentID) {
    waiting.show();
    var url = "checkins/" + checkinID + "/deletecomment?"
    url += "CHECKIN_ID=" + checkinID + "&";
    url += "commentId=" + commentID + "&";
    url += getAccessTokenParameter();
    doWebRequest("POST", url, page, parseDeleteComment);
}

function parseDeleteComment(response, page) {
    var data = processResponse(response);
    waiting.hide();
    page.commentsModel.clear();
    data.checkin.comments.items.forEach(function(comment) {
        addCommentToModel(page,comment);
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
    addTipToModel(page,data.tip);
}

function markVenueToDo(venueID, text) {
    var url = "venues/" + venueID + "/marktodo?";
    if(text!="" && text.length>0) {
        url += "text=" + encodeURIComponent(text) + "&";
    }
    url += getAccessTokenParameter();
    doWebRequest("POST", url, "", doNothing);
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

function loadLeaderBoard(page) {
    var url = "users/leaderboard?" + getAccessTokenParameter();
    waiting.show();
    doWebRequest("GET", url, page, parseLeaderBoard);
}

function parseLeaderBoard(response, page) {
    waiting.hide();
    var data = processResponse(response);
    page.boardModel.clear();
    data.leaderboard.items.forEach(function(ranking) {
        page.boardModel.append({
                           "user": ranking.user.id,
                           "name": makeUserName(ranking.user),
                           "photo": thumbnailPhoto(ranking.user.photo,100),
                           "recent": ranking.scores.recent,
                           "max": ranking.scores.max,
                           "checkinsCount": ranking.scores.checkinsCount,
                           "rank": ranking.rank
        });
        if(ranking.user.relationship=="self") {
            page.rank = ranking.rank;
        }
    });
}

function loadToDo(page) {
    var url = "users/self/todos?" +
        getLocationParameter() + "&" +
        getAccessTokenParameter();
    waiting.show();
    doWebRequest("GET", url, page, parseToDo);
}

function parseToDo(response, page) {
    waiting.hide();
    var data = processResponse(response);
    page.placesModel.clear();
    data.todos.items.forEach(function(todo) {
        var place = todo.tip.venue;
        var icon = "";
        if(place.categories!=null && place.categories[0]!==undefined) {
            icon = parseIcon(place.categories[0].icon);
        } else {
            icon = parseIcon(defaultVenueIcon);
        }
        page.placesModel.append({
                           "id": place.id,
                           "name": place.name,
                           "todoComment": todo.tip.text,
                           "distance": place.location.distance,
                           "address": parse(place.location.address),
                           "city": parse(place.location.city),
                           "lat": place.location.lat,
                           "lng": place.location.lng,
                           "icon": icon,
                           "peoplesCount": 0
        });
    });
}

function likeCheckin(page, id, state) {
    //console.log("ID: " + id + " State: " + state);
    var url = "checkins/"+id+"/like?set="
    if (state) {
        url += "1";
    } else {
        url += "0";
    }
    url += "&" + getAccessTokenParameter();
    doWebRequest("POST", url, page, parseLikeCheckin);
}

function parseLikeCheckin(response, page) {
    //console.log("LIKE RESPONSE: " + JSON.stringify(response));
    var data = processResponse(response);

    processLikes(page.likeBox, data);
}

function loadCheckin(page,id) {
    waiting.show();
    var url = "checkins/" + id + "?" + getAccessTokenParameter();

    page.scoreTotal = "--";
    page.scoresModel.clear();
    page.badgesModel.clear();
    page.commentsModel.clear();
    page.photosBox.photosModel.clear();
    doWebRequest("GET",url,page,parseCheckin);
}

function parseCheckin(response, page) {
    var checkin = processResponse(response).checkin;
    //console.log("CHECKIN INFO: " + JSON.stringify(checkin) + "\n");

    page.checkinID = checkin.id;
    page.scoreTotal = checkin.score.total;
    page.owner.userID = checkin.user.id;
    page.owner.userName = makeUserName(checkin.user);
    page.owner.createdAt = makeTime(checkin.createdAt);
    page.owner.userPhoto.photoUrl = thumbnailPhoto(checkin.user.photo,100);
    page.owner.venueID = checkin.venue.id;
    page.owner.venueName = checkin.venue.name;
    page.owner.venueAddress = parse(checkin.venue.location.address);
    page.owner.venueCity = parse(checkin.venue.location.city);
    page.owner.eventOwner = parse(checkin.user.relationship);
    page.owner.userShout = parse(checkin.shout);

    checkin.score.scores.forEach(function(score) {
        //console.log("CHECKIN SCORE: " + JSON.stringify(score));
        page.scoresModel.append({
                               "scorePoints": score.points,
                               "scoreImage": score.icon,
                               "scoreMessage": score.message,
                    });
    });
    if(checkin.badges!==undefined) {
        checkin.badges.items.forEach(function(badge) {
            //console.log("CHECKIN BADGE: " + JSON.stringify(badge));
            page.badgesModel.append({
                                   "badgeTitle":badge.name,
                                   "badgeMessage":badge.description,
                                   "badgeImage":badge.image.prefix + badge.image.sizes[1] + badge.image.name})
        });
    }
    checkin.comments.items.forEach(function(comment) {
        addCommentToModel(page,comment);
    });

    if (checkin.photos.count>0) {
        checkin.photos.items.forEach(function (photo) {
            page.photosBox.photosModel.append(
                makePhoto(photo,300));
        });
    }

    processLikes(page.likeBox, checkin);

    waiting.hide();
}

function loadMayorships(page, user) {
    var url = "users/"+user + "/mayorships?" + getAccessTokenParameter();
    waiting.show();
    page.mayorshipsModel.clear();
    doWebRequest("GET", url, page, parseMayorhips);
}

function parseMayorhips(response, page) {
    var data = processResponse(response);
    waiting.hide();
    page.mayorshipsModel.clear();
    data.mayorships.items.forEach(function(mayorship){
        var place = mayorship.venue;
        //console.log("PLACE MAYORSHIP: " + JSON.stringify(mayorship))
        var icon = "";
        if(place.categories!=null && place.categories[0]!==undefined) {
            icon = parseIcon(place.categories[0].icon);
        } else {
            icon = parseIcon(defaultVenueIcon);
        }
        page.mayorshipsModel.append({
            "id": place.id,
            "name": place.name,
            "address": parse(place.location.address),
            "city": parse(place.location.city),
            "lat": place.location.lat,
            "lng": place.location.lng,
            "icon": icon,
        });
    });
}

function loadCheckinHistory(page, user) {
    var url = "users/" + user + "/checkins?limit=50&set=newestfirst&" + getAccessTokenParameter();
    waiting.show();
    page.checkinHistoryModel.clear();
    doWebRequest("GET", url, page, parseCheckinHistory);
}

function parseCheckinHistory(response, page) {
    var data = processResponse(response);
    waiting.hide();
    page.checkinHistoryModel.clear();
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
        var likesCount = 0;
        if (checkin.likes!==undefined) {
            likesCount = parse(checkin.likes.count);
        }
        var venuePhoto = "";
        if (checkin.photos.count > 0) {
            venuePhoto = thumbnailPhoto(checkin.photos.items[0], 300);
        }
        var icon = parseIcon(defaultVenueIcon);
        if (checkin.venue.categories!=null && checkin.venue.categories[0]!==undefined)
            icon = parseIcon(checkin.venue.categories[0].icon);
        page.checkinHistoryModel.append({
                           "id": checkin.id,
                           "shout": parse(checkin.shout),
                           "mayor": parse(checkin.isMayor),
                           "photo": icon,
                           "commentsCount": commentsCount,
                           "likesCount": likesCount,
                           "venueID": venueID,
                           "venueName": venueName,
                           "createdAt": createdAgo,
                           "venuePhoto": venuePhoto
        });
    });
}

function loadBadges(page,user) {
    var url = "users/" + user + "/badges?" + getAccessTokenParameter();
    waiting.show();
    page.badgeModel.clear();
    doWebRequest("GET", url, page, parseBadges);
}

function makeBadgeObject(badge){
    var venue = parse(badge.unlocks[0].checkins[0].venue);
    return {
        "name":badge.name,
        "image":makeImageUrl(badge.image,114),
        "imageLarge":makeImageUrl(badge.image,300),
        "info":badge.badgeText,
        "venueName":parse(venue.name),
        "venueID":parse(venue.id),
        "time":prettyDate(badge.unlocks[0].checkins[0].createdAt),
         };
}

function parseBadges(response, page) {
    var data = processResponse(response);
    waiting.hide();
    data.sets.groups.forEach(function(group){
         if (group.type == "all") {
             group.items.forEach(function(item){
                 var badge = data.badges[item];
                 page.badgeModel.append(makeBadgeObject(badge));
             });
         }
    });
}

function loadUser(page, user) {
    var url = "users/" + user + "?" + getAccessTokenParameter();
    waiting.show();
    page.boardModel.clear();
    page.friendsBox.photosModel.clear();
    doWebRequest("GET", url, page, parseUser);
    if (user === "self") {
        url = "users/leaderboard?neighbors=2&" + getAccessTokenParameter();
        doWebRequest("GET",url, page, parseUserBoard);
    }
}

function parseUser(response, page) {
    var data = processResponse(response);
    //console.log("USER: " + JSON.stringify(data))
    waiting.hide();
    var user = data.user;
    page.userName = makeUserName(user);
    page.userPhoto = thumbnailPhoto(user.photo,300);
    page.userPhotoLarge = thumbnailPhoto(user.photo,500);
    page.userBadgesCount = user.badges.count;
    page.userCheckinsCount = user.checkins.count;
    page.userFriendsCount = user.friends.count;
    page.userID = user.id;
    page.userMayorshipsCount = user.mayorships.count;

    if(user.checkins.items!==undefined) {
        page.lastVenueID = user.checkins.items[0].venue.id;
        page.lastVenue = user.checkins.items[0].venue.name;
        page.lastTime = makeTime(user.checkins.items[0].createdAt);
    }
    page.scoreRecent = user.scores.recent;
    page.scoreMax = user.scores.max;
    page.userRelationship = parse(user.relationship);

    if (user.friends.count>0) {
        page.friendsBox.caption = "TOTAL FRIENDS: <b>" + user.friends.count +"</b>";
        user.friends.groups.forEach(function(group) {
            if (group.type == "friends" && user.relationship != "self" ) {
                page.friendsBox.caption += " ("+ group.name + " <b>" + group.count + "</b>)";
            }
            if (group.count>0) {
                group.items.forEach(function(user){
                    page.friendsBox.photosModel.append({
                        "objectID": user.id,
                        "photoThumb": thumbnailPhoto(user.photo,100) });
                });
            }
        });

    }
}

function parseUserBoard(response, page) {
    var data = processResponse(response);
    //console.log("USER: " + JSON.stringify(data))
    data.leaderboard.items.forEach(function(ranking) {
        if (ranking.user.relationship == "self")
            page.userLeadersboardRank = ranking.rank;
            page.boardModel.append({
               "user": "#" + ranking.rank + ". " +makeUserName(ranking.user),
               "shout": "<b>"+ranking.scores.recent+" "+"points" + "</b> " + ranking.scores.checkinsCount + " " + "checkins",
               "photo": thumbnailPhoto(ranking.user.photo,100),
        });
    });
}

function addPhoto(params) {
    waiting.show();
    var url = "https://api.foursquare.com/v2/photos/add?";
    url += params.type;
    url += "Id=" + params.id;
    if (params.makepublic == "1") {
        url += "&public=1";
    }
    var broadcast = "";
    if (params.facebook) {
        broadcast = "facebook";
    }
    if (params.twitter) {
        if (broadcast!="") broadcast += ",";
        broadcast += "twitter";
    }
    if (broadcast != "") {
        url += "&broadcast="+broadcast;
    }
    url += "&" + getAccessTokenParameter();
    //console.log("PHOTOUPLOAD: "+url);
    if (!pictureHelper.upload(url, params.path, params.owner)) {
        showError("Error uploading photo!");
    }
}

function parseAddPhoto(response, page) {
    waiting.hide();
    var photo = processResponse(response).photo;    
    //console.log("ADDED PHOTO: " + JSON.stringify(photo));
    page.photosBox.photosModel.insert(0,
                makePhoto(photo,300));    
}

function loadPhoto(page, photoid) {
    var url = "photos/" + photoid + "?" + getAccessTokenParameter();
    waiting.show();
    doWebRequest("GET", url, page, parsePhoto);
}

function parsePhoto(response, page) {
    var photo = processResponse(response).photo;
    //console.log("FULL PHOTO: " + JSON.stringify(photo))
    waiting.hide();

    page.photoUrl = thumbnailPhoto(photo);
    page.owner.userID = photo.user.id;
    page.owner.userName = "<span style='color:#000'>Uploaded by </span>" + makeUserName(photo.user);
    page.owner.userPhoto.photoUrl = thumbnailPhoto(photo.user.photo,100);
    page.owner.userShout = "via " + parse(photo.source.name);
    page.owner.createdAt = makeTime(photo.createdAt);
}

function loadNotifications(page) {
    var url = "updates/notifications?" + getAccessTokenParameter();
    waiting.show();
    doWebRequest("GET",url,page, parseNotifications);
}

function markNotificationsRead(page, time) {
    var url = "updates/marknotificationsread?";
    url += "highWatermark=" + time;
    url += "&" + getAccessTokenParameter();
    page.notificationsModel.clear();
    doWebRequest("POST", url, page, doNothing);
}

function parseNotifications(response, page) {
    var notis = processResponse(response).notifications;
    //console.log("NOTIFICATIONS: " + JSON.stringify(notis));
    waiting.hide();
    notis.items.forEach(function(noti) {
        //console.log("NOTIFICATIONS: " + JSON.stringify(noti));
        var objectID = noti.target.object.id;
        if (noti.target.type == "tip")
            objectID = noti.target.object.venue.id;
        page.notificationsModel
            .append({
                        "type": noti.target.type,
                        "objectID": objectID,
                        "object": noti.target.object,
                        "userName": makeUserName("asdf"),
                        "createdAt": noti.createdAt,
                        "time": makeTime(noti.createdAt),
                        "text": noti.text,
                        "photo": noti.image.fullPath
                })
        });
}

function addFriend(page, user) {
    var url = "users/"+user+"/request?";
    url += getAccessTokenParameter();
    doWebRequest("POST",url,page, parseFriendUpdate);
}

function removeFriend(page, user) {
    var url = "users/"+user+"/unfriend?";
    url += getAccessTokenParameter();
    doWebRequest("POST",url,page, parseFriendUpdate);
}

function approveFriend(page, user) {
    var url = "users/"+user+"/approve?";
    url += getAccessTokenParameter();
    doWebRequest("POST",url,page, parseFriendUpdate);
}

function denyFriend(page, user) {
    var url = "users/"+user+"/deny?";
    url += getAccessTokenParameter();
    doWebRequest("POST",url,page, parseFriendUpdate);
}

function parseFriendUpdate(response,page) {
    var data = processResponse(response);
    page.userRelationship = parse(data.user.relationship);
}

function getUpdateInfo(updatetype, callback) {
    var os = theme.platform;
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

/*
 *
 */
.pragma library

api.log("loading api-user...");

var users = new ApiObject();
//users.debuglevel = 1;

users.loadUser = function (page, user) {
    var url = "users/" + user + "?" + getAccessTokenParameter();
    page.waiting_show();
    page.boardModel.clear();
    api.request("GET", url, page, users.parseUser);
    if (user === "self") {
        url = "users/leaderboard?neighbors=2&" + getAccessTokenParameter();
        api.request("GET",url, page, users.parseUserBoard);
    }
}

users.parseUser = function(response, page) {
    var data = api.process(response, page);
    //console.log("USER: " + JSON.stringify(data))
    page.waiting_hide();
    var user = data.user;
    page.userName = makeUserName(user);
    page.userPhoto = thumbnailPhoto(user.photo, 300, 300);
    page.userPhotoLarge = thumbnailPhoto(user.photo, 500, 500);
    page.userContactPhone = parse(user.contact.phone);
    page.userContactEmail = parse(user.contact.email);
    page.userContactTwitter = parse(user.contact.twitter);
    page.userContactFacebook = parse(user.contact.facebook);
    page.userBadgesCount = user.badges.count;
    page.userCheckinsCount = user.checkins.count;
    page.userFriendsCount = user.friends.count;
    page.userPhotosCount = user.photos.count;
    page.userTipsCount = user.tips.count;
    //page.userID = user.id; //already filled
    page.userMayorshipsCount = user.mayorships.count;

    if(user.checkins.items!==undefined) {
        page.lastVenueID = user.checkins.items[0].venue.id;
        page.lastVenue = user.checkins.items[0].venue.name;
        page.lastTime = makeTime(user.checkins.items[0].createdAt);
    }
    page.scoreRecent = user.scores.recent;
    page.scoreMax = user.scores.max;
    page.userRelationship = parse(user.relationship);
}

users.parseUserBoard = function(response, page) {
    var data = api.process(response, page);
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

users.addFriend = function(page, user) {
    var url = "users/"+user+"/request?";
    url += getAccessTokenParameter();
    api.request("POST",url,page, users.parseFriendUpdate);
}

users.removeFriend = function(page, user) {
    var url = "users/"+user+"/unfriend?";
    url += getAccessTokenParameter();
    api.request("POST",url,page, users.parseFriendUpdate);
}

users.approveFriend = function(page, user) {
    var url = "users/"+user+"/approve?";
    url += getAccessTokenParameter();
    api.request("POST",url,page, users.parseFriendUpdate);
}

users.denyFriend = function(page, user) {
    var url = "users/"+user+"/deny?";
    url += getAccessTokenParameter();
    api.request("POST",url,page, users.parseFriendUpdate);
}

users.parseFriendUpdate = function(response,page) {
    var data = api.process(response, page);
    page.userRelationship = parse(data.user.relationship);
}

users.loadLeaderBoard = function(page) {
    var url = "users/leaderboard?" + getAccessTokenParameter();
    page.waiting_show();
    api.request("GET", url, page, users.parseLeaderBoard);
}

users.parseLeaderBoard = function(response, page) {
    page.waiting_hide();
    var data = api.process(response, page);
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

users.loadUserPhotos = function(page, user) {
    page.waiting_show();

    var url = "/users/" + user + "/photos?offset="+page.options.get(0).offset+"&limit="+page.batchsize
    var urlfull = "multi?requests="
            + encodeURIComponent(url)
            + "&" + getAccessTokenParameter();

    api.request("GET", urlfull, page, users.parseUserPhotosGallery);
}

users.parseUserPhotosGallery = function(multiresponse, page) {
    var multidata = api.process(multiresponse);
    page.waiting_hide();
    for (var key in multidata.responses) {
        var data = multidata.responses[key].response;
        if (data.photos.items.length < page.batchsize) {
            page.options.get(key).completed = true;
        }
        page.options.get(key).offset += data.photos.items.length;
        page.loaded += data.photos.items.length;
        data.photos.items.forEach(function(photo){
            page.photosModel.append(
                makePhoto(photo,300)
            );
        });
    };
}

users.loadBadges = function(page,user) {
    var url = "users/" + user + "/badges?" + getAccessTokenParameter();
    page.waiting_show();
    page.badgeModel.clear();
    api.request("GET", url, page, users.parseBadges);
}

users.parseBadges = function(response, page) {
    var data = api.process(response, page);
    page.waiting_hide();
    data.sets.groups.forEach(function(group){
         if (group.type == "all") {
             group.items.forEach(function(item){
                 var badge = data.badges[item];
                 page.badgeModel.append(makeBadgeObject(badge));
             });
         }
    });
}

users.loadActivityHistory = function(page, user) {
    var url = "activities/recent?limit=800"
    page.waiting_show();
    url += "&" +getAccessTokenParameter();
    api.request("GET", url, page, function(response,page){
                     users.parseActivityHistory(response,page,user)
                 });
}

//TODO: make usage of new feed elements
users.parseActivityHistory = function(response,page,user) {
    var data = api.process(response, page);
    var activities = data.activities;
    page.waiting_hide();

    var objParser = function(checkin) {
        if (checkin.user.id !== user) return;
        var userName = makeUserName(checkin.user);
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
            venuePhoto = thumbnailPhoto(checkin.photos.items[0], 300, 300);
        }
        if (venueDistance === undefined || venueDistance < api.MAX_NEARBY_DISTANCE) {
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
                "commentsCount": checkin.comments.count,
                "likesCount": checkin.likes.count,
                "photosCount": checkin.photos.count
            };
                //console.log("adding item at end");
            page.checkinHistoryModel.append(item);
        }
    }

    activities.items.forEach(
    function(activity){
        //console.log("ACTIVITY: " + JSON.stringify(activity));
        if (activity.type !== "create") {
            console.log("ACTIVITY TYPE: " + activity.type);
            return;
        }
        var content = activity.content;
        if (content.type === "checkin") {
            objParser(content.object);
        } else if (content.type === "aggregation") {
            content.object.items.forEach(function(item) {
                if (item.type === "checkin") {
                    objParser(item.object);
                } else {
                    console.log("ITEM TYPE 2: " + item.type);
                }
            });
        } else
            console.log("CONTENT TYPE: " + content.type);
    });
}

users.loadCheckinHistory = function(page, user) {
    var url = "users/" + user + "/checkins?set=newestfirst&"
        +"offset="+page.loaded+"&limit="+page.batchsize
        +"&" + getAccessTokenParameter();
    page.waiting_show();
    api.request("GET", url, page, users.parseCheckinHistory);
}

users.parseCheckinHistory = function(response, page) {
    var data = api.process(response, page);
    page.waiting_hide();
    if (data.checkins.items.length < page.batchsize) {
        page.completed = true;
    } else {
        page.completed = false;
    }
    page.loaded += data.checkins.items.length;
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
        var photosCount = 0;
        if (checkin.photos!==undefined) {
            photosCount = parse(checkin.photos.count);
        }
        var venuePhoto = "";
        if (checkin.photos.count > 0) {
            venuePhoto = thumbnailPhoto(checkin.photos.items[0], 300, 300);
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
                           "photosCount": photosCount,
                           "venueID": venueID,
                           "venueName": venueName,
                           "createdAt": createdAgo,
                           "venuePhoto": venuePhoto
        });
    });
}

users.loadUserFriends = function(page, user) {
    page.usersModel.clear();
    page.waiting_show();
    var url = "users/" + user + "/friends?" + getAccessTokenParameter();
    api.request("GET",url,page,users.parseUsersList)
}

users.parseUsersList = function(response, page) {
    page.waiting_hide();
    var data = api.process(response, page);
    //console.log("USERS LISTS: " + JSON.stringify(data));
    data.friends.items.forEach(function(user) {
         page.usersModel.append({
            "id":user.id,
            "name":makeUserName(user),
            "city":parse(user.homeCity),
            "photo":thumbnailPhoto(user.photo,100)
        });
     });
}

users.loadMayorships = function(page, user) {
    var url = "users/"+user + "/mayorships?" + getAccessTokenParameter();
    page.waiting_show();
    page.mayorshipsModel.clear();
    api.request("GET", url, page, users.parseMayorhips);
}

users.parseMayorhips = function(response, page) {
    var data = api.process(response, page);
    page.waiting_hide();
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

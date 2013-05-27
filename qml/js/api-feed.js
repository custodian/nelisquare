/*
 *
 */
.pragma library

api.log("loading api-feed...");

var feed = new ApiObject();
//feed.debuglevel = 2;

feed.loadFriendsFeed = function(page, history) {
    //activities/recent activities/recent?afterMarker=50ade891e4b0892bb7343597
    var url = "activities/recent?"
    if (page.isUpdating)
        return;
    page.isUpdating = true;
    page.waiting_show();

    if (history!==undefined) {
        url += "beforeMarker=" + page.trailingMarker + "&";
    } else {
        if (page.leadingMarker !== "") {
            url += "afterMarker=" + page.leadingMarker + "&";
        }
    }

    if (page.nearbyPressed) {
        url += getLocationParameter() + "&";
    }

    url += "limit=" + page.batchSize + "&" +getAccessTokenParameter();
    api.request("GET", url, page, function(response,page) {
                     feed.parseFriendsFeed(response,page,history);
                 });

    if (history===undefined && page.lastUpdateTime!=="0") {
        //activities/updates ?afterTimestamp=0 & updatesAfterMarker=50ade891e4b0892bb7343597
        var url2 = "activities/updates?afterTimestamp=" + page.lastUpdateTime
        url2 += "&updatesAfterMarker=" + page.trailingMarker; //page.leadingMarker;
        url2 += "&" +getAccessTokenParameter()
        api.request("GET", url2, page, feed.parseFriendsFeedUpdate);
        //TODO: page.friendsCheckinsView.positionViewAtBeginning();
    }
}

feed.parseFriendsFeedUpdate = function(response, page) {
    var data = api.process(response, page);
    feed.debug(function(){return "UPDATES: " + JSON.stringify(data)});
    data.updates.items.forEach(
        function(update){
            if (update.type === "checkin") {
                for (var i=0;i<page.friendsCheckinsModel.count;i++) {
                    var info = page.friendsCheckinsModel.get(i).content;
                    if (info.id !== update.id)
                        continue;
                    feed.log("FOUND CHECKIN in MODEL: " + update.id);
                    info.commentsCount = update.comments.count;
                    info.comments = update.comments.items;
                    info.likesCount = update.likes.count;
                    page.updateItem(i,info);
                    break;
                }
            } else {
                feed.log("UPDATE TYPE: " + update.type);
                feed.debug(function(){ return "UPDATE CONTENT: " + JSON.stringify(update)});
                var item = {
                    "type": "feed-upd",
                    "content": data
                }
                page.addItem(item,0);
            }
        });
}

feed.parseFriendsFeed = function(response, page, history) {
    page.waiting_hide();
    page.isUpdating = false;
    var data = api.process(response, page);
    var activities = data.activities;

    var count = 0;
    var updateTime = page.lastUpdateTime;
    var updating = (updateTime !== "0");

    if (page.leadingMarker === "") {
        page.friendsCheckinsModel.clear();
    }

    if (history !== undefined || !updating) {
        feed.debug(function(){return"MORE DATA: Updated: "+ activities.moreData});
        page.moreData = activities.moreData;
    }
    if (activities.leadingMarker > page.leadingMarker)
        page.leadingMarker = activities.leadingMarker;
    if (activities.trailingMarker < page.trailingMarker || page.trailingMarker === "")
        page.trailingMarker = activities.trailingMarker;

    var feedObjParser = function(object) {
        //DBG
        //object = loaddebugobject();
        var append = (!updating || history!==undefined);
        var timeObj = object;
        if (timeObj.object !== undefined) {
            timeObj=timeObj.object;
        }

        if (updateTime <= timeObj.createdAt)
            updateTime = timeObj.createdAt;

        if (object.type === "create") {
            var create = object.content;
            if (create.type === "checkin") {
                if (feed.feedObjParserCheckin(page, object, append, count))
                    count++;
            } else if (create.type === "photo") {
                feed.feedObjParserPhoto(page,object);
            } else if (create.type === "tip") {
                object.content.summary = object.summary;
                feed.feedObjParserTip(page, object, append, count);
                count++;
            } else if (create.type === "pageUpdate") {
                feed.feedObjParserPageUpdate(page, object, append, count);
                count++;
            } else if (create.type === "aggregation"){
                object.content.object.items.forEach(function(item) {
                    object.content = item;
                    feedObjParser(object);
                });
            } else {
                feed.log("CREATE TYPE: " + create.type);
                feed.debug(function(){return "CREATE VALUE: " + JSON.stringify(object)});
                feed.feedObjParserUnknown(page, object);
                count++;
            }
        } else if (object.type === "like") {
            var like = object.content;
            if (like.type === "tip") {
                feed.feedObjParserLikeTip(page, object, append, count);
                count++;
            } else if (like.type === "venue") {
                feed.feedObjParserLikeVenue(page, object, append, count);
                count++;
            } else if (like.type === "page") {
                feed.feedObjParserLikePage(page, object, append, count);
                count++;
            } else if (like.type === "pageUpdate") {
                feed.feedObjParserLikePageUpdate(page, object, append, count);
                count++;
            } else if (like.type === "aggregation"){
                object.content.object.items.forEach(function(item) {
                    object.content = item;
                    feedObjParser(object);
                });
            } else {
                feed.log("LIKE TYPE: " + like.type);
                feed.debug(function(){return "LIKE VALUE: " + JSON.stringify(object)});
                feed.feedObjParserUnknown(page, object);
                count++;
            }
        } else if (object.type === "save") {
            var save = object.content;
            if (save.type === "activity") {
                if (save.object.content.type === "list") {
                    feed.feedObjParserSaveList(page, object, append, count);
                    count++;
                } else if (save.object.content.type === "venue") {
                    feed.feedObjParserSaveVenue(page, object, append, count);
                    count++;
                } else if (save.object.content.type === "tip") {
                    feed.feedObjParserSaveTip(page, object, append, count);
                    count++;
                } else {
                    feed.log("SAVE TYPE: " + save.type + " OBJECT: " + save.object.content.type);
                    feed.debug(function(){return "SAVE VALUE: " + JSON.stringify(object)});
                    feed.feedObjParserUnknown(page, object);
                    count++;
                }
            } else if (save.type === "aggregation"){
                object.content.object.items.forEach(function(item) {
                    object.content = item;
                    feedObjParser(object);
                });
            } else {
                feed.log("SAVE TYPE: " + save.type);
                feed.debug(function(){return "SAVE VALUE: " + JSON.stringify(object)});
                feed.feedObjParserUnknown(page, object);
                count++;
            }
        } else if (object.type === "install") {
            var install = object.content;
            if (install.type === "plugin") {
                feed.feedObjParserInstallPlugin(page, object, append, count);
                count++;
            } else {
                feed.log("INSTALL TYPE: " + install.type);
                feed.debug(function(){return "SAVE VALUE: " + JSON.stringify(object)});
                feed.feedObjParserUnknown(page, object);
                count++;
            }
        } else if (object.type === "award") {
            var award = object.content;
            if (award.type === "badge") {
                feed.feedObjParserAwardBadge(page, object, append, count);
                count++;
            } else {
                feed.log("AWARD TYPE: " + award.type);
                feed.debug(function(){return "SAVE VALUE: " + JSON.stringify(object)});
                feed.feedObjParserUnknown(page, object);
                count++;
            }
        } else if (object.type === "friend" ) {
            feed.feedObjParserFriend(page, object, append, count);
            count++;
        } else {
            //un implemented content types goes here
            feed.log("CONTENT TYPE: " + object.type);
            feed.debug(function(){return "CONTENT VALUE: " + JSON.stringify(object)});
            feed.feedObjParserUnknown(page, object);
            count++;
        }
    }

    activities.items.forEach(feedObjParser);

    if (!updating) {
        page.timerFeedUpdate.restart();
    } else {
        //Limit all checkins //TODO: Make options at settings of feed length
        if (history===undefined) {
            var currentsize = page.friendsCheckinsModel.count;
            for (var i=api.MAX_FEED_SIZE;i<currentsize;i++){
                page.removeItem(api.MAX_FEED_SIZE);
                page.moreData = true;
            }
            if (currentsize>(api.MAX_FEED_SIZE-1))
                page.trailingMarker = page.friendsCheckinsModel.get(api.MAX_FEED_SIZE-1).content.id;
        }
        //rotate times and dates
        //get content, replace, put back
        for (var i=0;i<page.friendsCheckinsModel.count;i++){
            var info = page.friendsCheckinsModel.get(i).content;
            info.createdAt = makeTime(info.timestamp);
            page.friendsCheckinsModel.set(i,{"content":info});
        }
    }
    page.lastUpdateTime = updateTime;
}

feed.feedObjParserUnknown = function(page, object) {
    var item = {
                "type": object.type,
                "content": object
    }
    page.addItem(item);
}

feed.feedObjParserCheckin = function(page, object, append, count) {
    var checkin = object.content.object;
    var result = true;
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
            "type": "checkin",
            "content": {
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
                "comments": checkin.comments.items,
                "likesCount": checkin.likes.count,
                "photosCount": checkin.photos.count
            }
        };
        if (append) {
            feed.debug(function(){return "adding checkin at end"});
            page.addItem(item);
        } else {
            page.addItem(item,count);
            feed.debug(function(){return "adding checkin at head"});
        }
        result = true;
    } else if (venueDistance !== undefined) {
        result = false;
    }
    return result;
}

feed.feedObjParserPhoto = function(page, object) {
    var photo = object.content.object;
    feed.debug(function(){return "NEW PHOTO: " + JSON.stringify(photo) });
    for (var i=0;i<page.friendsCheckinsModel.count;i++) {
        var info = page.friendsCheckinsModel.get(i).content;
        if (info.id !== photo.checkin.id)
            continue;
        feed.log("UPDATE CHECKIN PHOTO: " + photo.checkin.id);
        info.photosCount++;
        info.venuePhoto = thumbnailPhoto(photo,300,300);
        page.updateItem(i,info);
        break;
    }
}

feed.feedObjParserFriend = function(page, friend, append, count) {
    if (friend.content.type === "aggregation") {
        //TODO: change if aggregation will be enabled
        feed.log("FRIEND AGGREGATION!")
        feed.debug(function(){return "FRIEND AGGREGATION: " + JSON.stringify(friend)});
        friend.content.object.id = friend.thumbnails[0].id;
    }
    feed.debug(function(){return "FRIEND CONTENT: " + JSON.stringify(friend)});
    var item = {
        "type": friend.type,
        "content": {
            "id": friend.content.object.id,
            "user": friend.summary.text,
            "createdAt": makeTime(friend.createdAt),
            "timestamp": friend.createdAt,
        }
    };
    if (append) {
        feed.debug(function(){return "adding friend at end"});
        page.addItem(item);
    } else {
        feed.debug(function(){return "adding friend at head"});
        page.addItem(item,count);
    }
}

feed.feedObjParserTip = function(page, object, append, count) {
    var tip = object.content.object;
    feed.debug(function(){return "TIP CONTENT: " + JSON.stringify(object)});
    var icon = "";
    if (tip.venue.categories[0] !== undefined)
        icon = parseIcon(tip.venue.categories[0].icon);
    else
        icon = parseIcon(defaultVenueIcon);

    var item = {
        "type": "tip",
        "content": {
            "id": tip.id,
            "userName": object.summary.text,
            "shout": tip.text,
            "venueName": tip.venue.name,
            "photo": icon,
            "likesCount": tip.likes.count,
            "venuePhoto": thumbnailPhoto(tip.photo, 300, 300),
            "createdAt": makeTime(tip.createdAt),
            "timestamp": tip.createdAt,
        }
    }
    if (append) {
        feed.debug(function(){return "adding friend at end"});
        page.addItem(item);
    } else {
        feed.debug(function(){return "adding friend at head"});
        page.addItem(item,count);
    }
}

feed.feedObjParserLikeTip = function(page, object, append, count) {
    var tip = object.content.object;
    feed.debug(function(){return "LIKE TIP CONTENT: " + JSON.stringify(object)});
    var icon = "";
    if (tip.venue.categories[0] !== undefined)
        icon = parseIcon(tip.venue.categories[0].icon);
    else
        icon = parseIcon(defaultVenueIcon);

    var item = {
        "type": "tip",
        "content": {
            "id": tip.id,
            "userName": object.summary.text,
            "shout": tip.text,
            "venueName": "",
            "photo": icon,
            "likesCount": tip.likes.count,
            "venuePhoto": thumbnailPhoto(tip.photo, 300, 300),
            "createdAt": makeTime(object.createdAt),
            "timestamp": object.createdAt,
        }
    }
    if (append) {
        feed.debug(function(){return "adding friend at end"});
        page.addItem(item);
    } else {
        feed.debug(function(){return "adding friend at head"});
        page.addItem(item,count);
    }
};

feed.feedObjParserLikePage = function(owner, object, append, count) {
    var page = object.content.object
    var item = {
        "type": "likepage",
        "content": {
            "id": page.id,
            "userName": object.summary.text,
            "likesCount": "0",
            "commentsCount": page.tips.count,
            "peoplesCount": page.followers.count,
            "shout": page.pageInfo.description,
            "photo": object.thumbnails[0].photo,
            "venuePhoto": thumbnailPhoto(page.photo, 300, 300),
            "createdAt": makeTime(object.createdAt),
            "timestamp": object.createdAt,
        }
    }
    if (append) {
        feed.debug(function(){return "adding friend at end"});
        owner.addItem(item);
    } else {
        feed.debug(function(){return "adding friend at head"});
        owner.addItem(item,count);
    }
}

feed.feedObjParserLikePageUpdate = function(owner, object, append, count) {
    //TODO: likepageupdate
    feed.feedObjParserPageUpdate(owner, object, append, count);
}

feed.feedObjParserPageUpdate = function(owner, object, append, count) {
    var pageupdate = object.content.object;

    var venuePhoto = "";
    if (pageupdate.photos.count > 0) {
        venuePhoto = thumbnailPhoto(pageupdate.photos.items[0], 300, 300);
    }
    var followersCount = "0";
    if (pageupdate.page.followers!==undefined)
        followersCount = pageupdate.page.followers.count;
    var item = {
        "type": "pageupdate",
        "content": {
            "id": pageupdate.id,
            "userName": object.summary.text,
            "photo": object.thumbnails[0].photo,
            "likesCount": pageupdate.likes.count,
            "commentsCount": pageupdate.page.tips.count,
            "peoplesCount": followersCount,
            "shout": pageupdate.shout,
            "venuePhoto": venuePhoto,
            "createdAt": makeTime(object.createdAt),
            "timestamp": object.createdAt,
        }
    }
    if (append) {
        feed.debug(function(){return "adding friend at end"});
        owner.addItem(item);
    } else {
        feed.debug(function(){return "adding friend at head"});
        owner.addItem(item,count);
    }
}

feed.feedObjParserAwardBadge = function(page, object, append, count) {
    var badge = object.content.object;
    feed.debug(function(){return "AWARD BADGE CONTENT: " + JSON.stringify(object)});
    var item = {
        "type": "awardbadge",
        "content": {
            "id": badge.id,
            "userName": object.summary.text,
            "photo": object.thumbnails[0].photo,
            "shout": badge.badgeText,
            "venuePhoto": makeImageUrl(badge.image,300),
            "badge": badge,
            "createdAt": makeTime(object.createdAt),
            "timestamp": object.createdAt,
        }
    }
    if (append) {
        feed.debug(function(){return "adding friend at end"});
        page.addItem(item);
    } else {
        feed.debug(function(){return "adding friend at head"});
        page.addItem(item,count);
    }
}

feed.feedObjParserLikeVenue = function(page, object, append, count) {
    var venue = object.content.object;
    feed.debug(function(){return "LIKE VENUE CONTENT: " + JSON.stringify(object)});
    var icon = "";
    if (venue.categories[0] !== undefined)
        icon = parseIcon(venue.categories[0].icon);
    else
        icon = parseIcon(defaultVenueIcon);

    var item = {
        "type": "likevenue",
        "content": {
            "id": venue.id,
            "userName": object.summary.text,
            "venueCity": parse(venue.location.city),
            "photo": icon,
            "likesCount": venue.likes.count,
            "createdAt": makeTime(object.createdAt),
            "timestamp": object.createdAt,
        }
    }
    if (append) {
        feed.debug(function(){return "adding friend at end"});
        page.addItem(item);
    } else {
        feed.debug(function(){return "adding friend at head"});
        page.addItem(item,count);
    }
};

feed.feedObjParserSaveTip = function(page, object, append, count) {
    var tip = object.content.object.content.object;
    feed.debug(function(){return "SAVE TIP CONTENT: " + JSON.stringify(object)});
    var icon = "";
    if (tip.venue.categories[0] !== undefined)
        icon = parseIcon(tip.venue.categories[0].icon);
    else
        icon = parseIcon(defaultVenueIcon);

    var item = {
        "type": "savetip",
        "content": {
            "id": tip.id,
            "userName": object.summary.text,
            "shout": tip.text,
            "venueName": tip.venue.name,
            "photo": icon,
            "likesCount": tip.likes.count,
            "venuePhoto": thumbnailPhoto(tip.photo, 300, 300),
            "createdAt": makeTime(object.createdAt),
            "timestamp": object.createdAt,
        }
    }
    if (append) {
        feed.debug(function(){return "adding friend at end"});
        page.addItem(item);
    } else {
        feed.debug(function(){return "adding friend at head"});
        page.addItem(item,count);
    }
};

feed.feedObjParserSaveList = function (page, object, append, count) {
    var list = object.content.object.content.object;
    feed.debug(function(){return "LIST: " + JSON.stringify(list)});
    var item = {
        "type": "savelist",
        "content": {
            "id": list.id,
            "photo": object.thumbnails[0].photo,
            "user": object.summary.text,
            "listName": list.name,
            "shout": list.description,
            "venuePhoto": thumbnailPhoto(list.photo, 300, 300),
            "likesCount": list.followers.count,
            "createdAt": makeTime(object.createdAt),
            "timestamp": object.createdAt,
        }
    }
    if (append) {
        feed.debug(function(){return "adding friend at end"});
        page.addItem(item);
    } else {
        feed.debug(function(){return "adding friend at head"});
        page.addItem(item,count);
    }
}

feed.feedObjParserSaveVenue = function (page, object, append, count) {
    var venue = object.content.object.content.object;
    feed.debug(function(){return "SAVE VENUE CONTENT: " + JSON.stringify(object.content.object)});
    var icon = "";
    if (venue.categories[0] !== undefined)
        icon = parseIcon(venue.categories[0].icon);
    else
        icon = parseIcon(defaultVenueIcon);

    var item = {
        "type": "savevenue",
        "content": {
            "id": venue.id,
            "userName": object.summary.text,
            "venueCity": venue.name,
            "photo": icon,
            "likesCount": venue.likes.count,
            "createdAt": makeTime(object.createdAt),
            "timestamp": object.createdAt,
        }
    }
    if (append) {
        feed.debug(function(){return "adding friend at end"});
        page.addItem(item);
    } else {
        feed.debug(function(){return "adding friend at head"});
        page.addItem(item,count);
    }
}

feed.feedObjParserInstallPlugin = function(page, object, append, count) {
    var plugin = object.content.object;
    feed.debug(function(){return "PLUGIN: " + JSON.stringify(plugin)});
    var item = {
        "type": "installplugin",
        "content": {
            "id": plugin.id,
            "userName": object.summary.text,
            "venueName": plugin.name,
            "photo": plugin.icon,
            "venuePhoto": plugin.banner,
            "shout": plugin.tagline,
            "url": plugin.detailUrl,
            "createdAt": makeTime(object.createdAt),
            "timestamp": object.createdAt,
        }
    };
    if (append) {
        feed.debug(function(){return "adding friend at end"});
        page.addItem(item);
    } else {
        feed.debug(function(){return "adding friend at head"});
        page.addItem(item,count);
    }
}

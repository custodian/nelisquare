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
                feed.log("UPDATE CONTENT: " + JSON.stringify(update));
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
        var append = (!updating || history!==undefined);

        var timeObj = object;
        if (timeObj.object !== undefined)
            timeObj=timeObj.object;
        if (updateTime <= timeObj.createdAt)
            updateTime = timeObj.createdAt;
        if (object.type === "checkin") {
            if (feed.feedObjParserCheckin(page, object.object, append, count))
                count++;
        } else if (object.type === "photo") {
            feed.feedObjParserPhoto(page,object.object);
        } else if (object.type === "friend" ) {
            feed.feedObjParserFriend(page, object, append, count);
            count++;
        } else if (object.type === "tip") {
            feed.feedObjParserTip(page, object, append, count);
            count++;
        } else if (object.type === "like") {
            var like = object.content;
            if (like.type === "tip") {
                feed.feedObjParserLikeTip(page, object, append, count);
                count++;
            } else {
                feed.log("LIKE TYPE: " + like.type);
                feed.debug(function(){return "LIKE VALUE: " + JSON.stringify(object)});
                feed.feedObjParserUnknown(page, object);
            }
        } else if (object.type === "save") {
            var save = object.content;
            if (save.type === "activity") {
                if (save.object.content.type === "list") {
                    feed.feedObjParserSaveList(page, object, append, count);
                    count++;
                } else {
                    feed.log("SAVE TYPE: " + save.type + " OBJECT: " + save.object.content.type);
                    feed.debug(function(){return "SAVE VALUE: " + JSON.stringify(object)});
                    feed.feedObjParserUnknown(page, object);
                }
            } else {
                feed.log("SAVE TYPE: " + save.type);
                feed.debug(function(){return "SAVE VALUE: " + JSON.stringify(object)});
                feed.feedObjParserUnknown(page, object);
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
            }
        } else {
            //un implemented content types goes here
            feed.log("CONTENT TYPE: " + object.type);
            feed.debug(function(){return "CONTENT VALUE: " + JSON.stringify(object)});
            feed.feedObjParserUnknown(page, object);
            count++;
        }
    }

    activities.items.forEach(
    function(activity){
        feed.debug(function(){return "ACTIVITY: " + JSON.stringify(activity)});
        if (activity.type === "create") {
            //TODO: pass real activity for create. not a content;
            var content = activity.content;

            if (content.type === "tip") {
                content.summary = activity.summary;
            }

            if (content.type === "aggregation") {
                feed.log("CREATE AGGREGATION!");
                content.object.items.forEach(function(item) {
                    //TODO: move general parts from activity to content to get
                    //now just copy, looks weird on tips
                    item.summary = activity.summary;
                    feedObjParser(item);
                });
            } else {
                feedObjParser(content);
            }
        } else if (activity.type === "friend") {
            feedObjParser(activity);
        } else if (activity.type === "like") {
            feedObjParser(activity);
        } else if (activity.type === "save") {
            feedObjParser(activity);
        } else if (activity.type === "install") {
            feedObjParser(activity);
        }else {
            //un implemented events goes here
            feed.log("ACTIVITY TYPE: " + activity.type);
            feed.log(function(){return "ACTIVITY CONTENT: " + JSON.stringify(activity)}());
            feed.feedObjParserUnknown(page, object);
            count++;
        }
    });

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

feed.feedObjParserCheckin = function(page, checkin, append, count) {
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

feed.feedObjParserPhoto = function(page, photo) {
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
    var tip = object.object;
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

/*
 *
 */
.pragma library

api.log("loading api-feed...");

var feed = new ApiObject();
//feed.debuglevel = 1;

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
    }
}

feed.parseFriendsFeedUpdate = function(response, page) {
    var data = api.process(response, page);
    feed.log("UPDATES: " + JSON.stringify(data));
    data.updates.items.forEach(
        function(update){
            if (update.type === "checkin") {
                for (var i=0;i<page.friendsCheckinsModel.count;i++) {
                    if (page.friendsCheckinsModel.get(i).id !== update.id)
                        continue;
                    feed.log("FOUND CHECKIN in MODEL: " + update.id);
                    page.updateItem(i,
                        {
                        "commentsCount": update.comments.count,
                        "likesCount": update.likes.count
                        }
                    );

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
        feed.log("MORE DATA: Updated: "+ activities.moreData);
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
            //TODO: make show tip
            /*
            page.loaded -= 1;
            */
            //DBG: testing loader
            var itemtest = {
                "type": object.type
            }
            page.addItem(itemtest);

            feed.debug("TIP EVENT VALUE: " + JSON.stringify(object));
        } else {
            page.loaded -= 1;
            feed.log("CONTENT TYPE: " + object.type);
            feed.log("CONTENT VALUE: " + JSON.stringify(object));
        }
    }

    page.loaded += activities.items.length;
    activities.items.forEach(
    function(activity){
        feed.debug("ACTIVITY: " + JSON.stringify(activity));
        if (activity.type === "create") {
            var content = activity.content;

            if (content.type === "aggregation") {
                page.loaded -= 1;
                page.loaded += content.object.items.length;
                content.object.items.forEach(function(item) {
                    feedObjParser(item);
                });
            } else {
                feedObjParser(content);
            }
        } else if (activity.type === "friend") {
            feedObjParser(activity);
        } else {
            /*
            page.loaded -= 1;
            */
            //DBG: testing loader
            var itemtest = {
                "id": "",
                "type": activity.type
            }
            page.addItem(itemtest);

            feed.log("ACTIVITY TYPE: " + activity.type);
            feed.debug("ACTIVITY CONTENT: " + JSON.stringify(activity.content));
            return;
        }
    });

    if (!updating) {
        page.timerFeedUpdate.restart();
    } else {
        //Limit all checkins //TODO: Make options at settings of feed length
        if (history===undefined) {
            var currentsize = page.friendsCheckinsModel.count;
            var maxsize = 100;
            for (var i=maxsize;i<currentsize;i++){
                page.removeItem(maxsize);
                page.loaded -= 1;
                page.moreData = true;
            }
            if (currentsize>(maxsize-1))
                page.trailingMarker = page.friendsCheckinsModel.get(maxsize-1).id;
        }
        for (var i=0;i<page.friendsCheckinsModel.count;i++){
            page.friendsCheckinsModel.setProperty(i,"createdAt", makeTime(page.friendsCheckinsModel.get(i).timestamp));
        }
    }
    page.lastUpdateTime = updateTime;
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
    if (venueDistance === undefined || venueDistance < MAX_NEARBY_DISTANCE) {
        var item = {
            "id": checkin.id,
            "type": "checkin",
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
        if (append) {
            feed.debug("adding checkin at end");
            page.addItem(item);
        } else {
            page.addItem(item,count);
            feed.debug("adding checkin at head");
        }
        result = true;
    } else if (venueDistance !== undefined) {
        page.loaded -= 1;
        result = false;
    }
    return result;
}

feed.feedObjParserPhoto = function(page, photo) {
    feed.debug("NEW PHOTO: " + JSON.stringify(photo) );
    for (var i=0;i<page.friendsCheckinsModel.count;i++) {
        if (page.friendsCheckinsModel.get(i).id !== photo.checkin.id)
            continue;
        feed.log("UPDATE CHECKIN PHOTO: " + photo.checkin.id);
        var photosCount = page.friendsCheckinsModel.get(i).photosCount;
        photosCount++;
        page.updateItem(i,
            {
            "venuePhoto": thumbnailPhoto(photo,300,300),
            "photosCount": photosCount,
            }
        );

        break;
    }
}

feed.feedObjParserFriend = function(page, friend, append, count) {
    if (friend.content.type === "aggregation") {
        //TODO: change if aggregation will be enabled
        //page.loaded -= 1;
        //page.loaded -= friend.content.object.items.length;
    }
    var item = {
        "id": "",
        "type": friend.type,
        "shout": "",
        "user": friend.summary.text,
        "userID": friend.content.object.id,
        "mayor": false,
        "photo": friend.thumbnails[0].photo,
        "venueID": "",
        "venueName": "",
        "createdAt": makeTime(friend.createdAt),
        "timestamp": friend.createdAt,
        "venuePhoto": "",
        "commentsCount": "0",
        "likesCount": "0",
        "photosCount": "0"
    };
    if (append) {
        feed.debug("adding friend at end");
        page.addItem(item);
    } else {
        feed.debug("adding friend at head");
        page.addItem(item,count);
    }
}

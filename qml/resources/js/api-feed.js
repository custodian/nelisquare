/*
 *
 */
Qt.include("api.js")

function loadFriendsFeed(page, history) {
    //activities/recent activities/recent?afterMarker=50ade891e4b0892bb7343597
    var url = "activities/recent?"
    waiting.show();

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
    doWebRequest("GET", url, page, function(response,page) {
                     parseFriendsFeed(response,page,history);
                 });

    if (history===undefined && page.lastUpdateTime!=="0") {
        //activities/updates ?afterTimestamp=0 & updatesAfterMarker=50ade891e4b0892bb7343597
        //doWebRequest();
        var url2 = "activities/updates?afterTimestamp=" + page.lastUpdateTime
        url2 += "&updatesAfterMarker=" + page.trailingMarker; //page.leadingMarker;
        url2 += "&" +getAccessTokenParameter()
        doWebRequest("GET", url2, page, parseFriendsFeedUpdate);
    }
}

function parseFriendsFeedUpdate(response, page) {
    var data = processResponse(response);
    //console.log("UPDATES: " + JSON.stringify(data));
    data.updates.items.forEach(
        function(update){
            if (update.type === "checkin") {
                for (var i=0;i<page.friendsCheckinsModel.count;i++) {
                    if (page.friendsCheckinsModel.get(i).id !== update.id)
                        continue;
                    console.log("FOUND CHECKIN in MODEL: " + update.id);
                    page.friendsCheckinsModel.set(i,
                        {
                        "commentsCount": update.comments.count,
                        "likesCount": update.likes.count
                        }
                    );

                    break;
                }
            } else {
                console.log("UPDATE TYPE: " + update.type);
                console.log("UPDATE CONTENT: " + JSON.stringify(update));
            }
        });
}

function parseFriendsFeed(response, page, history) {
    waiting.hide();
    var data = processResponse(response);
    var activities = data.activities;

    var count = 0;
    var updateTime = page.lastUpdateTime;
    var updating = (updateTime !== "0");

    if (page.leadingMarker === "") {
        page.friendsCheckinsModel.clear();
    }

    if (history !== undefined || !updating) {
        //console.log("MORE DATA: Updated: "+ activities.moreData);
        page.moreData = activities.moreData;
    }
    if (activities.leadingMarker > page.leadingMarker)
        page.leadingMarker = activities.leadingMarker;
    if (activities.trailingMarker < page.trailingMarker || page.trailingMarker === "")
        page.trailingMarker = activities.trailingMarker;

    var feedObjParser = function(object) {
        if (updateTime <= object.object.createdAt)
            updateTime = object.object.createdAt;
        if (object.type === "checkin") {
            var append = (!updating || history!==undefined);
            feedObjParserCheckin(page, object.object, append, count);
            count++;
        } else if (object.type === "photo") {
            feedObjParserPhoto(page,object.object);
        } else {
            page.loaded -= 1;
            console.log("CONTENT TYPE: " + object.type);
            console.log("CONTENT VALUE: " + JSON.stringify(object));
        }
    }

    page.loaded += activities.items.length;
    activities.items.forEach(
    function(activity){
        //console.log("ACTIVITY: " + JSON.stringify(activity));
        if (activity.type !== "create") {
            page.loaded -= 1;
            console.log("ACTIVITY TYPE: " + activity.type);
            return;
        }
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
    });

    if (!updating) {
        //TODO: enable
        page.timerFeedUpdate.restart();
    } else {
        //Limit all checkins //TODO: Make options at settings of feed length
        if (history===undefined) {
            var currentsize = page.friendsCheckinsModel.count;
            for (var i=100;i<currentsize;i++){
                page.friendsCheckinsModel.remove(100);
                page.loaded -= 1;
                page.moreData = true;
            }
            if (currentsize>99)
                page.trailingMarker = page.friendsCheckinsModel.get(99).id;
        }
        for (var i=0;i<page.friendsCheckinsModel.count;i++){
            page.friendsCheckinsModel.setProperty(i,"createdAt", makeTime(page.friendsCheckinsModel.get(i).timestamp));
        }
    }
    page.lastUpdateTime = updateTime;
}

function feedObjParserCheckin(page, checkin, append, count) {
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
            //console.log("adding item at end");
            page.friendsCheckinsModel.append(item);
        } else {
            //console.log("adding item at head");
            page.friendsCheckinsModel.insert(count,item)
        }
    }
}

function feedObjParserPhoto(page, photo) {
    //console.log("NEW PHOTO: " + JSON.stringify(photo) );
    for (var i=0;i<page.friendsCheckinsModel.count;i++) {
        if (page.friendsCheckinsModel.get(i).id !== photo.checkin.id)
            continue;
        //console.log("UPDATE CHECKIN PHOTO: " + photo.checkin.id);
        var photosCount = page.friendsCheckinsModel.get(i).photosCount;
        photosCount++;
        page.friendsCheckinsModel.set(i,
            {
            "venuePhoto": thumbnailPhoto(photo,300,300),
            "photosCount": photosCount,
            }
        );

        break;
    }
}

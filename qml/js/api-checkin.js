/*
 *
 */

.pragma library

api.log("loading api-checkin...");

var checkin = new ApiObject();
//checkin.debuglevel = 1;


checkin.loadCheckin = function(page,id) {
    page.waiting_show();
    var url = "checkins/" + id + "?" + getAccessTokenParameter();

    page.scoreTotal = "--";
    page.scoresModel.clear();
    page.badgesModel.clear();
    page.commentsModel.clear();
    page.photosBox.photosModel.clear();
    api.request("GET",url,page,checkin.parseCheckin);
}

checkin.parseCheckin = function(response, page) {
    var checkinobj = api.process(response, page).checkin;
    //console.log("CHECKIN INFO: " + JSON.stringify(checkin) + "\n");

    page.checkinID = checkinobj.id;
    page.scoreTotal = checkinobj.score.total;
    page.owner.userID = checkinobj.user.id;
    page.owner.userName = makeUserName(checkinobj.user);
    page.owner.createdAt = makeTime(checkinobj.createdAt);
    page.owner.userPhoto.photoUrl = thumbnailPhoto(checkinobj.user.photo,100);
    page.owner.venueID = checkinobj.venue.id;
    page.owner.venueName = checkinobj.venue.name;
    page.owner.venueAddress = parse(checkinobj.venue.location.address);
    page.owner.venueCity = parse(checkinobj.venue.location.city);
    page.owner.eventOwner = parse(checkinobj.user.relationship);
    page.owner.userShout = parse(checkinobj.shout);

    checkinobj.score.scores.forEach(function(score) {
        //console.log("CHECKIN SCORE: " + JSON.stringify(score));
        page.scoresModel.append({
                               "scorePoints": score.points,
                               "scoreImage": score.icon,
                               "scoreMessage": score.message,
                    });
    });
    if(checkinobj.badges!==undefined) {
        checkinobj.badges.items.forEach(function(badge) {
            //console.log("CHECKIN BADGE: " + JSON.stringify(badge));
            page.badgesModel.append({
                                   "badgeTitle":badge.name,
                                   "badgeMessage":badge.description,
                                   "badgeImage":badge.image.prefix + badge.image.sizes[1] + badge.image.name})
        });
    }
    checkinobj.comments.items.forEach(function(comment) {
        addCommentToModel(page,comment);
    });

    if (checkinobj.photos.count>0) {
        checkinobj.photos.items.forEach(function (photo) {
            page.photosBox.photosModel.append(
                makePhoto(photo,300));
        });
    }

    processLikes(page.likeBox, checkinobj);

    page.waiting_hide();
}

checkin.likeCheckin = function(page, id, state) {
    //console.log("ID: " + id + " State: " + state);
    var url = "checkins/"+id+"/like?set="
    if (state) {
        url += "1";
    } else {
        url += "0";
    }
    url += "&" + getAccessTokenParameter();
    api.request("POST", url, page, checkin.parseLikeCheckin);
}

checkin.parseLikeCheckin = function(response, page) {
    //console.log("LIKE RESPONSE: " + JSON.stringify(response));
    var data = api.process(response, page);

    processLikes(page.likeBox, data);
}

checkin.addCheckin = function(venueID, page, comment, friends, facebook, twitter) {
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
    api.request("POST", url, page, checkin.parseAddCheckin);
}

checkin.parseAddCheckin = function(response, page) {
    var data = api.process(response, page);
    var message = "<span>";
    var specials = {};
    specials.type = "aftercheckin";
    specials.items = [];
    data.notifications.forEach(function(noti) {
        //console.log("NOTIFICATION: "+ JSON.stringify(noti));
        if(noti.item.message!==undefined) {
            if(message.length>6) {
                message += "<br/><br/>";
            }
            message += noti.item.message;
            if (noti.type === "tip") {
                message += "<br/>" + noti.item.tip.text;
            } else if (noti.type === "specials"){
                console.log("SPECIALS: " + JSON.stringify(noti));
                specials.items.push(noti);
            } else {
                console.log("TODO: NOTI TYPE: " + JSON.stringify(noti));
            }
            //TODO: add specials support info
        }
    });
    message += "</span>";

    page.checkinCompleted(data.checkin.id, message, specials);
}

checkin.addComment = function(page, checkinID, text) {
    page.waiting_show();
    var url = "checkins/" + checkinID + "/addcomment?"
    url += "CHECKIN_ID=" + checkinID + "&";
    url += "text=" + encodeURIComponent(text) + "&";
    url += getAccessTokenParameter();
    api.request("POST", url, page, checkin.parseAddComment);
}

checkin.parseAddComment = function(response, page) {
    var data = api.process(response, page);
    page.waiting_hide();
    addCommentToModel(page, data.comment);
}


checkin.deleteComment = function(page, checkinID, commentID) {
    page.waiting_show();
    var url = "checkins/" + checkinID + "/deletecomment?"
    url += "CHECKIN_ID=" + checkinID + "&";
    url += "commentId=" + commentID + "&";
    url += getAccessTokenParameter();
    api.request("POST", url, page, checkin.parseDeleteComment);
}

checkin.parseDeleteComment = function(response, page) {
    var data = api.process(response, page);
    page.waiting_hide();
    page.commentsModel.clear();
    data.checkin.comments.items.forEach(function(comment) {
        addCommentToModel(page,comment);
    });
}

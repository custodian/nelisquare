/*
 *
 */

Qt.include("api.js")

function loadCheckin(page,id) {
    page.waiting_show();
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

    page.waiting_hide();
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
    var data = processResponse(response, page);

    processLikes(page.likeBox, data);
}

function addCheckin(venueID, page, comment, friends, facebook, twitter) {
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
    doWebRequest("POST", url, page, parseAddCheckin);
}

function parseAddCheckin(response, page) {
    var data = processResponse(response, page);
    var message = "<span>";
    data.notifications.forEach(function(noti) {
        //console.log("NOTIFICATION: "+ JSON.stringify(noti));
        if(noti.item.message!==undefined) {
            if(message.length>6) {
                message += "<br/><br/>";
            }
            message += noti.item.message;
            if (noti.type == "tip") {
                message += "<br/>" + noti.item.tip.text;
            } else {
                console.log("TODO: checkin noti info: " + JSON.stringify(noti));
            }
            //TODO: add specials support info
        }
    });
    message += "</span>";

    page.checkinCompleted(data.checkin.id, message);
}

function addComment(page, checkinID, text) {
    page.waiting_show();
    var url = "checkins/" + checkinID + "/addcomment?"
    url += "CHECKIN_ID=" + checkinID + "&";
    url += "text=" + encodeURIComponent(text) + "&";
    url += getAccessTokenParameter();
    doWebRequest("POST", url, page, parseAddComment);
}

function parseAddComment(response, page) {
    var data = processResponse(response, page);
    page.waiting_hide();
    addCommentToModel(page, data.comment);
}


function deleteComment(page, checkinID, commentID) {
    page.waiting_show();
    var url = "checkins/" + checkinID + "/deletecomment?"
    url += "CHECKIN_ID=" + checkinID + "&";
    url += "commentId=" + commentID + "&";
    url += getAccessTokenParameter();
    doWebRequest("POST", url, page, parseDeleteComment);
}

function parseDeleteComment(response, page) {
    var data = processResponse(response, page);
    page.waiting_hide();
    page.commentsModel.clear();
    data.checkin.comments.items.forEach(function(comment) {
        addCommentToModel(page,comment);
    });
}

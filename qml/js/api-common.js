/*
 * Foursquare API bindings
 */

.pragma library

api.log("loading api-common...");

function parse(item) {
    if(item!==undefined) {
        return item;
    } else {
        return "";
    }
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
    if (photo) {
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
    }
    return url;
}

function makePhoto(photo,minsize) {
    return {
       "objectID": photo.id,
       "photoThumb":thumbnailPhoto(photo,minsize,minsize)
   }
}

function parseIcon(icon, size) {
    if (size === undefined) {
        size = 32
    }
    return icon.prefix+((api.inverted)?"":"bg_")+size+icon.suffix;
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

function addTipToModel(page,tip) {
    //console.log("VENUE TIP: " + JSON.stringify(tip));
    page.tipsModel.append({
                     "userID": tip.user.id,
                     "userName": makeUserName(tip.user),
                     "userPhoto": thumbnailPhoto(tip.user.photo,100),
                     "tipID": tip.id,
                     "tipText": tip.text,
                     "tipAge": "Added " + makeTime(tip.createdAt),
                     "tipPhoto": thumbnailPhoto(tip.photo, 300, 300),
                     "venueName": parse(tip.venueName),
                     "likesCount": tip.likes.count,
                     "peoplesCount": ((tip.done)?tip.done.count:tip.todo.count),
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

function makeBadgeObject(badge){
    var venue = parse(badge.unlocks[0].checkins[0].venue);
    //console.log("badge date: " + badge.unlocks[0].checkins[0].createdAt);
    return {
        "name":badge.name,
        "image":makeImageUrl(badge.image,114),
        "imageLarge":makeImageUrl(badge.image,300),
        "info":badge.badgeText,
        "venueName":parse(venue.name),
        "venueID":parse(venue.id),
        "time":makeTime(badge.unlocks[0].checkins[0].createdAt),
        };
}

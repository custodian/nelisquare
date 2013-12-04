/*
 *
 */

.pragma library

api.log("loading api-photo...");

var photos = new ApiObject();
photos.debuglevel = 2;

photos.loadPhoto = function(page, photoid) {
    var url = "photos/" + photoid + "?" + getAccessTokenParameter();
    page.waiting_show();
    api.request("GET", url, page, photos.parsePhoto);
}

photos.parsePhoto = function(response, page) {
    var data = api.process(response, page)
    //photos.log("FULL PHOTO: " + JSON.stringify(data))
    var obj = data.photo;
    page.waiting_hide();

    page.photoUrl = thumbnailPhoto(obj);
    page.owner.userID = obj.user.id;
    page.owner.userName = makeUserName(obj.user);
    page.owner.userPhoto.photoUrl = thumbnailPhoto(obj.user.photo,100);
    page.owner.userShout = "via " + parse(obj.source.name);
    page.owner.venueID = obj.venue.id;
    page.owner.venueName = parse(obj.venue.name);
    page.owner.createdAt = makeTime(obj.createdAt);
}

photos.addPhoto = function(params, page, callback) {
    params.owner.waiting_show();
    var url = API_URL;
    if (params.type === "avatar") {
        url += "users/self/update?"
    } else {
        url += "photos/add?";
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
    }
    url += "&" + getAccessTokenParameter();
    callback(url);
}

photos.parseAddPhoto = function(response, page) {
    page.waiting_hide();
    var obj = api.process(response);
    photos.debug(function(){console.log("ADDED PHOTO: " + JSON.stringify(obj));});
    if (page.photosBox !== undefined) {
        page.photosBox.photosModel.insert(0,
                    makePhoto(obj.photo,300));
    }
    if (page.tipPhoto !== undefined) {
        page.tipPhoto.photoUrl = thumbnailPhoto(obj.tip.photo, 300, 300);
        page.tipPhotoID = obj.tip.photo.id;
    }
    if (page.userPhoto !== undefined) {
        page.userPhoto = thumbnailPhoto(obj.user.photo, 300, 300);
        page.userPhotoLarge = thumbnailPhoto(obj.user.photo, 500, 500);
    }
}

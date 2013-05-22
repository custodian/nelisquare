/*
 *
 */

.pragma library

api.log("loading api-photo...");

var photos = new ApiObject();
//photo.debuglevel = 1;

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
    var url = API_URL + "photos/add?";
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
    callback(url);
}

photos.parseAddPhoto = function(response, page) {
    page.waiting_hide();
    var obj = api.process(response).photo;
    //console.log("ADDED PHOTO: " + JSON.stringify(photo));
    page.photosBox.photosModel.insert(0,
                makePhoto(obj,300));
}

/*
 *
 */

Qt.include("api.js")

function loadPhoto(page, photoid) {
    var url = "photos/" + photoid + "?" + getAccessTokenParameter();
    page.waiting_show();
    doWebRequest("GET", url, page, parsePhoto);
}

function parsePhoto(response, page) {
    var photo = processResponse(response).photo;
    //console.log("FULL PHOTO: " + JSON.stringify(photo))
    page.waiting_hide();

    page.photoUrl = thumbnailPhoto(photo);
    page.owner.userID = photo.user.id;
    page.owner.userName = makeUserName(photo.user);
    page.owner.userPhoto.photoUrl = thumbnailPhoto(photo.user.photo,100);
    page.owner.userShout = "via " + parse(photo.source.name);
    page.owner.createdAt = makeTime(photo.createdAt);
}

function addPhoto(params) {
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
    if (!pictureHelper.upload(url, params.path, params.owner)) {
        show_error("Error uploading photo!");
    }
}

function parseAddPhoto(response, page) {
    page.waiting_hide();
    var photo = processResponse(response).photo;
    //console.log("ADDED PHOTO: " + JSON.stringify(photo));
    page.photosBox.photosModel.insert(0,
                makePhoto(photo,300));
}

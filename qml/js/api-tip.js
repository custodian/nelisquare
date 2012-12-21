/*
 *
 */

Qt.include("api.js")

function loadTipsList(page, objectid) {
    //page baseType == "venue" baseType == "user"
    var url;
    if (page.baseType === "user") {
        url = "lists"
    } else {
        url = page.baseType;
    }
    url += "/" + objectid + "/tips?"
        + "sort="+page.sortType
        + "&offset="+page.loaded+"&limit="+page.batchsize
        + "&" + getAccessTokenParameter();

    page.waiting_show();
    doWebRequest("GET", url, page, parseTipsList);
}

function parseTipsList(response,page){
    var data = processResponse(response);
    page.waiting_hide();
    //console.log("TIPS LIST: " + JSON.stringify(data));
    var tips;
    if (data.tips === undefined) {
        tips = [];
        data.list.listItems.items.forEach(function(item){
            item.tip.venueName = item.venue.name;
            tips.push(item.tip);
        });
    } else {
        tips = data.tips.items;
    }

    if (tips.length < page.batchsize) {
        page.completed = true;
    }
    page.loaded += tips.length;
    tips.forEach(function(tip){
        addTipToModel(page,tip);
    });
}

function loadTipInfo(page, tip) {
    var url = "tips/" + tip + "?" + getAccessTokenParameter();
    page.waiting_show();
    doWebRequest("GET", url, page, parseTipInfo);
}

function parseTipInfo(response, page) {
    var data = processResponse(response);
    page.waiting_hide();
    //console.log("FULL TIP: " + JSON.stringify(data));
    var tip = data.tip;

    //load tip to page
    page.ownerVenue.venueID = tip.venue.id;
    page.ownerVenue.venueName = tip.venue.name;
    page.ownerVenue.venueAddress = parse(tip.venue.location.address);
    var venuePhoto;
    if(tip.venue.categories!=null && tip.venue.categories[0]!==undefined) {
        venuePhoto = parseIcon(tip.venue.categories[0].icon);
    } else {
        venuePhoto = parseIcon(defaultVenueIcon);
    }
    page.ownerVenue.userPhoto.photoUrl = venuePhoto;
    page.ownerVenue.createdAt = makeTime(tip.createdAt);

    page.ownerUser.userID = tip.user.id;
    page.ownerUser.userName = makeUserName(tip.user);
    page.ownerUser.userPhoto.photoUrl = thumbnailPhoto(tip.user.photo, 100)
    page.ownerUser.userShout = tip.text;
    if (tip.photo!==undefined) {
        page.tipPhoto.photoUrl = thumbnailPhoto(tip.photo, 300, 300);
        page.tipPhotoID = tip.photo.id;
    }
    //page.ownerUser.createdAt = makeTime(tip.createdAt);

    processLikes(page.likeBox,tip);
}

function likeTip(page, id, state) {
    var url = "tips/"+id+"/like?set="
    page.waiting_show();
    if (state) {
        url += "1";
    } else {
        url += "0";
    }
    url += "&" + getAccessTokenParameter();
    doWebRequest("POST", url, page, parseLikeTip);
}

function parseLikeTip(response, page) {
    page.waiting_hide();
    var data = processResponse(response);
    processLikes(page.likeBox, data);
}

/*
 *
 */
.pragma library

api.log("loading api-tip...");

var tips = new ApiObject();
//tips.debuglevel = 1;

tips.loadTipsList = function(page, objectid) {
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
    api.request("GET", url, page, tips.parseTipsList);
}

tips.parseTipsList = function(response,page){
    var data = api.process(response, page);
    page.waiting_hide();
    //console.log("TIPS LIST: " + JSON.stringify(data));
    var tipsobj;
    if (data.tips === undefined) {
        tipsobj = [];
        data.list.listItems.items.forEach(function(item){
            item.tip.venueName = item.venue.name;
            tipsobj.push(item.tip);
        });
    } else {
        tipsobj = data.tips.items;
    }

    if (tipsobj.length < page.batchsize) {
        page.completed = true;
    }
    page.loaded += tipsobj.length;
    tipsobj.forEach(function(tip){
        addTipToModel(page,tip);
    });
}

tips.loadTipInfo = function(page, tip) {
    var url = "tips/" + tip + "?" + getAccessTokenParameter();
    page.waiting_show();
    api.request("GET", url, page, tips.parseTipInfo);
}

tips.parseTipInfo = function(response, page) {
    var data = api.process(response, page);
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
    page.ownerUser.eventOwner = tip.user.relationship;
    if (tip.photo!==undefined) {
        page.tipPhoto.photoUrl = thumbnailPhoto(tip.photo, 300, 300);
        page.tipPhotoID = tip.photo.id;
    }
    //page.ownerUser.createdAt = makeTime(tip.createdAt);

    processLikes(page.likeBox,tip);
}

tips.likeTip = function(page, id, state) {
    var url = "tips/"+id+"/like?set="
    page.waiting_show();
    if (state) {
        url += "1";
    } else {
        url += "0";
    }
    url += "&" + getAccessTokenParameter();
    api.request("POST", url, page, tips.parseLikeTip);
}

tips.parseLikeTip = function(response, page) {
    page.waiting_hide();
    var data = api.process(response, page);
    processLikes(page.likeBox, data);
}

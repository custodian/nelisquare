/*
 *
 */

.pragma library

api.log("loading api-notifications...");

var notifications = new ApiObject();
//notifications.debuglevel = 1;

notifications.loadNotifications = function(page) {
    var url = "updates/notifications?limit=100&" + getAccessTokenParameter();
    page.waiting_show();
    page.notificationsModel.clear();
    api.request("GET", url, page, notifications.parseNotifications);
}

notifications.markNotificationsRead = function(page, time) {
    var url = "updates/marknotificationsread?";
    url += "highWatermark=" + time;
    url += "&" + getAccessTokenParameter();
    api.request("POST", url, page, doNothing);
}

notifications.parseNotifications = function(response, page) {
    var notis = api.process(response, page).notifications;
    //console.log("NOTIFICATIONS: " + JSON.stringify(notis));
    page.waiting_hide();
    notis.items.forEach(function(noti) {
        //console.log("NOTIFICATIONS: " + JSON.stringify(noti));
        var objectID = noti.target.object.id;
        var image = noti.image.fullPath;
        if (noti.target.type == "badge") {
            image = makeImageUrl(noti.image,114);
        }
        page.notificationsModel
            .append({
                        "type": noti.target.type,
                        "objectID": objectID,
                        "object": noti.target.object,
                        //"userName": makeUserName("asdf"),
                        "createdAt": noti.createdAt,
                        "time": makeTime(noti.createdAt),
                        "text": noti.text,
                        "unreaded": noti.unread,
                        "photo": image
                })
        });
}

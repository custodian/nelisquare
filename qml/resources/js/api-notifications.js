/*
 *
 */

Qt.include("api.js")

function loadNotifications(page) {
    var url = "updates/notifications?limit=100&" + getAccessTokenParameter();
    waiting.show();
    doWebRequest("GET",url,page, parseNotifications);
}

function markNotificationsRead(page, time) {
    var url = "updates/marknotificationsread?";
    url += "highWatermark=" + time;
    url += "&" + getAccessTokenParameter();
    doWebRequest("POST", url, page, doNothing);
}

function parseNotifications(response, page) {
    var notis = processResponse(response).notifications;
    //console.log("NOTIFICATIONS: " + JSON.stringify(notis));
    waiting.hide();
    notis.items.forEach(function(noti) {
        //console.log("NOTIFICATIONS: " + JSON.stringify(noti));
        var objectID = noti.target.object.id;
        var photo = noti.image.fullPath;
        if (noti.target.type == "badge") {
            photo = makeImageUrl(noti.image,114);
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
                        "photo": photo
                })
        });
}

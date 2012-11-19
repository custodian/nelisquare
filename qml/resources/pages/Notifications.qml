import Qt 4.7
import QtMobility.gallery 1.1
import "../components"

import "../js/api-notifications.js" as NotiAPI

Rectangle {
    signal user(string user)
    signal tip(string tip)
    signal checkin(string checkin)
    signal venue(string venue)
    signal badge(variant badge)
    signal markRead(string time)

    property alias notificationsModel: notificationsModel

    id: notificationsList
    width: parent.width
    height: parent.height

    color: theme.colors.backgroundMain

    function load() {
        var page = notificationsList;
        page.user.connect(function(user) {
            pageStack.push(Qt.resolvedUrl("User.qml"),{"userID":user});
        });
        page.checkin.connect(function(checkin) {
            pageStack.push(Qt.resolvedUrl("Checkin.qml"),{"checkinID":checkin});
        });
        page.venue.connect(function(venue) {
            pageStack.push(Qt.resolvedUrl("Venue.qml"),{"venueID":venue});
        });
        page.badge.connect(function(badge) {
            pageStack.push(Qt.resolvedUrl("BadgeInfo.qml"),NotiAPI.makeBadgeObject(badge));
        });
        page.tip.connect(function(tip){
            pageStack.push(Qt.resolvedUrl("TipPage.qml"),{"tipID":tip});
        });
        page.markRead.connect(function(time) {
            NotiAPI.markNotificationsRead(page,time);
        });
        NotiAPI.loadNotifications(page);
    }

    ListModel {
        id: notificationsModel
    }

    ListView {
        id: notificationRepeater
        anchors.fill: parent
        model: notificationsModel
        delegate: notificationDelegate
        spacing: 10
        //highlightFollowsCurrentItem: true
        clip: true
    }

    Component {
        id: notificationDelegate

        EventBox {
            activeWhole: true
            userShout: model.text
            createdAt: model.time
            highlight: model.unreaded
            fontSize: 20

            Component.onCompleted: {
                userPhoto.photoUrl = model.photo
            }
            onAreaClicked: {
                var readed = false;
                console.log("NOTI TYPE: " + model.type + " OBJID: " + model.objectID);
                //TODO: disable readed notification check!
                if (model.type === "checkin") {
                    readed = true;
                    notificationsList.checkin(model.objectID);
                } else if (model.type === "tip") {
                    readed = true;
                    notificationsList.tip(model.objectID);
                } else if (model.type === "venue") {
                    notificationsList.venue(model.objectID);
                } else if (model.type === "user") {
                    readed = true;
                    notificationsList.user(model.objectID);
                } else if (model.type === "badge") {
                    readed = true;
                    notificationsList.badge(model.object);
                } else if (model.type === "list") {
                    //TODO: load list "objID == 622214/todos"
                    readed = true;
                }
                if (readed) {
                    notificationsList.markRead(model.createdAt);
                }
                highlight = false;
            }
        }
    }
}

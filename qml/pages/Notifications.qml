import Qt 4.7
import com.nokia.meego 1.0
import QtMobility.gallery 1.1
import "../components"

import "../js/api.js" as Api

PageWrapper {
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

    color: mytheme.colors.backgroundMain

    headerText: "NOTIFICATIONS"
    headerIcon: "../icons/icon-header-notifications.png"
    headerBubble: false

    tools: ToolBarLayout{
        ToolIcon{
            platformIconId: "toolbar-back"
            onClicked: stack.pop()
        }
        ToolIcon {
            platformIconId: "toolbar-refresh"
            onClicked: {
                Api.notifications.loadNotifications(notificationsList);
            }
        }
        ToolIcon {
            platformIconId: "toolbar-view-menu"
            onClicked: {
                menu.open();
            }
        }
    }

    Menu {
        id: menu
        MenuLayout {
            MenuItem {
                text: qsTr("Mark all as read")
                onClicked: {
                    Api.notifications.markNotificationsRead(notificationsList,Api.getCurrentTime());
                    Api.notifications.loadNotifications(notificationsList);
                }
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: {
                    stack.replace(Qt.resolvedUrl("../pages/Settings.qml"));
                }
            }
        }
    }

    function load() {
        var page = notificationsList;
        page.user.connect(function(user) {
            stack.push(Qt.resolvedUrl("User.qml"),{"userID":user});
        });
        page.checkin.connect(function(checkin) {
            stack.push(Qt.resolvedUrl("Checkin.qml"),{"checkinID":checkin});
        });
        page.venue.connect(function(venue) {
            stack.push(Qt.resolvedUrl("Venue.qml"),{"venueID":venue});
        });
        page.badge.connect(function(badge) {
            stack.push(Qt.resolvedUrl("BadgeInfo.qml"),Api.makeBadgeObject(badge));
        });
        page.tip.connect(function(tip){
            stack.push(Qt.resolvedUrl("TipPage.qml"),{"tipID":tip});
        });
        page.markRead.connect(function(time) {
            Api.notifications.markNotificationsRead(page,time);
        });
        Api.notifications.loadNotifications(page);
    }

    ListModel {
        id: notificationsModel
    }

    ListView {
        id: notificationRepeater
        anchors {
            top: pagetop
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        model: notificationsModel
        delegate: notificationDelegate
        spacing: 10
        //highlightFollowsCurrentItem: true
        clip: true
    }

    ScrollDecorator{ flickableItem: notificationRepeater }

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

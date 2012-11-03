import Qt 4.7
import QtMobility.gallery 1.1
import "../components"

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
    state: "hidden"
    color: theme.colors.backgroundMain

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

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: notificationsList
                x: parent.width
            }
        },
        State {
            name: "hiddenLeft"
            PropertyChanges {
                target: notificationsList
                x: -parent.width
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: notificationsList
                x: 0
            }
        }
    ]

    transitions: [
        Transition {
            from: "shown"
            SequentialAnimation {
                PropertyAnimation {
                    target: notificationsList
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
                PropertyAction {
                    target: notificationsList
                    properties: "visible"
                    value: false
                }
            }
        },
        Transition {
            to: "shown"
            SequentialAnimation {
                PropertyAction {
                    target: notificationsList
                    properties: "visible"
                    value: true
                }
                PropertyAnimation {
                    target: notificationsList
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}

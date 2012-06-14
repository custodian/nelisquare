import Qt 4.7
import QtMobility.gallery 1.1
import "../."

Rectangle {
    signal user(string user)
    signal checkin(string checkin)
    signal venue(string venue)
    signal markNotificationsRead(string time)

    property alias notificationsModel: notificationsModel

    id: notificationsList

    width: parent.width
    height: parent.height

    ListModel {
        id: notificationsModel
    }

    ListView {
        id: notificationRepeater
        anchors.fill: parent
        model: notificationsModel
        delegate: notificationDelegate
        highlightFollowsCurrentItem: true
        clip: true
    }

    Component {
        id: notificationDelegate

        EventBox {
            activeWhole: true
            userShout: model.text
            createdAt: model.time
            fontSize: 20

            Component.onCompleted: {
                userPhoto.photoUrl = model.photo
            }
            onAreaClicked: {
                console.log("NOTI TYPE: " + model.type + " OBJID: " + model.objectID);
                markNotificationsRead(model.createdAt);
                if (model.type == "checkin") {
                    notificationsList.checkin(model.objectID);
                } else if (model.type == "tip") {
                    notificationsList.venue(model.objectID);
                } else if (model.type == "venue") {
                    notificationsList.venue(model.objectID);
                } else if (model.type == "user") {
                    notificationsList.user(model.objectID);
                }
            }
        }
    }

    states: [
        State {
            name: "hidden"
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

import Qt 4.7

Rectangle {
    id: notification
    width: parent.width
    height: items.height + 50
    color: mytheme.colors.notificationBackground
    property string message: ""
    property string objectType: ""
    property string objectID: ""

    property alias hider: hider

    signal close()
    state: "hidden"

    Column {
        id: items
        x: 10
        y: 10
        width: parent.width - 20
        spacing: 10

        Text {
            id: venueName
            text: notification.message
            wrapMode: Text.Wrap
            width: parent.width
            font.pixelSize: 22
            color: mytheme.colors.textHeader
        }

        ButtonBlue {
            id: checkinButton
            label: "OK"
            width: parent.width
            onClicked: {
                notification.close();
                message = "";
            }
        }

    }

    Timer {
        id: hider
        interval: 10000
        onTriggered: {
            notification.message = "";
            notification.state = "hidden";
        }
    }

    Image {
        id: shadow
        source: "../pics/top-shadow.png"
        width: parent.width
        y: parent.height - 1
    }

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: notification
                y: -200-notification.height
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: notification
                y: 0
            }
        }
    ]

    transitions: [
        Transition {
            from: "shown"
            SequentialAnimation {
                PropertyAnimation {
                    target: notification
                    properties: "y"
                    duration: 300
                    easing.type: "InOutQuad"
                }
                PropertyAction {
                    target: notification
                    properties: "visible"
                    value: false
                }
            }
        },
        Transition {
            to: "shown"
            SequentialAnimation {
                PropertyAction {
                    target: notification
                    properties: "visible"
                    value: true
                }
                PropertyAnimation {
                    target: notification
                    properties: "y"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}

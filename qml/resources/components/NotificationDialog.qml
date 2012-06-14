import Qt 4.7

Rectangle {
    id: notification
    width: parent.width
    height: items.height + 50
    color: theme.toolbarLightColor
    property string message: ""
    property string objectType: ""
    property string objectID: ""
    signal close()

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
            color: "#fff"
        }

        GreenButton {
            id: checkinButton
            label: "Ok"
            width: parent.width
            onClicked: {
                notification.close();
                message = "";
            }
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
                y: -notification.height
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

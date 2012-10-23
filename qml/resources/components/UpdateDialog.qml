import Qt 4.7

Rectangle {
    id: update
    width: parent.width
    height: items.height + 20
    color: theme.toolbarLightColor
    state: "hidden"
    property string version: ""
    property string build: ""
    property string url: ""

    Column {
        id: items
        x: 10
        y: 10
        width: parent.width - 20
        spacing: 10

        Text {
            text: "New update is available!"
            width: parent.width
            font.pixelSize: theme.font.sizeSettigs
            color: theme.textColorSign
        }

        Text {
            text: "Type: " + window.checkupdates;
            width: parent.width
            font.pixelSize: theme.font.sizeDefault
            color: theme.textColorSign
        }
        Text {
            text: "Version: " + update.version;
            width: parent.width
            font.pixelSize: theme.font.sizeDefault
            color: theme.textColorSign
        }
        Text {
            text: "Build: " + update.build;
            width: parent.width
            font.pixelSize: theme.font.sizeDefault
            color: theme.textColorSign
        }

        Item {
            width: parent.width
            height: updateButton.height

            GreenButton {
                id: updateButton
                label: "Update!"
                width: parent.width - 130
                onClicked: {
                    update.state = "hidden";
                    Qt.openUrlExternally(url);
                    Qt.quit();
                }
            }

            ButtonEx {
                label: "Cancel"
                x: parent.width - 120
                width: 120
                onClicked: {
                    update.state = "hidden";
                }
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
                target: update
                y: -200-update.height
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: update
                y: 0
            }
        }
    ]

    transitions: [
        Transition {
            from: "shown"
            SequentialAnimation {
                PropertyAnimation {
                    target: update
                    properties: "y"
                    duration: 300
                    easing.type: "InOutQuad"
                }
                PropertyAction {
                    target: update
                    properties: "visible"
                    value: false
                }
            }
        },
        Transition {
            to: "shown"
            SequentialAnimation {
                PropertyAction {
                    target: update
                    properties: "visible"
                    value: true
                }
                PropertyAnimation {
                    target: update
                    properties: "y"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}

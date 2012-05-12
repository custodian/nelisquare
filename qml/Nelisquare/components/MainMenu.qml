import Qt 4.7

Rectangle {
    signal openSettings()

    id: menu
    width: 220
    height: iconsColumn.height + 40
    radius: 5
    smooth: true
    color: "#555"

    signal openFriendsCheckins()
    signal openPlaces()
    signal openExplore()
    signal openProfile()
    signal openLeaderBoard()

    Column  {
        id: iconsColumn
        x: 10
        y: 20
        width: parent.width - 20
        spacing: 10

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            ToolbarButton {
                image: "settings.png"
                label: "Settings"
                onClicked: menu.openSettings();
            }
        }
    }

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: menu
                y: -menu.height
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: menu
                y: 49
            }
        }
    ]

    transitions: [
        Transition {
            SequentialAnimation {
                PropertyAnimation {
                    target: menu
                    properties: "y"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}

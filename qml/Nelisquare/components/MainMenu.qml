import Qt 4.7

Rectangle {
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
                id: friendsButton
                image: "users.png" // "112-group@2x.png"
                label: "Friends"
                selected: friendsCheckinsList.state == "shown"
                onClicked: menu.openFriendsCheckins();
            }


            ToolbarButton {
                id: placesButton
                image: "pin_map.png" //  "07-map-marker@2x.png"
                label: "Places"
                selected: placesList.state == "shown"
                onClicked: menu.openPlaces();
            }
        }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            ToolbarButton {
                image: "checkbox_checked.png" // "117-todo@2x.png"
                label: "To-Do"
                onClicked: menu.openExplore();
            }

            ToolbarButton {
                image: "contact_card.png" // "111-user@2x.png"
                label: "Myself"
                onClicked: menu.openProfile();
            }
        }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            ToolbarButton {
                image: "chart_bar.png"
                label: "Stats"
                onClicked: menu.openLeaderBoard();
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

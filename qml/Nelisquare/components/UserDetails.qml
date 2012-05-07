import Qt 4.7

Rectangle {
    id: details
    width: parent.width
    color: "#eee"

    property string userID: ""
    property string userName: ""
    property string userPhoto: ""
    property int userBadgesCount: 0
    property int userMayorshipsCount: 0
    property int userCheckinsCount: 0
    property int userFriendsCount: 0
    signal openLeaderBoard()

    MouseArea {
        anchors.fill: parent
        onClicked: { }
    }

    Rectangle {
        width: parent.width
        height: 10
        color: "#A8CB17"
        y: 120

        Rectangle {
            width: parent.width
            height: 1
            color: "#A8CB17"
        }

        Rectangle {
            width: parent.width
            height: 1
            color: "#888"
            y: 9
        }
    }

    Column {
        width: parent.width - 20
        x: 10
        y: 134
        spacing: 10

        Item {
            width: parent.width
            height: 64
            Rectangle {
                id: profileImage
                width: 64
                height: 64
                color: "#fff"
                border.color: "#ccc"
                border.width: 1

                Image {
                    x: 4
                    y: 4
                    source: details.userPhoto
                    smooth: true
                    width: 57
                    height: 57
                }
            }

            Text {
                text: details.userName
                x: 74
                font.pixelSize: 22
                font.bold: true
                color: "#111"
            }
            Text {
                x: 74
                y: 32
                text: details.userFriendsCount + " friends"
                font.pixelSize: 20
                color: "#888"
            }
        }

        Button {
            width: 120
            label: "Stats"
            onClicked: {
                details.openLeaderBoard();
            }
        }

    }


    Rectangle {
        width: parent.width
        height: 120
        color: theme.toolbarLightColor

        Rectangle {
            id: badgesCount
            x: 10
            y: 10
            width: (parent.width - 20) / 3 - 10
            height: 100
            color: theme.toolbarDarkColor
            smooth: true
            radius: 5

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                y: 20
                color: "#fff"
                font.pixelSize: 50
                text: details.userBadgesCount
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                y: parent.height - height - 2
                color: "#ddd"
                font.pixelSize: 20
                text: "Badges"
            }
        }

        Rectangle {
            id: checkinsCount
            x: badgesCount.x + badgesCount.width + 10
            y: 10
            width: (parent.width - 20) / 3 - 10
            height: 100
            color: theme.toolbarDarkColor
            smooth: true
            radius: 5

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                y: 20
                color: "#fff"
                font.pixelSize: 50
                text: details.userCheckinsCount
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                y: parent.height - height - 2
                color: "#ddd"
                font.pixelSize: 20
                text: "Checkins"
            }
        }

        Rectangle {
            id: mayorCount
            x: checkinsCount.x + checkinsCount.width + 10
            y: 10
            width: (parent.width - 20) / 3 - 10
            height: 100
            color: theme.toolbarDarkColor
            smooth: true
            radius: 5

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                y: 20
                color: "#fff"
                font.pixelSize: 50
                text: details.userMayorshipsCount
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                y: parent.height - height - 2
                color: "#ddd"
                font.pixelSize: 20
                text: "Mayorships"
            }
        }
    }

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: details
                x: parent.width
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: details
                x: 0
            }
        }
    ]

    transitions: [
        Transition {
            SequentialAnimation {
                PropertyAnimation {
                    target: details
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}

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

    property int scoreRecent: 0
    property int scoreMax: 0

    property string lastVenue: ""
    property string lastTime: ""

    signal openLeaderBoard()

    MouseArea {
        anchors.fill: parent
        onClicked: { }
    }

    Column {
        width: parent.width - 20
        y: 10
        x: 10
        spacing: 10

        Item {
            width: parent.width
            height: 64

            ProfilePhoto {
                id: profileImage
                photoUrl: details.userPhoto
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
                text: details.lastTime + " @ " + details.lastVenue
                font.pixelSize: 20
                color: "#888"
            }
        }

        Rectangle {
            width: parent.width
            height: 10
            color: "#A8CB17"

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

        //scores title
        Row {
            width: parent.width
            Text {
                text: "Scores (last 7 days)"
                font.pixelSize: 18
            }
            Text {
                text: "Best score"
                anchors.right: parent.right
                font.pixelSize: 18
            }
        }
        //scores value
        Row {
            width: parent.width
            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                height: 25
                width: parent.width * 0.85
                color: "steelblue"
            }
            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                height: 25
                width: parent.width * 0.85 * scoreRecent / scoreMax
                color: "#00B000"
                Text {
                    text: scoreRecent + "  "
                    anchors.right: parent.right
                    font.pixelSize: 18
                    color: "white"
                    visible: scoreRecent>0
                }
            }
            Text {
                text: scoreMax
                anchors.right: parent.right
                font.pixelSize: 18
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: "#ccc"
        }

        //Friends
        Row {

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

        Button {
            width: 120
            label: "Stats"
            onClicked: {
                details.openLeaderBoard();
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

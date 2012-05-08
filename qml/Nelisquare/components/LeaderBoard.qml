import Qt 4.7

Rectangle {
    id: leaderBoard
    signal user( string user )
    property string rank: ""
    width: parent.width
    color: "#eee"

    MouseArea {
        anchors.fill: parent
        onClicked: { }
    }

    ListView {
        y: 60
        model: boardModel
        width: parent.width
        height: parent.height - y
        delegate: leaderBoardDelegate
        highlightFollowsCurrentItem: true
    }

    Rectangle {
        width: parent.width
        height: 50
        color: theme.toolbarLightColor

        Text {
            text: "You are #" + leaderBoard.rank
            font.pixelSize: 22
            font.bold: true
            color: "#111"
            anchors.centerIn: parent
        }

    }

    Rectangle {
        width: parent.width
        height: 10
        color: "#A8CB17"
        y: 50

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

    Image {
        id: shadow
        source: "../pics/top-shadow.png"
        width: parent.width
        y: 60
    }

    Component {
        id: leaderBoardDelegate

        Item {
            id: friendItem
            width: parent.width
            height: titleContainer.height + 2

            Rectangle {
                id: titleContainer
                color: mouseArea.pressed ? "#ddd" : "#eee"
                y: 1
                width: parent.width
                height: statusTextArea.height + 16 < profileImage.height+2 ? profileImage.height + 16 : statusTextArea.height + 16

                ProfilePhoto {
                    id: profileImage
                    photoUrl: photo

                    onClicked: {
                        checkin.user(userID);
                    }
                }

                Column {
                    id: statusTextArea
                    spacing: 4
                    x: profileImage.width + 12
                    y: 4
                    width: parent.width - x - 12

                    Text {
                        id: messageText
                        color: theme.toolbarDarkColor
                        font.pixelSize: 22
                        font.bold: true
                        width: parent.width
                        text: rank + ". " + name
                        wrapMode: Text.Wrap
                    }

                    Text {
                        color: "#555"
                        font.pixelSize: 22
                        width: parent.width
                        text: recent + " points"
                        wrapMode: Text.Wrap
                    }

                    Text {
                        color: "#888"
                        font.pixelSize: 20
                        width: parent.width
                        text: checkinsCount + " check-ins"
                        wrapMode: Text.Wrap
                    }
                }
            }

            Rectangle {
                width:  parent.width
                x: 4
                y: friendItem.height - 1
                height: 1
                color: "#ddd"
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                onClicked: {
                    leaderBoard.user( id );
                }
            }

        }
    }

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: leaderBoard
                x: parent.width
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: leaderBoard
                x: 0
            }
        }
    ]

    transitions: [
        Transition {
            SequentialAnimation {
                PropertyAnimation {
                    target: leaderBoard
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}

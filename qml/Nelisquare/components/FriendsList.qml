import Qt 4.7

Rectangle {
    id: friendsList
    signal clicked(int index)
    signal shout()
    signal nearby()
    signal recent()
    property bool recentPressed: true
    property bool nearbyPressed: false
    width: parent.width
    color: "#eee"

    MouseArea {
        anchors.fill: parent
        onClicked: { }
    }

    ListView {
        y: 110
        model: friendsModel
        width: parent.width
        height: parent.height - y
        delegate: friendsListDelegate
        highlightFollowsCurrentItem: true
    }

    Rectangle {
        width: parent.width
        height: 100
        color: theme.toolbarLightColor
/*
        GreenButton {
            x: 10
            y: 10
            height: 50
            label: "Shout"
            width: parent.width - 20

            onClicked: {
                friendsList.shout();
            }
        }
*/
        Rectangle {
            width: parent.width-20
            y: 20
            x: 10
            color: theme.toolbarDarkColor
            border.color: "#2774aA"
            border.width: 1
            height: 70
            radius: 5
            smooth: true

            BlueButton {
                label: "Recent"
                y: 10
                x: 10
                width:  parent.width/2-15
                height: 50
                pressed: friendsList.recentPressed
                onClicked: {
                    if(friendsList.recentPressed==false) {
                        friendsList.recent();
                    }
                }
            }
            BlueButton {
                label: "Nearby"
                y: 10
                x: parent.width/2+5
                width: parent.width/2-15
                height: 50
                pressed: friendsList.nearbyPressed
                onClicked: {
                    if(friendsList.nearbyPressed==false) {
                        friendsList.nearby();
                    }
                }
            }
        }

    }

    Rectangle {
        width: parent.width
        height: 10
        color: "#A8CB17"
        y: 100

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
        y: 110
    }

    Component {
        id: friendsListDelegate

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

                Rectangle {
                    id: profileImage
                    x: 4
                    y: 4
                    width: 64
                    height: 64
                    color: "#fff"
                    border.color: "#ccc"
                    border.width: 1

                    Image {
                        x: 4
                        y: 4
                        source: photo
                        smooth: true
                        width: 57
                        height: 57
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
                        text: user + "<span style='color:#000'> @ </span>" + venueName
                        wrapMode: Text.Wrap
                    }

                    Text {
                        color: "#555"
                        font.pixelSize: 22
                        width: parent.width
                        text: shout!="" ? shout : venueAddress + " " + venueCity
                        wrapMode: Text.Wrap
                    }

                    Text {
                        color: "#888"
                        font.pixelSize: 20
                        width: parent.width
                        text: createdAt
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
                    friendsList.clicked( index );
                }
            }

        }
    }

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: friendsList
                x: parent.width
            }
        },
        State {
            name: "hiddenLeft"
            PropertyChanges {
                target: friendsList
                x: -parent.width
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: friendsList
                x: 0
            }
        }
    ]

    transitions: [
        Transition {
            SequentialAnimation {
                PropertyAnimation {
                    target: friendsList
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}

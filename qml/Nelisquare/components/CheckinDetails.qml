import Qt 4.7

Rectangle {
    id: checkin
    signal venue()
    signal user(string user)
    width: parent.width
    height: parent.height
    color: "#eee"

    property string scoreTotal: ""

    MouseArea {
        anchors.fill: parent
        onClicked: {
        }
    }

    Column {
        anchors.fill: parent

        Repeater {
            id: checkinListView
            model: checkinModel
            width: parent.width
            delegate: checkinDelegate
        }

        Flickable {
            id: flickableArea
            width: parent.width
            contentWidth: parent.width
            height: checkin.height - y

            clip: true
            flickableDirection: Flickable.VerticalFlick
            boundsBehavior: Flickable.StopAtBounds
            pressDelay: 100

            Column {

                onHeightChanged: {
                    flickableArea.contentHeight = height;
                }

                id: columnView
                x: 10
                width: parent.width - 20
                spacing: 10

                Row {
                    width: parent.width
                    spacing: 10
                    Text {
                        width: parent.width * 0.85
                        text: "Total points:"
                    }
                    Text {
                        //anchors.right: parent.right
                        text: checkin.scoreTotal
                    }
                }

                Repeater {
                    id: scoreRepeater
                    width: parent.width
                    model: scoresModel
                    delegate: scoreDelegate
                    visible: scoresModel.count>0
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#ccc"
                }

                Text {
                    width: parent.width
                    visible: badgesModel.count>0
                    text: "Earned badges:"
                }

                Repeater {
                    id: badgeRepeater
                    width: parent.width
                    model: badgesModel
                    delegate: badgeDelegate
                    visible: badgesModel.count>0
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#ccc"
                    visible: badgesModel.count>0
                }

                Text {
                    width: parent.width
                    visible: commentsModel.count>0
                    text: "Comments:"
                }

                Repeater {
                    id: commentRepeater
                    width: parent.width
                    model: commentsModel
                    delegate: checkinDelegate
                    visible: commentsModel.count>0
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#ccc"
                    visible: commentsModel.count>0
                }
            }
        }
    }

    Component {
        id: checkinDelegate

        Item {
            z: 100
            id: friendItem
            width: checkinListView.width
            height: titleContainer.height + 2

            Rectangle {
                id: titleContainer
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

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            checkin.user(userID);
                        }
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
                MouseArea {
                    anchors.fill: statusTextArea
                    onClicked: {
                        checkin.venue();
                    }
                }
            }

            Rectangle {
                width: parent.width
                x: 4
                y: friendItem.height - 1
                height: 1
                color: "#ddd"
            }
        }
    }

    Component {
        id: scoreDelegate

        Column {
            width: scoreRepeater.width
            Row {
                width: scoreRepeater.width
                Image {
                    source: scoreImage
                    smooth: true
                    width: 24
                    height: 24
                }
                Text {
                    width: parent.width * 0.8
                    wrapMode: Text.Wrap
                    text: scoreMessage
                    color: "#111"
                    font.pixelSize: 18
                }
                Text {
                    wrapMode: Text.NoWrap
                    text: "+"+scorePoints
                    color: "#aaa"
                    font.pixelSize: 18
                }
            }
        }
    }

    Component {
        id: badgeDelegate

        Row {
            width: badgeRepeater.width
            Column {
                width: badgeRepeater.width - 105
                Text {
                    width: badgeRepeater.width * 0.95
                    text: badgeTitle
                }
                Text {
                    width: parent.width * 0.8
                    wrapMode: Text.Wrap
                    text: badgeMessage
                    color: "#111"
                    font.pixelSize: 18
                }
            }
            Image {
                source: badgeImage
                smooth: true
                width: 100
                height: 100
            }
        }
    }

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: checkin
                x: parent.width
            }
        },
        State {
            name: "hiddenLeft"
            PropertyChanges {
                target: checkin
                x: -parent.width
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: checkin
                x: 0
            }
        }
    ]

    transitions: [
        Transition {
            SequentialAnimation {
                PropertyAnimation {
                    target: checkin
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}

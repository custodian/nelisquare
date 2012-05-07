import Qt 4.7

Rectangle {
    id: checkin
    width: parent.width
    height: items.height + 20
    color: theme.toolbarLightColor
    property string venueID: ""
    property string venueName: ""
    property string comment: "Add comment"
    property bool useFacebook: false
    property bool useTwitter: false
    property bool useFriends: true
    signal cancel()
    signal checkin(string venueID, string comment, bool friends, bool facebook, bool twitter)

    function reset() {
        shoutText.text = "Add comment";
    }

    Column {
        id: items
        x: 10
        y: 10
        width: parent.width - 20
        spacing: 10

        Text {
            id: venueName
            text: checkin.venueName
            width: parent.width
            font.pixelSize: 24
            color: "#fff"
        }

        Rectangle {
            id: checkinShoutBox
            height: 120
            width: parent.width
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#ccc" }
                GradientStop { position: 0.1; color: "#fafafa" }
                GradientStop { position: 1.0; color: "#fff" }
            }
            radius: 5
            border.width: 1
            border.color: "#aaa"
            smooth: true

            TextEdit {
                id: shoutText
                wrapMode: TextEdit.Wrap
                text: "Add comment"
                textFormat: TextEdit.PlainText
                width: parent.width - 10
                height: parent.height - 10
                x: 5
                y: 5
                color: "#111"
                font.pixelSize: 24

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if(shoutText.text=="Add comment") {
                            shoutText.text = "";
                            shoutText.focus = true;
                        }
                        shoutText.forceActiveFocus();
                        shoutText.openSoftwareInputPanel();
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            color: theme.toolbarDarkColor
            border.color: "#2774aA"
            border.width: 1
            height: 10 + twitterRow.y + twitterRow.height
            radius: 5
            smooth: true

            Row {
                id: friendsRow
                y: 10
                x: 10
                spacing: 10
                width: parent.width - 64
                height: 42

                Rectangle {
                    border.width: 1
                    border.color: "#444"
                    color: friendsMouseArea.pressed ? "#555" : "#111"
                    radius: 5
                    width: 42
                    height: 42

                    Image {
                        anchors.centerIn: parent
                        source: "../pics/delete.png"
                        visible: checkin.useFriends
                    }

                    MouseArea {
                        id: friendsMouseArea
                        anchors.fill: parent
                        onClicked: {
                            checkin.useFriends = !checkin.useFriends;
                        }
                    }
                }

                Text {
                    text: "Share with friends"
                    width: parent.width - 128
                    wrapMode: Text.Wrap
                    font.pixelSize: 22
                    anchors.verticalCenter: parent.verticalCenter
                    color: "#fff"
                }
            }

            Row {
                id: facebookRow
                y: 20 + 42
                x: 10
                spacing: 10
                width: parent.width - 64
                height: 42

                Rectangle {
                    border.width: 1
                    border.color: "#444"
                    color: facebookMouseArea.pressed ? "#555" : "#111"
                    radius: 5
                    width: 42
                    height: 42

                    Image {
                        anchors.centerIn: parent
                        source: "../pics/delete.png"
                        visible: checkin.useFacebook
                    }

                    MouseArea {
                        id: facebookMouseArea
                        anchors.fill: parent
                        onClicked: {
                            checkin.useFacebook = !checkin.useFacebook;
                        }
                    }
                }

                Text {
                    text: "Share with Facebook"
                    width: parent.width - 128
                    wrapMode: Text.Wrap
                    font.pixelSize: 22
                    anchors.verticalCenter: parent.verticalCenter
                    color: "#fff"
                }
            }

            Row {
                y: 30 + 42*2
                x: 10
                id: twitterRow
                spacing: 10
                width: parent.width - 64
                height: 42

                Rectangle {
                    border.width: 1
                    border.color: "#444"
                    color: twitterMouseArea.pressed ? "#555" : "#111"
                    radius: 5
                    width: 42
                    height: 42

                    Image {
                        anchors.centerIn: parent
                        source: "../pics/delete.png"
                        visible: checkin.useTwitter
                    }

                    MouseArea {
                        id: twitterMouseArea
                        anchors.fill: parent
                        onClicked: {
                            checkin.useTwitter = !checkin.useTwitter;
                        }
                    }
                }

                Text {
                    text: "Share with Twitter"
                    width: parent.width - 128
                    wrapMode: Text.Wrap
                    font.pixelSize: 22
                    anchors.verticalCenter: parent.verticalCenter
                    color: "#fff"
                }
            }
        }

        Item {
            width: parent.width
            height: checkinButton.height

            GreenButton {
                id: checkinButton
                label: "CHECK-IN HERE"
                width: parent.width - 130
                onClicked: checkin.checkin( checkin.venueID, shoutText.text, checkin.useFriends, checkin.useFacebook, checkin.useTwitter )

            }

            GreenButton {
                label: "Cancel"
                x: parent.width - 120
                width: 120
                onClicked: checkin.state = "hidden";
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
                target: checkin
                y: -checkin.height
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: checkin
                y: 0
            }
        }
    ]

    transitions: [
        Transition {
            SequentialAnimation {
                PropertyAnimation {
                    target: checkin
                    properties: "y"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}

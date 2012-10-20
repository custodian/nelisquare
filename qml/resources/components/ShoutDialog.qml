import Qt 4.7

Rectangle {
    id: checkin
    width: parent.width
    height: items.height + 20
    color: theme.toolbarLightColor
    state: "hidden"
    property bool useFacebook: false
    property bool useTwitter: false
    signal cancel()
    signal shout(string comment, bool facebook, bool twitter)

    function reset() {
        shoutText.text = "Write here";
    }

    function hideKeyboard() {
        shoutText.closeSoftwareInputPanel();
        window.focus = true;
    }

    Column {
        id: items
        x: 10
        y: 10
        width: parent.width - 20
        spacing: 10

        Text {
            id: venueName
            text: "What is on your mind?"
            width: parent.width
            font.pixelSize: 24
            color: "#fff"
        }

        Rectangle {
            id: checkinShoutBox
            height: 100
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
                text: "Write here"
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
                        shoutText.focus = true;
                        if(shoutText.text=="Write here") {
                            shoutText.text = "";                            
                        }
                        if (shoutText.text != "") {
                            shoutText.cursorPosition = shoutText.positionAt(mouseX,mouseY);
                        }
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
                id: facebookRow
                y: 10
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
                        source: "../pics/checktap.png"
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
                y: 20 + 42
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
                        source: "../pics/checktap.png"
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
                label: "Shout!"
                width: parent.width - 130
                onClicked: {
                    hideKeyboard();
                    checkin.shout( shoutText.text, checkin.useFacebook, checkin.useTwitter )
                }

            }

            GreenButton {
                label: "Cancel"
                x: parent.width - 120
                width: 120
                onClicked: {
                    hideKeyboard();
                    checkin.state = "hidden";
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
                target: checkin
                y: -200-checkin.height
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
            from: "shown"
            SequentialAnimation {
                PropertyAnimation {
                    target: checkin
                    properties: "y"
                    duration: 300
                    easing.type: "InOutQuad"
                }
                PropertyAction {
                    target: checkin
                    properties: "visible"
                    value: false
                }
            }
        },
        Transition {
            to: "shown"
            SequentialAnimation {
                PropertyAction {
                    target: checkin
                    properties: "visible"
                    value: true
                }
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

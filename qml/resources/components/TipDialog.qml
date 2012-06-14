import Qt 4.7

Rectangle {
    id: tipDialog
    width: parent.width
    height: items.height + 20
    color: theme.toolbarLightColor
    property string venueID: ""
    property string venueName: ""
    property int action: 0
    property string comment: "Write here"
    signal cancel()
    signal addTip(string comment)

    function reset() {
        shoutText.text = "Comment...";
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
            text: tipDialog.venueName
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
                text: "Comment..."
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
                        if(shoutText.text=="Comment...") {
                            shoutText.text = "";
                        }
                    }
                }
            }
        }

        Item {
            width: parent.width
            height: checkinButton.height

            GreenButton {
                id: checkinButton
                label: "ADD"
                width: parent.width - 130
                onClicked: {
                    var comment = shoutText.text;
                    if(comment=="Comment...") {
                        comment = "";
                    }
                    hideKeyboard();
                    tipDialog.addTip( comment );
                }
            }

            GreenButton {
                label: "Cancel"
                x: parent.width - 120
                width: 120
                onClicked: {
                    hideKeyboard();
                    tipDialog.state = "hidden";
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
                target: tipDialog
                y: -tipDialog.height
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: tipDialog
                y: 0
            }
        }
    ]

    transitions: [
        Transition {
            from: "shown"
            SequentialAnimation {
                PropertyAnimation {
                    target: tipDialog
                    properties: "y"
                    duration: 300
                    easing.type: "InOutQuad"
                }
                PropertyAction {
                    target: tipDialog
                    properties: "visible"
                    value: false
                }
            }
        },
        Transition {
            to: "shown"
            SequentialAnimation {
                PropertyAction {
                    target: tipDialog
                    properties: "visible"
                    value: true
                }
                PropertyAnimation {
                    target: tipDialog
                    properties: "y"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}

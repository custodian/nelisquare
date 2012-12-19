import Qt 4.7
import com.nokia.meego 1.0

Rectangle {
    id: tipDialog
    width: parent.width
    height: items.height + 20
    color: mytheme.colors.backgroundBlueDark
    state: "hidden"
    property string venueName: ""
    property int action: 0
    signal cancel()
    signal addTip(string comment)

    function reset() {
        tipText.text = "";
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
            color: mytheme.colors.textColorSign
        }

        TextArea {
            id: tipText
            x: 5
            width: parent.width - 10
            height: 130

            placeholderText: mytheme.textDefaultTip;
            textFormat: TextEdit.PlainText

            font.pixelSize: mytheme.fontSizeMedium

            onTextChanged: {
                if (text.length>200) {
                    errorHighlight = true;
                } else {
                    errorHighlight = false;
                }
            }
            Text {
                anchors { right: parent.right; bottom: parent.bottom; margins: mytheme.paddingMedium }
                font.pixelSize: mytheme.fontSizeMedium
                color: mytheme.colors.textColorTimestamp
                text: 200 - tipText.text.length
            }
        }

        Item {
            width: parent.width
            height: checkinButton.height

            ButtonGreen {
                id: checkinButton
                label: "ADD"
                width: parent.width - 130
                onClicked: {
                    tipDialog.addTip( tipText.text );
                }
            }

            ButtonGray{
                label: "Cancel"
                x: parent.width - 120
                width: 120
                onClicked: {
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
                y: -200-tipDialog.height
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

import Qt 4.7
import com.nokia.meego 1.0

Rectangle {
    id: comment
    width: parent.width
    height: items.height + 20
    color: mytheme.colors.backgroundBlueDark
    state: "hidden"
    signal cancel()
    signal shout(string comment)

    function reset() {
        commentText.text = ""
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
            color: mytheme.colors.textColorSign
        }

        TextArea {
            id: commentText
            x: 5
            width: parent.width - 10
            height: 130

            placeholderText: mytheme.textDefaultComment
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
                text: 200 - commentText.text.length
            }
        }

        Item {
            width: parent.width
            height: commentButton.height

            ButtonGreen {
                id: commentButton
                label: "Comment!"
                width: parent.width - 130
                onClicked: {
                    comment.shout( commentText.text )
                }
            }

            ButtonGray {
                label: "Cancel"
                x: parent.width - 120
                width: 120
                onClicked: {
                    comment.state = "hidden";
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
                target: comment
                y: -200-comment.height
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: comment
                y: 0
            }
        }
    ]

    transitions: [
        Transition {
            from: "shown"
            SequentialAnimation {
                PropertyAnimation {
                    target: comment
                    properties: "y"
                    duration: 300
                    easing.type: "InOutQuad"
                }
                PropertyAction {
                    target: comment
                    properties: "visible"
                    value: false
                }
            }
        },
        Transition {
            to: "shown"
            SequentialAnimation {
                PropertyAction {
                    target: comment
                    properties: "visible"
                    value: true
                }
                PropertyAnimation {
                    target: comment
                    properties: "y"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}

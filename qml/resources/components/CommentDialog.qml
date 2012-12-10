import Qt 4.7

Rectangle {
    id: comment
    width: parent.width
    height: items.height + 20
    color: mytheme.colors.backgroundBlueDark
    state: "hidden"
    signal cancel()
    signal shout(string comment)

    function reset() {
        commentText.text = mytheme.textDefaultComment;
    }

    function hideKeyboard() {
        commentText.closeSoftwareInputPanel();
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
            color: mytheme.colors.textColorSign
        }

        Rectangle {
            id: commentBox
            height: 135
            width: parent.width
            gradient: mytheme.gradientTextBox
            border.width: 1
            border.color: mytheme.colors.textboxBorderColor
            smooth: true

            Flickable {
                 id: flick

                 width: parent.width;
                 height: parent.height;
                 //contentWidth: commentText.paintedWidth
                 //contentHeight: commentText.paintedHeight
                 clip: true

                 function ensureVisible(r)
                  {
                      if (contentX >= r.x)
                          contentX = r.x;
                      else if (contentX+width <= r.x+r.width)
                          contentX = r.x+r.width-width;
                      if (contentY >= r.y)
                          contentY = r.y;
                      else if (contentY+height <= r.y+r.height)
                          contentY = r.y+r.height-height;
                  }

                TextEdit {
                    id: commentText
                    wrapMode: TextEdit.Wrap
                    text: mytheme.textDefaultComment
                    textFormat: TextEdit.PlainText
                    width: parent.width - 10
                    height: parent.height - 10
                    x: 5
                    y: 5
                    color: mytheme.colors.textColor
                    font.pixelSize: 24
                    onCursorRectangleChanged: flick.ensureVisible(cursorRectangle)


                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            commentText.focus = true;
                            if(commentText.text == mytheme.textDefaultComment) {
                                commentText.text = "";
                            }
                            if (commentText.text != "") {
                                commentText.cursorPosition = commentText.positionAt(mouseX,mouseY);
                            }
                        }
                    }
                }
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
                    hideKeyboard();
                    comment.shout( commentText.text )
                }
            }

            ButtonGreen {
                label: "Cancel"
                x: parent.width - 120
                width: 120
                onClicked: {
                    hideKeyboard();
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

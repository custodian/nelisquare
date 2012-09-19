import Qt 4.7

Rectangle {
    id: waitingIndicator
    y: 80
    anchors.horizontalCenter: parent.horizontalCenter
    property string label: "ONE MOMENT..."
    width: doneText.width+50
    height: doneText.height+30
    color: theme.highlightColor
    radius: 2
    opacity: 0.9
    smooth: true
    state: "hidden"

    Text {
        id: doneText
        text: waitingIndicator.label
        color: theme.textColorSign
        font.pixelSize: theme.font.sizeSigns
        anchors.centerIn: parent
    }

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: waitingIndicator
                y: -100 - waitingIndicator.height - 1
            }
            PropertyChanges {
                target: window
                blurred: false
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: waitingIndicator
                y: 100
            }
            PropertyChanges {
                target: window
                blurred: true
            }
        }
    ]

    transitions: [
        Transition {
            from: "shown"
            SequentialAnimation {
                PropertyAnimation {
                    target: waitingIndicator
                    properties: "y"
                    duration: 200
                    easing.type: "InOutCubic"
                }
                PropertyAction {
                    target: waitingIndicator
                    properties: "visible"
                    value: false
                }
            }
        },
        Transition {
            to: "shown"
            SequentialAnimation {
                PropertyAction {
                    target: waitingIndicator
                    properties: "visible"
                    value: true
                }
                PropertyAnimation {
                    target: waitingIndicator
                    properties: "y"
                    duration: 200
                    easing.type: "InOutCubic"
                }
            }
        }
    ]
}

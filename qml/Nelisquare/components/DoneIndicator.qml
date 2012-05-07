import Qt 4.7

Rectangle {
    id: doneIndicator
    anchors.horizontalCenter: parent.horizontalCenter
    y: 60
    property string label: "Done"
    width: parent.width - 20
    height: doneItems.height+20
    color: "#3B5998"
    radius: 5
    opacity: 0.9
    smooth: true
    state: "hidden"

    Row {
        id: doneItems
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10
        width: parent.width - 20
        height: doneText.height<50 ? 50 : doneText.height

        Image {
            id: icon
            source: "../pics/accepted_48.png"
        }

        Text {
            id: doneText
            text: doneIndicator.label
            width: parent.width - icon.width - 20
            color: "#eee"
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            font.pixelSize: 20
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    states:
        State {
        name: "hidden"
        PropertyChanges {
            target: doneIndicator
            y: 0 - doneIndicator.height - 1
        }
    }
    State {
        name: "shown"
        PropertyChanges {
            target: doneIndicator
            y: 10
        }
    }

    transitions: [
        Transition {
            SequentialAnimation {
                PropertyAnimation {
                    target: doneIndicator
                    properties: "y"
                    duration: 200
                    easing.type: "InOutCubic"
                }
                PropertyAnimation {
                    target: doneIndicator
                    properties: "y"
                    duration: 2000
                }
                ScriptAction {
                    script: {
                        doneIndicator.state = "hidden";
                    }
                }
            }
        }
    ]
}

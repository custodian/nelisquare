import Qt 4.7

Rectangle {
    id: waitingIndicator
    property int waitCount: 0
    property string currentMessage: mytheme.textDefaultWait

    anchors.horizontalCenter: parent.horizontalCenter
    width: doneText.width+90
    height: doneText.height+35
    color: mytheme.colors.waitingInicatorBackGround
    radius: 2
    opacity: 0.9
    smooth: true
    state: "hidden"

    /*ListModel {
        id: messages

        onCountChanged: {
            if (count>0){
                currentMessage = messages.get(count-1);
            }
        }
    }*/

    onWaitCountChanged: {
        if (waitCount > 0) {
            state = "shown";
        } else {
            waitCount = 0;
            state = "hidden";
        }
    }

    function show(message) {
        waitCount++;
        /*if (message === undefined) {
            message = mytheme.textDefaultWait
        }
        messages.append(message);
        */
    }
    function hide() {
        waitCount--;
    }

    Text {
        id: doneText
        text: waitingIndicator.currentMessage
        color: mytheme.colors.textColorOptions
        font.pixelSize: mytheme.font.sizeSigns
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 5
    }

    /*Animated*/Image {
        id: loader
        source: "../pics/waiting.gif"
        anchors.top: doneText.bottom
        anchors.topMargin: 5
        anchors.horizontalCenter: parent.horizontalCenter
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            hide()
        }
    }

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: waitingIndicator
                y: -waitingIndicator.height
            }
            PropertyChanges {
                target: waitingIndicator
                visible: false
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: waitingIndicator
                visible: true
            }
            PropertyChanges {
                target: waitingIndicator
                y: 0
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

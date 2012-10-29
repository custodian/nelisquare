import Qt 4.7
import QtQuick 1.1
import "../components"

Rectangle {
    signal user(string user)
    signal prevPhoto()
    signal nextPhoto()

    id: photoDetails
    width: parent.width
    height: parent.height
    state: "hidden"
    color: theme.backgroundMain

    property string photoUrl: ""
    property alias owner: photoOwner

    Image {
        id: fullImage
        width: parent.width
        height: parent.height - photoOwner.height
        anchors.top: parent.top
        asynchronous: true
        //cache: false
        fillMode: Image.PreserveAspectFit
        source: photoDetails.photoUrl // + "hjgjh"
        onProgressChanged: {
            loadProgress.percent = progress*100;
        }

        ProgressBar {
            id: loadProgress
            anchors.centerIn: fullImage
            radiusValue: 5
            height: 16
            width: parent.width*0.8
            visible: (fullImage.status != Image.Ready)
        }

        /*PinchArea {
            anchors.fill: parent
            pinch.target: fullImage
            enabled: true

            onPinchFinished: {
                console.log("PINCH: " + JSON.stringify(pinch));
            }
        }*/

        SwypeArea {
            onSwype: {
                if (type === direction.LEFT || type === direction.UP) {
                    photoDetails.prevPhoto();
                } else if (type === direction.RIGHT || type === direction.DOWN) {
                    photoDetails.nextPhoto();
                }
            }
        }
    }

    EventBox {
        id: photoOwner
        anchors.bottom: parent.bottom
        fontSize: 18
        onAreaClicked: {
            user(photoDetails.owner.userID);
        }
    }

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: photoDetails
                x: parent.width
            }
        },
        State {
            name: "hiddenLeft"
            PropertyChanges {
                target: photoDetails
                x: -parent.width
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: photoDetails
                x: 0
            }
        }
    ]

    transitions: [
        Transition {
            from: "shown"
            SequentialAnimation {
                PropertyAnimation {
                    target: photoDetails
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
                PropertyAction {
                    target: photoDetails
                    properties: "visible"
                    value: false
                }
            }
        },
        Transition {
            to: "shown"
            SequentialAnimation {
                PropertyAction {
                    target: photoDetails
                    properties: "visible"
                    value: true
                }
                PropertyAnimation {
                    target: photoDetails
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}

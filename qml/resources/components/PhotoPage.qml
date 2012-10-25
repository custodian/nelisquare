import Qt 4.7

Rectangle {
    signal user(string user)

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
        source: photoDetails.photoUrl

        Image {
            id: loader
            anchors.centerIn: fullImage
            asynchronous: true
            source: "../pics/loader.png"
            visible: (fullImage.status != Image.Ready)
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

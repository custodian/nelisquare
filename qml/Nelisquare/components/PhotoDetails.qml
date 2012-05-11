import Qt 4.7

Rectangle {
    signal user(string user)

    id: photoDetails
    width: parent.width
    height: parent.height

    property string photoUrl: ""
    property alias owner: photoOwner

    Column {
        width: parent.width
        height: parent.height

        Flickable {
            id: photoArea
            width: parent.width
            height: parent.height - photoOwner.height

            clip: true
            flickableDirection: Flickable.HorizontalAndVerticalFlick
            boundsBehavior: Flickable.StopAtBounds

            pressDelay: 100
            Row {
                onWidthChanged: {
                    photoArea.contentWidth = width;
                }
                onHeightChanged: {
                    photoArea.contentHeight = height;
                }
                Image {
                    id: fullImage
                    fillMode: Image.PreserveAspectFit
                    source: photoDetails.photoUrl
                }
            }
        }

        EventBox {
            id: photoOwner
            fontSize: 18
            onAreaClicked: {
                user(photoDetails.owner.userID);
            }
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
            SequentialAnimation {
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

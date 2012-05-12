import Qt 4.7
import "../colibri"

Rectangle {
    signal authDelete()
    signal iconsetChange(string type)
    signal orientationChange(string type)

    id: settingsDialog
    color: "#555"

    width: parent.width
    height: parent.height    

    Flickable{

        id: flickableArea
        width: parent.width
        contentWidth: parent.width
        height: settingsDialog.height - y

        clip: true
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds
        pressDelay: 100

        Column {
            onHeightChanged: {
                flickableArea.contentHeight = height;
            }

            width: parent.width - 20
            y: 10
            x: 10
            spacing: 10

            //OrientationLock
            Row {
                width: parent.width

                Text {
                    color: "#eee"
                    text: "Orientation"
                    anchors.verticalCenter: parent.verticalCenter
                }

                ToolbarButton {
                    id: orientationAuto
                    anchors.right: orientationLandscape.left
                    selected: window.orientationType == label
                    imageSize: 64
                    image: "orientation_auto.png"
                    label: "Auto"
                    onClicked: orientationChange(label)
                }
                ToolbarButton {
                    id: orientationLandscape
                    anchors.right: orientationPortrait.left
                    selected: window.orientationType == label
                    imageSize: 64
                    image: "orientation_landscape.png"
                    label: "Landscape"
                    onClicked: orientationChange(label)
                }
                ToolbarButton {
                    id: orientationPortrait
                    anchors.right: parent.right
                    selected: window.orientationType == label
                    imageSize: 64
                    image: "orientation_portrait.png"
                    label: "Portrait"
                    onClicked: orientationChange(label)
                }
            }

            //IconSet
            Row {
                width: parent.width

                Text {
                    color: "#eee"
                    text: "Icon set"
                    anchors.verticalCenter: parent.verticalCenter
                }

                ToolbarButton {
                    id: iconSetClassic
                    anchors.right: iconSetHanddraw.left
                    selected: window.iconset == label
                    imageSize: 64
                    image: "../iconset_classic.png"
                    label: "Classic"
                    onClicked: iconsetChange(label)
                }
                ToolbarButton {
                    id: iconSetHanddraw
                    anchors.right: parent.right
                    selected: window.iconset == label
                    imageSize: 64
                    image: "../iconset_handdraw.png"
                    label: "Handdraw"
                    onClicked: iconsetChange(label)
                }
            }

            //DefaultPhotoPreviewSize
            Row {
                width: parent.width

                Text {
                    color: "#eee"
                    text: "Revoke auth token"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Button {
                    width: 150
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    pic: "stop.png"
                    imageSize: 48
                    onClicked: {
                        authDelete()
                    }
                }
            }

        }
    }

    onStateChanged: {

    }

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: settingsDialog
                x: -parent.width
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: settingsDialog
                x: 0
            }
        }
    ]

    transitions: [
        Transition {
            SequentialAnimation {
                PropertyAnimation {
                    target: settingsDialog
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}

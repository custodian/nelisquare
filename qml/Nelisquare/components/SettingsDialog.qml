import Qt 4.7

Rectangle {
    signal authDeleted()
    signal iconsetChanged(string type)
    signal orientationChanged(string type)
    signal mapProviderChanged(string type)

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
                    onClicked: orientationChanged(label)
                }
                ToolbarButton {
                    id: orientationLandscape
                    anchors.right: orientationPortrait.left
                    selected: window.orientationType == label
                    imageSize: 64
                    image: "orientation_landscape.png"
                    label: "Landscape"
                    onClicked: orientationChanged(label)
                }
                ToolbarButton {
                    id: orientationPortrait
                    anchors.right: parent.right
                    selected: window.orientationType == label
                    imageSize: 64
                    image: "orientation_portrait.png"
                    label: "Portrait"
                    onClicked: orientationChanged(label)
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
                    onClicked: iconsetChanged(label)
                }
                ToolbarButton {
                    id: iconSetHanddraw
                    anchors.right: parent.right
                    selected: window.iconset == label
                    imageSize: 64
                    image: "../iconset_handdraw.png"
                    label: "Handdraw"
                    onClicked: iconsetChanged(label)
                }
            }

            //Map provider
            Row {
                width: parent.width
                Text {
                    color: "#eee"
                    text: "Map provider"
                    anchors.verticalCenter: parent.verticalCenter
                }

                ToolbarButton {
                    id: mapProviderGoogleMaps
                    anchors.right: mapProviderOSM.left
                    selected: window.mapprovider == label
                    imageSize: 64
                    image: "icon_google_maps.png"
                    label: "Google Maps"
                    onClicked: mapProviderChanged(label)
                }
                ToolbarButton {
                    id: mapProviderOSM
                    anchors.right: parent.right
                    selected: window.mapprovider == label
                    imageSize: 64
                    image: "icon_osm.png"
                    label: "OpenStreetMap"
                    onClicked: mapProviderChanged(label)
                }

            }

            //Revoke auth token
            Row {
                width: parent.width

                Text {
                    color: "#eee"
                    text: "Revoke auth token"
                    anchors.verticalCenter: parent.verticalCenter
                }

                ButtonEx {
                    width: 150
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    pic: "stop.png"
                    imageSize: 48
                    onClicked: {
                        authDeleted()
                    }
                }
            }

            Row {
                width: parent.width

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: theme.textHelp1
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

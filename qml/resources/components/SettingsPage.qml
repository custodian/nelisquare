import Qt 4.7

Rectangle {
    signal authDeleted()
    signal iconsetChanged(string type)
    signal orientationChanged(string type)
    signal mapProviderChanged(string type)

    id: settings
    color: theme.backgroundSettings
    state: "hidden"

    width: parent.width
    height: parent.height    

    GreenLine {
        id: settingsLabel
        text: "SETTINGS"
        size: theme.font.sizeSettigs
        height: 50
    }

    Flickable{

        id: flickableArea

        anchors.top: settingsLabel.bottom
        width: parent.width
        contentWidth: parent.width
        height: settings.height - y

        clip: true
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds
        pressDelay: 100

        Column {
            onHeightChanged: {
                flickableArea.contentHeight = height;
            }

            width: parent.width - 20
            y: 30
            x: 10
            spacing: 0

            //OrientationLock
            Text {
                color: theme.textColorSign
                text: "Screen orientation"
                font.pixelSize: theme.font.sizeSettigs
            }

            Row {
                width: parent.width

                ToolbarTextButton {
                    selected: window.orientationType == "auto"
                    label: "AUTO"
                    onClicked: orientationChanged("auto")
                }
                ToolbarTextButton {
                    selected: window.orientationType == "landscape"
                    label: "LANDSCAPE"
                    onClicked: orientationChanged("landscape")
                }
                ToolbarTextButton {
                    selected: window.orientationType == "portrait"
                    label: "PORTRAIT"
                    onClicked: orientationChanged("portrait")
                }
            }

            //Icons
            Text {
                color: theme.textColorSign
                text: "Icons"
                font.pixelSize: theme.font.sizeSettigs
            }
            Row {
                width: parent.width

                ToolbarTextButton {
                    selected: window.iconset == "original"
                    label: "ORIGINAL"
                    onClicked: iconsetChanged("original")
                }
                ToolbarTextButton {
                    selected: window.iconset == "colorful"
                    label: "COLOURFUL"
                    onClicked: iconsetChanged("colorful")
                }
            }

            //Map provider
            Text {
                color: theme.textColorSign
                text: "Map provider"
                font.pixelSize: theme.font.sizeSettigs
            }
            Row {
                width: parent.width

                ToolbarTextButton {
                    selected: window.mapprovider == "googlemaps"
                    label: "GOOGLE MAPS"
                    onClicked: mapProviderChanged("googlemaps")
                }
                ToolbarTextButton {
                    selected: window.mapprovider == "osm"
                    label: "OPENSTREETMAP"
                    onClicked: mapProviderChanged("osm")
                }

            }

            //Revoke auth token
            Text {
                color: theme.textColorSign
                text: "Reset authentication"
                font.pixelSize: theme.font.sizeSettigs
            }
            Row {
                width: parent.width

                ToolbarTextButton {
                    label: "REVOKE"
                    onClicked: {
                        authDeleted()
                    }
                }
            }


            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: theme.textHelp1
                color: theme.textColorSign
                font.pixelSize: theme.font.sizeHelp

                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: theme.textHelp2
                color: theme.textColorSign
                font.pixelSize: theme.font.sizeHelp
                font.bold: true

                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: theme.textHelp3
                color: theme.textColorSign
                font.pixelSize: theme.font.sizeHelp

                horizontalAlignment: Text.AlignHCenter
            }

        }
    }

    onStateChanged: {

    }

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: settings
                x: -parent.width
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: settings
                x: 0
            }
        }
    ]

    transitions: [
        Transition {
            from: "shown"
            SequentialAnimation {
                PropertyAnimation {
                    target: settings
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
                PropertyAction {
                    target: settings
                    properties: "visible"
                    value: false
                }
            }
        },
        Transition {
            to: "shown"
            SequentialAnimation {
                PropertyAction {
                    target: settings
                    properties: "visible"
                    value: true
                }
                PropertyAnimation {
                    target: settings
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}

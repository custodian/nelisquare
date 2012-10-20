import Qt 4.7

Rectangle {
    signal authDeleted()
    signal cacheReseted()
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
                color: theme.textColorOptions
                text: "Screen orientation"
                font.pixelSize: theme.font.sizeSettigs
            }

            Row {
                width: parent.width
                spacing: 20

                ToolbarTextButton {
                    height: 35
                    selected: window.orientationType == "auto"
                    label: "AUTO"
                    onClicked: orientationChanged("auto")
                }
                ToolbarTextButton {
                    height: 35
                    selected: window.orientationType == "landscape"
                    label: "LANDSCAPE"
                    onClicked: orientationChanged("landscape")
                }
                ToolbarTextButton {
                    height: 35
                    selected: window.orientationType == "portrait"
                    label: "PORTRAIT"
                    onClicked: orientationChanged("portrait")
                }
            }

            Item{
                height: 20
                width: parent.width
            }

            //Map provider
            Text {
                color: theme.textColorOptions
                text: "Map provider"
                font.pixelSize: theme.font.sizeSettigs
            }
            Row {
                width: parent.width
                spacing: 20

                ToolbarTextButton {
                    height: 35
                    selected: window.mapprovider == "googlemaps"
                    label: "GOOGLE MAPS"
                    onClicked: mapProviderChanged("googlemaps")
                }
                ToolbarTextButton {
                    height: 35
                    selected: window.mapprovider == "osm"
                    label: "OPENSTREETMAP"
                    onClicked: mapProviderChanged("osm")
                }

            }

            Item{
                height: 20
                width: parent.width
            }

            //Revoke auth token
            Text {
                color: theme.textColorOptions
                text: "Reset authentication"
                font.pixelSize: theme.font.sizeSettigs
            }
            Row {
                width: parent.width

                ToolbarTextButton {
                    height: 35
                    label: "REVOKE"
                    onClicked: {
                        authDeleted()
                    }
                }
            }

            Item{
                height: 20
                width: parent.width
            }

            //App cache
            Text {
                color: theme.textColorOptions
                text: "App Cache"
                font.pixelSize: theme.font.sizeSettigs
            }
            Row {
                width: parent.width
                spacing: 20

                ToolbarTextButton {
                    height: 35
                    selected: false
                    label: "RESET"
                    onClicked: cacheReseted()
                }
            }

            Item{
                height: 20
                width: parent.width
            }

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                source: "../pics/separator.png"
            }

            Item{
                height: 20
                width: parent.width
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: theme.textHelp1
                color: theme.textColorOptions
                font.pixelSize: theme.font.sizeHelp

                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: theme.textHelp2
                color: theme.textColorOptions
                font.pixelSize: theme.font.sizeHelp
                font.bold: true

                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: theme.textHelp3
                color: theme.textColorOptions
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

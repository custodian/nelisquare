import Qt 4.7
import "../build.info.js" as BuildInfo
import "../components"

Rectangle {
    signal authDeleted()

    signal settingsChanged(string type, string value);

    property string cacheSize: "undefined"

    id: settings
    color: theme.colors.backgroundMain
    state: "hidden"

    width: parent.width
    height: parent.height    

    LineGreen {
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
                flickableArea.contentHeight = height + y;
            }

            width: parent.width - 20
            y: 30
            x: 10
            spacing: 0

            //Check updates
            Text {
                color: theme.colors.textColorOptions
                text: "Check for updates"
                font.pixelSize: theme.font.sizeSettigs
            }
            Row {
                width: parent.width
                spacing: 20

                ToolbarTextButton {
                    height: 35
                    selected: window.checkupdates === "none"
                    label: "NONE"
                    onClicked: settingsChanged("checkupdates","none")
                }
                ToolbarTextButton {
                    height: 35
                    selected: window.checkupdates === "stable"
                    label: "STABLE"
                    onClicked: settingsChanged("checkupdates","stable")
                }
                ToolbarTextButton {
                    height: 35
                    selected: window.checkupdates === "developer"
                    label: "BETA"
                    onClicked: settingsChanged("checkupdates","developer")
                }

            }
            Item{
                height: 20
                width: parent.width
            }

            //OrientationLock
            Text {
                color: theme.colors.textColorOptions
                text: "Screen orientation"
                font.pixelSize: theme.font.sizeSettigs
            }

            Row {
                width: parent.width
                spacing: 20

                ToolbarTextButton {
                    height: 35
                    selected: window.orientationType === "auto"
                    label: "AUTO"
                    onClicked: settingsChanged("orientation","auto")
                }
                ToolbarTextButton {
                    height: 35
                    selected: window.orientationType === "landscape"
                    label: "LANDSCAPE"
                    onClicked: settingsChanged("orientation","landscape")
                }
                ToolbarTextButton {
                    height: 35
                    selected: window.orientationType === "portrait"
                    label: "PORTRAIT"
                    onClicked: settingsChanged("orientation","portrait")
                }
            }

            Item{
                height: 20
                width: parent.width
            }

            //Map provider
            Text {
                color: theme.colors.textColorOptions
                text: "Map provider"
                font.pixelSize: theme.font.sizeSettigs
            }
            Row {
                width: parent.width
                spacing: 20

                ToolbarTextButton {
                    height: 35
                    selected: window.mapprovider === "googlemaps"
                    label: "GOOGLE MAPS"
                    onClicked: settingsChanged("mapprovider","googlemaps")
                }
                ToolbarTextButton {
                    height: 35
                    selected: window.mapprovider === "osm"
                    label: "OPENSTREETMAP"
                    onClicked: settingsChanged("mapprovider","osm")
                }

            }

            Item {
                height: 20
                width: parent.width
            }

            //Molome integration
            Text {
                color: theme.colors.textColorOptions
                text: "MOLO.me integration (beta)"
                font.pixelSize: theme.font.sizeSettigs
                visible: theme.platform === "meego"
            }
            Row {
                width: parent.width
                spacing: 20

                ToolbarTextButton {
                    height: 35
                    label: "DOWNLOAD MOLO.ME NOW!"
                    onClicked: {
                        Qt.openUrlExternally("http://molo.me/meego");
                    }
                    visible: !window.molome_present;
                }

                ToolbarTextButton {
                    height: 35
                    selected: true
                    label: (window.molome_installed ? "ENABLED" : "DISABLED")
                    onClicked: molome.updateinfo();
                    visible: window.molome_present;
                }
                ToolbarTextButton {
                    height: 35
                    selected: false
                    label: "INSTALL"
                    onClicked: {
                        waiting.show();
                        selected = true;
                        molome.install();
                    }
                    visible: !window.molome_installed && window.molome_present;
                    onVisibleChanged: {
                        if (selected) {
                            waiting.hide();
                            selected = false;
                        }
                    }
                }
                ToolbarTextButton {
                    height: 35
                    selected: false
                    label: "UNINSTALL"
                    onClicked: {
                        waiting.show();
                        selected = true;
                        molome.uninstall();
                    }
                    visible: window.molome_installed && window.molome_present;
                    onVisibleChanged: {
                        if (selected) {
                            waiting.hide();
                            selected = false;
                        }
                    }
                }
                visible: theme.platform === "meego";
            }
            Item{
                height: 20
                width: parent.width
                visible: theme.platform === "meego";
            }

            //Image loading settings
            Text {
                color: theme.colors.textColorOptions
                text: "Load images"
                font.pixelSize: theme.font.sizeSettigs
            }
            Row {
                width: parent.width
                spacing: 20

                ToolbarTextButton {
                    height: 35
                    selected: window.imageLoadType === "cached"
                    label: "CACHED"
                    onClicked: settingsChanged("imageload","cached");
                }

                ToolbarTextButton {
                    height: 35
                    selected: window.imageLoadType === "all"
                    label: "ALL"
                    onClicked: settingsChanged("imageload","all");
                }
            }
            Item{
                height: 20
                width: parent.width
            }

            //GPS Unlock time
            Text {
                color: theme.colors.textColorOptions
                text: "GPS Unlock timeout"
                font.pixelSize: theme.font.sizeSettigs
            }
            Row {
                width: parent.width
                spacing: 20

                ToolbarTextButton {
                    height: 35
                    selected: window.gpsUplockTime === 0
                    label: "AT ONCE"
                    onClicked: settingsChanged("gpsunlock",0);
                }

                ToolbarTextButton {
                    height: 35
                    selected: window.gpsUplockTime === 30
                    label: "30 SEC"
                    onClicked: settingsChanged("gpsunlock",30);
                }

                ToolbarTextButton {
                    height: 35
                    selected: window.gpsUplockTime === 60
                    label: "60 SEC"
                    onClicked: settingsChanged("gpsunlock",60);
                }
            }
            Item{
                height: 20
                width: parent.width
            }

            Text {
                color: theme.colors.textColorOptions
                text: "Feed autoupdate"
                font.pixelSize: theme.font.sizeSettigs
            }
            Row {
                width: parent.width
                spacing: 20

                ToolbarTextButton {
                    height: 35
                    selected: window.feedAutoUpdate === 0
                    label: "OFF"
                    onClicked: settingsChanged("feedupdate",0);
                }

                ToolbarTextButton {
                    height: 35
                    selected: window.feedAutoUpdate === 120
                    label: "2 MIN"
                    onClicked: settingsChanged("feedupdate",120);
                }

                ToolbarTextButton {
                    height: 35
                    selected: window.feedAutoUpdate === 300
                    label: "5 MIN"
                    onClicked: settingsChanged("feedupdate",300);
                }

                ToolbarTextButton {
                    height: 35
                    selected: window.feedAutoUpdate === 600
                    label: "10 MIN"
                    onClicked: settingsChanged("feedupdate", 600);
                }
            }
            Item{
                height: 20
                width: parent.width
            }

            Text {
                color: theme.colors.textColorOptions
                text: "Nelisquare theme"
                font.pixelSize: theme.font.sizeSettigs
            }
            Row {
                width: parent.width
                spacing: 20

                ToolbarTextButton {
                    height: 35
                    selected: theme.name === "light"
                    label: "LIGHT"
                    onClicked: settingsChanged("theme","light");
                }

                ToolbarTextButton {
                    height: 35
                    selected: theme.name === "dark"
                    label: "DARK"
                    onClicked: settingsChanged("theme","dark");
                }
            }
            Item{
                height: 20
                width: parent.width
            }

            //App cache
            Text {
                color: theme.colors.textColorOptions
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
                    onClicked: {
                        cache.reset();
                        cacheSize = cache.info();
                    }
                }

                ToolbarTextButton {
                    height: 35
                    selected: false
                    label: "Size: " + cacheSize;
                }
            }

            Item{
                height: 20
                width: parent.width
            }

            //Revoke auth token
            Text {
                color: theme.colors.textColorOptions
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

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                source: "../pics/"+theme.name+"/separator.png"
            }

            Item{
                height: 20
                width: parent.width
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: theme.textHelp1
                color: theme.colors.textColorOptions
                font.pixelSize: theme.font.sizeHelp

                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: theme.textHelp2
                color: theme.colors.textColorOptions
                font.pixelSize: theme.font.sizeHelp
                font.bold: true

                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: theme.textVersionInfo + BuildInfo.version
                color: theme.colors.textColorOptions
                font.pixelSize: theme.font.sizeHelp
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: theme.textBuildInfo + BuildInfo.build
                color: theme.colors.textColorOptions
                font.pixelSize: theme.font.sizeHelp
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: theme.textHelp3
                color: theme.colors.textColorOptions
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
                x: parent.width
            }
        },
        State {
            name: "hiddenLeft"
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

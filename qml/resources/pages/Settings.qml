import Qt 4.7
import "../build.info.js" as BuildInfo
import "../components"

//TODO: dont forget about PAGESTACK:

Rectangle {
    signal authDeleted()

    signal settingsChanged(string type, string value);

    property string cacheSize: "updating..."

    id: settings
    color: theme.colors.backgroundMain

    width: parent.width
    height: parent.height    

    function load() {
        var page = settings;
        page.authDeleted.connect(function(){
            configuration.settingChanged("accesstoken","");
        });
        page.settingsChanged.connect(function(type,value) {
            configuration.settingChanged("settings."+type,value);
        });
        cacheUpdater.start();
    }

    Timer {
        id: cacheUpdater
        interval: 50
        repeat: false
        onTriggered: {
            cacheSize = cache.info();
        }
    }

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
                    selected: configuration.checkupdates === "none"
                    label: "NONE"
                    onClicked: settingsChanged("checkupdates","none")
                }
                ToolbarTextButton {
                    height: 35
                    selected: configuration.checkupdates === "stable"
                    label: "STABLE"
                    onClicked: settingsChanged("checkupdates","stable")
                }
                ToolbarTextButton {
                    height: 35
                    selected: configuration.checkupdates === "developer"
                    label: "BETA"
                    onClicked: settingsChanged("checkupdates","developer")
                }
                ToolbarTextButton {
                    height: 35
                    selected: configuration.checkupdates === "alpha"
                    label: "ALPHA"
                    onClicked: settingsChanged("checkupdates","alpha")
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
                    selected: configuration.orientationType === "auto"
                    label: "AUTO"
                    onClicked: settingsChanged("orientation","auto")
                }
                ToolbarTextButton {
                    height: 35
                    selected: configuration.orientationType === "landscape"
                    label: "LANDSCAPE"
                    onClicked: settingsChanged("orientation","landscape")
                }
                ToolbarTextButton {
                    height: 35
                    selected: configuration.orientationType === "portrait"
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
                    selected: configuration.mapprovider === "google"
                    label: "GOOGLE"
                    onClicked: settingsChanged("mapprovider","google")
                }
                ToolbarTextButton {
                    height: 35
                    selected: configuration.mapprovider === "openstreetmap"
                    label: "OSM"
                    onClicked: settingsChanged("mapprovider","openstreetmap")
                }
                ToolbarTextButton {
                    height: 35
                    selected: configuration.mapprovider === "nokia"
                    label: "NOKIA"
                    onClicked: settingsChanged("mapprovider","nokia")
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
                visible: configuration.platform === "meego"
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
                visible: configuration.platform === "meego";
            }
            Item{
                height: 20
                width: parent.width
                visible: configuration.platform === "meego";
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
                    selected: configuration.imageLoadType === "cached"
                    label: "CACHED"
                    onClicked: settingsChanged("imageload","cached");
                }

                ToolbarTextButton {
                    height: 35
                    selected: configuration.imageLoadType === "all"
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
                    selected: configuration.gpsUplockTime === 0
                    label: "AT ONCE"
                    onClicked: settingsChanged("gpsunlock",0);
                }

                ToolbarTextButton {
                    height: 35
                    selected: configuration.gpsUplockTime === 30
                    label: "30 SEC"
                    onClicked: settingsChanged("gpsunlock",30);
                }

                ToolbarTextButton {
                    height: 35
                    selected: configuration.gpsUplockTime === 60
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
                    selected: configuration.feedAutoUpdate === 0
                    label: "OFF"
                    onClicked: settingsChanged("feedupdate",0);
                }

                ToolbarTextButton {
                    height: 35
                    selected: configuration.feedAutoUpdate === 120
                    label: "2 MIN"
                    onClicked: settingsChanged("feedupdate",120);
                }

                ToolbarTextButton {
                    height: 35
                    selected: configuration.feedAutoUpdate === 300
                    label: "5 MIN"
                    onClicked: settingsChanged("feedupdate",300);
                }

                ToolbarTextButton {
                    height: 35
                    selected: configuration.feedAutoUpdate === 600
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
}

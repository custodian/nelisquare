import Qt 4.7
import com.nokia.meego 1.0
import "../build.info.js" as BuildInfo
import "../components"

//TODO: dont forget about PAGESTACK:

PageWrapper {
    signal authDeleted()

    signal settingsChanged(string type, string value);

    property string cacheSize: "updating..."

    id: settings
    color: mytheme.colors.backgroundMain

    width: parent.width
    height: parent.height

    tools: ToolBarLayout{
        ToolIcon{
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }

        ToolIcon {
            platformIconId: "toolbar-view-menu"
            onClicked: {
                menu.open();
            }
        }
    }

    QueryDialog  {
        id: eraseSettingsDialog
        icon: "image://theme/icon-l-accounts"
        titleText: "Reset settings"
        message: "This action will erase all data including auth token, application settings and cache."
        acceptButtonText: "Yes, clear the data"
        rejectButtonText: "No, thanks"
        onAccepted: {
            configuration.resetSettings();
        }
    }

    Menu {
        id: menu
        visualParent: mainWindowPage
        MenuLayout {
            MenuItem {
                text: qsTr("Reset settings")
                onClicked: {
                    eraseSettingsDialog.open();
                }
            }
        }
    }

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
        interval: 2000
        repeat: false
        onTriggered: {
            cacheSize = cache.info();
        }
    }

    LineGreen {
        id: settingsLabel
        text: "SETTINGS"
        size: mytheme.font.sizeSettigs
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
                color: mytheme.colors.textColorOptions
                text: "Check for updates"
                font.pixelSize: mytheme.font.sizeSettigs
            }
            ButtonRow {
                anchors.horizontalCenter: parent.horizontalCenter
                //width: parent.width
                onVisibleChanged: {
                    if (visible) {
                        switch(configuration.checkupdates) {
                        case "none":
                            checkedButton = btnUpdateNone;
                            break;
                        case "stable":
                            checkedButton = btnUpdateStable;
                            break;
                        case "developer":
                            checkedButton = btnUpdateBeta;
                            break;
                        case "alpha":
                            checkedButton = btnUpdateAlpha;
                            break;
                        }
                    }
                }
                Button{
                    id: btnUpdateNone
                    text: qsTr("None")
                    onClicked: settingsChanged("checkupdates","none")
                }

                Button{
                    id: btnUpdateStable
                    text: qsTr("Stable")
                    onClicked: settingsChanged("checkupdates","stable")
                }
                Button{
                    id: btnUpdateBeta
                    text: qsTr("Beta")
                    onClicked: settingsChanged("checkupdates","developer")
                }

                Button{
                    id: btnUpdateAlpha
                    text: qsTr("Alpha")
                    onClicked: settingsChanged("checkupdates","alpha")
                }
            }
            Item{
                height: 20
                width: parent.width
            }

            //THEME
            Text {
                color: mytheme.colors.textColorOptions
                text: "Nelisquare theme"
                font.pixelSize: mytheme.font.sizeSettigs
            }
            ButtonRow {
                anchors.horizontalCenter: parent.horizontalCenter
                //width: parent.width
                onVisibleChanged: {
                    if (visible) {
                        switch(mytheme.name) {
                        case "light":
                            checkedButton = btnThemeLight;
                            break;
                        case "dark":
                            checkedButton = btnThemeDark;
                            break;
                        }
                    }
                }
                Button{
                    id: btnThemeLight
                    text: qsTr("Light")
                    onClicked: settingsChanged("theme","light")
                }

                Button{
                    id: btnThemeDark
                    text: qsTr("Dark")
                    onClicked: settingsChanged("theme","dark")
                }
            }
            Item{
                height: 20
                width: parent.width
            }

            //OrientationLock
            Text {
                color: mytheme.colors.textColorOptions
                text: "Screen orientation"
                font.pixelSize: mytheme.font.sizeSettigs
            }
            ButtonRow {
                anchors.horizontalCenter: parent.horizontalCenter
                //width: parent.width
                onVisibleChanged: {
                    if (visible) {
                        switch(configuration.orientationType) {
                        case "auto":
                            checkedButton = btnOrientationAuto;
                            break;
                        case "landscape":
                            checkedButton = btnOrientationLandscape;
                            break;
                        case "portrait":
                            checkedButton = btnOrientationPortrait;
                            break;
                        }
                    }
                }
                Button{
                    id: btnOrientationAuto
                    text: qsTr("Auto")
                    onClicked: settingsChanged("orientation","auto")
                }

                Button{
                    id: btnOrientationLandscape
                    text: qsTr("Landscape")
                    onClicked: settingsChanged("orientation","landscape")
                }
                Button{
                    id: btnOrientationPortrait
                    text: qsTr("Portrait")
                    onClicked: settingsChanged("orientation","portrait")
                }
            }
            Item{
                height: 20
                width: parent.width
            }

            //Map provider
            Text {
                color: mytheme.colors.textColorOptions
                text: "Map provider"
                font.pixelSize: mytheme.font.sizeSettigs
            }
            ButtonRow {
                anchors.horizontalCenter: parent.horizontalCenter
                //width: parent.width
                onVisibleChanged: {
                    if (visible) {
                        switch(configuration.mapprovider) {
                        case "nokia":
                            checkedButton = btnMapsNokia;
                            break;
                        case "google":
                            checkedButton = btnMapsGoogle;
                            break;
                        case "openstreetmap":
                            checkedButton = btnMapsOsm;
                            break;
                        }
                    }
                }
                Button{
                    id: btnMapsNokia
                    text: qsTr("Nokia")
                    onClicked: settingsChanged("mapprovider","nokia")
                }

                Button{
                    id: btnMapsGoogle
                    text: qsTr("Google")
                    onClicked: settingsChanged("mapprovider","google")
                }
                Button{
                    id: btnMapsOsm
                    text: qsTr("OSM")
                    onClicked: settingsChanged("mapprovider","openstreetmap")
                }
            }
            Item{
                height: 20
                width: parent.width
            }

            //Image loading settings
            Text {
                color: mytheme.colors.textColorOptions
                text: "Load images"
                font.pixelSize: mytheme.font.sizeSettigs
            }
            ButtonRow {
                anchors.horizontalCenter: parent.horizontalCenter
                //width: parent.width
                onVisibleChanged: {
                    if (visible) {
                        switch(configuration.imageLoadType) {
                        case "cached":
                            checkedButton = btnImageCache;
                            break;
                        case "all":
                            checkedButton = btnImageAll;
                            break;
                        }
                    }
                }
                Button{
                    id: btnImageCache
                    text: qsTr("Cached")
                    onClicked: settingsChanged("imageload","cached")
                }

                Button{
                    id: btnImageAll
                    text: qsTr("All")
                    onClicked: settingsChanged("imageload","all")
                }
            }
            Item{
                height: 20
                width: parent.width
            }

            //Location data support
            SettingSwitch{
                text: qsTr("Allow use of Location Data")
                checked: configuration.gpsAllow === "1" //TODO: make some variable for it
                onCheckedChanged: {
                    var value = (checked)?"1":"0";
                    settingsChanged("gpsallow",value);
                }
            }
            Item{
                height: 20
                width: parent.width
            }

            //GPS Unlock time
            SettingSlider{
                enabled: true//!streamingSwitch.checked
                text: qsTr("GPS Unlock timeout") + ": " +
                      (enabled ? (value === 0 ? qsTr("Instant") : qsTr("%n secs(s)", "", value)) : qsTr("Disabled"))
                maximumValue: 120
                stepSize: 10
                value: configuration.gpsUplockTime
                onReleased: settingsChanged("gpsunlock",value)
            }
            Item{
                height: 20
                width: parent.width
            }

            //Feed autoupdate time
            SettingSlider{
                enabled: true//!streamingSwitch.checked
                text: qsTr("Feed autoupdate time") + ": " +
                      (enabled ? (value === 0 ? qsTr("Off") : qsTr("%n min(s)", "", value)) : qsTr("Disabled"))
                maximumValue: 60
                stepSize: 1
                value: configuration.feedAutoUpdate/60
                onReleased: settingsChanged("feedupdate",value * 60)
            }
            Item{
                height: 20
                width: parent.width
            }

            //Swypedown actions
            SettingSwitch {
                text: qsTr("Always run in background")
                checked: configuration.disableSwypedown === "1"
                onCheckedChanged: {
                    var value = (checked)?"1":"0";
                    settingsChanged("disableswypedown",value);
                }
            }

            //Notifications
            SettingSwitch{
                text: qsTr("Notification popups")
                checked: configuration.feedNotification === "1"
                onCheckedChanged: {
                    var value = (checked)?"1":"0";
                    settingsChanged("feed.notification",value);
                }
            }
            Item{
                height: 20
                width: parent.width
            }

            //Event feed integration
            SettingSwitch{
                text: qsTr("Feed at Home screen")
                checked: configuration.feedIntegration === "1"
                onCheckedChanged: {
                    var value = (checked)?"1":"0";
                    settingsChanged("feed.integration",value);
                }
            }
            Item{
                height: 20
                width: parent.width
            }

            //Push notifications support
            SettingSwitch{
                text: qsTr("Push notifications")
                //checked: configuration. === "1" //TODO: make some variable for it
                onCheckedChanged: {
                    if (checked) {
                        pushNotificationDialog.open();
                    }
                    checked = false;
                    var value = "0";
                    settingsChanged("push.enabled",value);
                }
            }
            Item{
                height: 20
                width: parent.width
            }

            //App cache
            Text {
                color: mytheme.colors.textColorOptions
                text: "App Cache"
                font.pixelSize: mytheme.font.sizeSettigs
            }
            Row {
                width: parent.width
                spacing: 20

                Button {
                    text: "Reset"
                    width: 150
                    onClicked: {
                        cache.reset();
                        cacheSize = cache.info();
                    }
                }

                TextButton {
                    height: 35
                    selected: false
                    label: "Size: " + cacheSize;
                }
            }

            Item{
                height: 20
                width: parent.width
            }

            //Molome integration
            Text {
                color: mytheme.colors.textColorOptions
                text: "MOLO.me integration"
                font.pixelSize: mytheme.font.sizeSettigs
                visible: configuration.platform === "meego"
            }
            Button {
                text: "Download MOLO.me"
                onClicked: {
                    Qt.openUrlExternally("http://molo.me/meego");
                }
                visible: !window.molome_present && configuration.platform === "meego"
            }
            Column {
                width: parent.width
                Button {
                    property bool active: false
                    text: "Enable"
                    onClicked: {
                        waiting_show();
                        active = true;
                        molome.install();
                    }
                    visible: window.molome_present && !window.molome_installed;
                    onVisibleChanged: {
                        if (active) {
                            waiting_hide();
                            active = false;
                        }
                    }
                }
                Button {
                    property bool active: false
                    text: "Disable"
                    onClicked: {
                        waiting_show();
                        active = true;
                        molome.uninstall();
                    }
                    visible: window.molome_installed;
                    onVisibleChanged: {
                        if (active) {
                            waiting_hide();
                            active = false;
                        }
                    }
                }
                visible: configuration.platform === "meego"
            }
            Item{
                height: 20
                width: parent.width
                visible: configuration.platform === "meego";
            }


            //Revoke auth token
            Text {
                color: mytheme.colors.textColorOptions
                text: "Reset authentication"
                font.pixelSize: mytheme.font.sizeSettigs
            }
            Row {
                width: parent.width

                Button {
                    text: "Revoke"
                    width: 150
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
                source: "../pics/"+mytheme.name+"/separator.png"
            }

            Item{
                height: 20
                width: parent.width
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: mytheme.textHelp1
                color: mytheme.colors.textColorOptions
                font.pixelSize: mytheme.font.sizeHelp

                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: mytheme.textHelp2
                color: mytheme.colors.textColorOptions
                font.pixelSize: mytheme.font.sizeHelp
                font.bold: true

                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: mytheme.textVersionInfo + BuildInfo.version
                color: mytheme.colors.textColorOptions
                font.pixelSize: mytheme.font.sizeHelp
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: mytheme.textBuildInfo + BuildInfo.build
                color: mytheme.colors.textColorOptions
                font.pixelSize: mytheme.font.sizeHelp
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: mytheme.textHelp3
                color: mytheme.colors.textColorOptions
                font.pixelSize: mytheme.font.sizeHelp
                font.underline: true

                horizontalAlignment: Text.AlignHCenter
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        Qt.openUrlExternally(mytheme.textHelp3);
                    }
                }
            }

            Item {
                width: parent.width
                height: 30
            }

        }
    }

    ScrollDecorator{ flickableItem: flickableArea }
}

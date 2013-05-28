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

    headerText: "SETTINGS"
    headerIcon: "../icons/icon-header-settings.png"
    headerBubble: false

    tools: ToolBarLayout{
        ToolIcon{
            platformIconId: "toolbar-back"
            onClicked: stack.pop()
        }

        ToolIcon {
            //platformIconId: "icon-m-user-guide"
            iconSource: "../icons/icon-m-toolbar-questionmark.png"
            onClicked: {
                infoDialog.open();
            }
        }

        ToolIcon {
            platformIconId: "toolbar-view-menu"
            onClicked: {
                menu.open();
            }
        }
    }

    QueryDialog  {
        id: infoDialog

        icon: "../pics/nelisquare-logo.png"//"image://theme/icon-m-user-guide"
        titleText: "Nelisquare"
        message: mytheme.textHelp1
            + "\n" + mytheme.textHelp2
            + "\n" + mytheme.textVersionInfo + BuildInfo.version
            + "\n" + mytheme.textBuildInfo + BuildInfo.build
            + "\n" + mytheme.textHelp3

        rejectButtonText: "Close"
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
        MenuLayout {
            MenuItem {
                text: qsTr("Notifications")
                onClicked: {
                    processUINotification(0);
                }
            }
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

    TabGroup {
        id: settingTabGroup
        anchors { left: parent.left; right: parent.right; top: tabButttonRow.bottom; bottom: parent.bottom }
        currentTab: generalTab

        Flickable {
            id: generalTab

            anchors.fill: parent
            contentHeight: generalTabColumn.height + 2 * mytheme.paddingMedium

            Column {
                id: generalTabColumn
                anchors { left: parent.left; right: parent.right; top: parent.top; topMargin: mytheme.paddingMedium }
                spacing: mytheme.paddingMedium

                //Check updates
                SectionHeader{
                    text: "UPDATES CHECK"
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

                SectionHeader {
                    text: "INTERVALS"
                }
                SettingSlider{
                    enabled: true//!streamingSwitch.checked
                    text: qsTr("GPS Unlock timeout") + ": " +
                          (enabled ? (value === 0 ? qsTr("Instant") : qsTr("%n secs(s)", "", value)) : qsTr("Disabled"))
                    maximumValue: 120
                    stepSize: 10
                    value: configuration.gpsUplockTime
                    onReleased: settingsChanged("gpsunlock",value)
                }
                SettingSlider{
                    enabled: true//!streamingSwitch.checked
                    text: qsTr("Feed autoupdate time") + ": " +
                          (enabled ? (value === 0 ? qsTr("Off") : qsTr("%n min(s)", "", value)) : qsTr("Disabled"))
                    maximumValue: 60
                    stepSize: 1
                    value: configuration.feedAutoUpdate/60
                    onReleased: settingsChanged("feedupdate",value * 60)
                }

                SectionHeader{
                    text: "PERMISSIONS"
                }
                SettingSwitch{
                    text: qsTr("Allow use of Location Data")
                    checked: configuration.gpsAllow === "1" //TODO: make some variable for it
                    onCheckedChanged: {
                        var value = (checked)?"1":"0";
                        settingsChanged("gpsallow",value);
                    }
                }
                SettingSwitch {
                    text: qsTr("Always run in background")
                    checked: configuration.disableSwypedown === "1"
                    onCheckedChanged: {
                        var value = (checked)?"1":"0";
                        settingsChanged("disableswypedown",value);
                    }
                }
                SettingSwitch{
                    text: qsTr("Enable notifications")
                    checked: configuration.feedNotification === "1"
                    onCheckedChanged: {
                        var value = (checked)?"1":"0";
                        settingsChanged("feed.notification",value);
                    }
                }
                SettingSwitch{
                    text: qsTr("Feed at Home screen")
                    checked: configuration.feedIntegration === "1"
                    onCheckedChanged: {
                        var value = (checked)?"1":"0";
                        settingsChanged("feed.integration",value);
                    }
                }
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

                Image {
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: "../pics/"+mytheme.name+"/separator.png"
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: mytheme.textHelp4
                    color: mytheme.colors.textColorOptions
                    font.pixelSize: mytheme.font.sizeHelp
                    font.underline: true

                    horizontalAlignment: Text.AlignHCenter
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            Qt.openUrlExternally(mytheme.textHelp4);
                        }
                    }
                }
                Item{
                    height: 20
                    width: parent.width
                }

            }
        }
        Flickable {
            id: themeTab

            anchors.fill: parent
            contentHeight: themeTabColumn.height + 2 * mytheme.paddingMedium

            Column {
                id: themeTabColumn
                anchors { left: parent.left; right: parent.right; top: parent.top; topMargin: mytheme.paddingMedium }
                spacing: mytheme.paddingMedium

                SectionHeader{
                    text: "COLOR THEME"
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

                SectionHeader{
                    text: "SCREEN ORIENTATION"
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

                SectionHeader{
                    text: "LANGUAGE"
                }
                Button{
                    text: "Default"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        show_error("No translations available!");
                    }
                }

                SectionHeader{
                    text: "MAP PROVIDER"
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
            }
        }
        Flickable {
            id: serviceTab

            anchors.fill: parent
            contentHeight: serviceTabColumn.height + 2 * mytheme.paddingMedium

            Column {
                id: serviceTabColumn
                anchors { left: parent.left; right: parent.right; top: parent.top; topMargin: mytheme.paddingMedium }
                spacing: mytheme.paddingMedium

                SectionHeader{
                    text: "IMAGE LOADING"
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
                        id: btnImageAll
                        text: qsTr("All")
                        onClicked: settingsChanged("imageload","all")
                    }
                    Button{
                        id: btnImageCache
                        text: qsTr("Cached")
                        onClicked: settingsChanged("imageload","cached")
                    }
                }

                SectionHeader{
                    text: "INTEGRATION WITH APPS"
                }
                Column {
                    width: parent.width
                    Button {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Download MOLO.ME"
                        onClicked: {
                            Qt.openUrlExternally("http://molo.me/meego");
                        }
                        visible: !configuration.molome_present
                    }

                    SettingSwitch{
                        property bool internalEnabled: configuration.molome_installed
                        property bool __active: true

                        onInternalEnabledChanged: {
                            __active = false;
                            checked = internalEnabled;
                            __active = true;
                            enabled = true;
                            waiting_hide();
                        }

                        text: qsTr("MOLO.ME Photos")
                        checked: configuration.molome_installed
                        onCheckedChanged: {
                            var value = (checked)?"1":"0";
                            if (!__active) return;
                            waiting_show();
                            enabled = false;
                            if (value === "1") {
                                molome.install();
                            } else {
                                molome.uninstall();
                            }
                        }
                        visible: configuration.molome_present
                    }

                    /*Button {
                        property bool active: false
                        text: "Enable"
                        onClicked: {
                            waiting_show();
                            active = true;
                            molome.install();
                        }
                        visible: configuration.molome_present && !configuration.molome_installed;
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
                        visible: configuration.molome_installed;
                        onVisibleChanged: {
                            if (active) {
                                waiting_hide();
                                active = false;
                            }
                        }
                    }*/
                    visible: configuration.platform === "meego"
                }

                SectionHeader{
                    text: "APPLICATION CACHE"
                }
                Row {
                    spacing: 20
                    anchors.horizontalCenter: parent.horizontalCenter

                    Button {
                        id: btnCacheClear
                        text: "Clear"
                        width: 250
                        onClicked: {
                            cache.reset();
                            cacheSize = cache.info();
                        }
                    }

                    TextButton {
                        anchors.verticalCenter: btnCacheClear.verticalCenter
                        height: 35
                        selected: false
                        label: "Size: " + cacheSize;
                    }

                }
                SectionHeader {
                    text: "AUTHENTICATION"
                }
                Button {
                    text: "Reset authentication"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        authDeleted()
                    }
                }

            }
        }
        Flickable {
            id: debugTab

            anchors.fill: parent
            contentHeight: debugTabColumn.height + 2 * mytheme.paddingMedium

            Column {
                id: debugTabColumn
                anchors { left: parent.left; right: parent.right; top: parent.top; topMargin: mytheme.paddingMedium }
                spacing: mytheme.paddingMedium

                SectionHeader {
                    text: "ACCESS RATE LIMIT"
                }
                Text{
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: mytheme.fontSizeLarge
                    color: mytheme.colors.textColorOptions
                    text: "API requests available: %1 / %2".arg(configuration.ratelimit.remaining).arg(configuration.ratelimit.limit)
                }
                Text{
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: mytheme.fontSizeLarge
                    color: mytheme.colors.textColorOptions
                    text: "You are low on X-RATE"
                    visible: configuration.ratelimit.remaining < 10
                }

                SectionHeader{
                    text: "DEBUG"
                }
                Text{
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: mytheme.fontSizeLarge
                    color: mytheme.colors.textColorOptions
                    text: "Options will be available soon"
                }
            }
        }
    }

    //ScrollDecorator{ flickableItem: settingTabGroup }


    ButtonRow {
        id: tabButttonRow
        anchors { top: pagetop; left: parent.left; right: parent.right }

        TabButton { tab: generalTab; text: qsTr("General")}
        TabButton { tab: themeTab; text: qsTr("Theme") }
        TabButton { tab: serviceTab; text: qsTr("Service") }
        TabButton { tab: debugTab; text: qsTr("Debug") }
    }

    /*Flickable{
        id: flickableArea
        anchors.top: pagetop
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



            //App cache
            Text {
                color: mytheme.colors.textColorOptions
                text: "App Cache"
                font.pixelSize: mytheme.font.sizeSettigs
            }


            Item{
                height: 20
                width: parent.width
            }

            //Molome integration

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


            Item{
                height: 20
                width: parent.width
            }



            Item{
                height: 20
                width: parent.width
            }

        }
    }


    */
}

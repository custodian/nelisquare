import Qt 4.7
import com.nokia.meego 1.0
import "../build.info.js" as BuildInfo
import "../components"

//TODO: dont forget about PAGESTACK:

PageWrapper {
    signal authDeleted()

    signal settingsChanged(string type, string value);

    property string cacheSize: qsTr("updating...")

    id: settings
    color: mytheme.colors.backgroundMain

    width: parent.width
    height: parent.height

    headerText: qsTr("SETTINGS")
    headerIcon: "../icons/icon-header-settings.png"
    headerBubble: false

    tools: ToolBarLayout{
        ToolIcon{
            platformIconId: "toolbar-back"
            onClicked: {
                stack.pop()
            }
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
        message: ("%1\n%2\n%3\n%4\n\n%5\n\n%6: %7\n%8: %9\n\n%10")
        .arg(qsTr("2012-2013 Basil Semuonov"))
        .arg(qsTr("Idea by Tommi Laukkanen"))
        .arg(qsTr("Shout out to @knobtviker"))
        .arg(qsTr("Design by Kim Venetvirta"))
        .arg(qsTr("If any problems, tweet @basil_s"))
        .arg(qsTr("Version"))
        .arg(BuildInfo.version)
        .arg(qsTr("Build"))
        .arg(BuildInfo.build)
        .arg(qsTr("Powered by Foursquare"))

        rejectButtonText: qsTr("Close")
    }

    QueryDialog  {
        id: eraseSettingsDialog
        icon: "image://theme/icon-l-accounts"
        titleText: qsTr("Reset settings")
        message: qsTr("This action will erase all data including auth token, application settings and cache.")
        acceptButtonText: qsTr("Yes, clear the data")
        rejectButtonText: qsTr("No, thanks")
        onAccepted: {
            configuration.resetSettings();
        }
    }

    SelectionDialog {
        id: translationSelector
        titleText: qsTr("Language")
        onAccepted: {
            settingsChanged("language",languageNamesModel.get(selectedIndex).code);
        }
    }

    ListModel {
        id: languageNamesModel

        Component.onCompleted: {
            var langs = translator.getAvailableLanguages()
            for(var lang in langs) {
                languageNamesModel.append({"name":langs[lang],"code":lang});
            }
            translationSelector.model = languageNamesModel;
            /*for (var i=0; i<internal.languagesCodesArray.length; i++) {
                if (internal.languagesCodesArray[i] === settings.translateLangCode) {
                    selectedIndex = i
                    break
                }
            }*/
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
                    text: qsTr("UPDATES CHECK")
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
                            case "beta":
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
                        onClicked: settingsChanged("checkupdates","beta")
                    }

                    Button{
                        id: btnUpdateAlpha
                        text: qsTr("Alpha")
                        onClicked: settingsChanged("checkupdates","alpha")
                    }
                }

                SectionHeader {
                    text: qsTr("INTERVALS")
                }
                SettingSlider{
                    enabled: true//!streamingSwitch.checked
                    text: qsTr("GPS Unlock timeout") + ": " +
                          (enabled ? (value === 0 ? qsTr("Instant") : qsTr("%1 secs(s)").arg(value)) : qsTr("Disabled"))
                    maximumValue: 120
                    stepSize: 10
                    value: configuration.gpsUplockTime
                    onReleased: settingsChanged("gpsunlock",value)
                }
                SettingSlider{
                    enabled: true//!streamingSwitch.checked
                    text: qsTr("Feed autoupdate time") + ": " +
                          (enabled ? (value === 0 ? qsTr("Off") : qsTr("%1 min(s)").arg(value)) : qsTr("Disabled"))
                    maximumValue: 60
                    stepSize: 1
                    value: configuration.feedAutoUpdate/60
                    onReleased: settingsChanged("feedupdate",value * 60)
                }

                SectionHeader{
                    text: qsTr("PERMISSIONS")
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
                    text: "http://custodian.github.com/nelisquare"
                    color: mytheme.colors.textColorOptions
                    font.pixelSize: mytheme.font.sizeHelp
                    font.underline: true

                    horizontalAlignment: Text.AlignHCenter
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            Qt.openUrlExternally("http://custodian.github.com/nelisquare");
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
                    text: qsTr("COLOR THEME")
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
                        onClicked: {
                            settingsChanged("theme","light");
                            appWindow.reloadUI();
                        }
                    }

                    Button{
                        id: btnThemeDark
                        text: qsTr("Dark")
                        onClicked: {
                            settingsChanged("theme","dark");
                            appWindow.reloadUI();
                        }
                    }
                }

                SectionHeader{
                    text: qsTr("SCREEN ORIENTATION")
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
                    text: qsTr("STARTUP PAGE")
                }
                ButtonRow {
                    anchors.horizontalCenter: parent.horizontalCenter
                    //width: parent.width
                    onVisibleChanged: {
                        if (visible) {
                            switch(configuration.startPage) {
                            case "feed":
                                checkedButton = btnPageFeed;
                                break;
                            case "venues":
                                checkedButton = btnPageVenues;
                                break;
                            case "self":
                                checkedButton = btnPageMe;
                                break;
                            }
                        }
                    }
                    Button{
                        id: btnPageFeed
                        text: qsTr("Feed")
                        onClicked: settingsChanged("startpage","feed")
                    }

                    Button{
                        id: btnPageVenues
                        text: qsTr("Venues")
                        onClicked: settingsChanged("startpage","venues")
                    }
                    Button{
                        id: btnPageMe
                        text: qsTr("Self")
                        onClicked: settingsChanged("startpage","self")
                    }
                }

                SectionHeader{
                    text: qsTr("LANGUAGE")
                }
                Button{
                    text: translator.getLanguageName(configuration.interfaceLanguage) //"Default"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        translationSelector.open();
                    }
                }

                SectionHeader{
                    text: qsTr("MAP PROVIDER")
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
                    text: qsTr("IMAGE LOADING")
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
                    text: qsTr("INTEGRATION WITH APPS")
                }
                Column {
                    width: parent.width
                    Button {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: qsTr("Download MOLO.ME")
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

                    visible: configuration.platform === "meego"
                }

                SectionHeader{
                    text: qsTr("APPLICATION CACHE")
                }
                Row {
                    spacing: 20
                    anchors.horizontalCenter: parent.horizontalCenter

                    Button {
                        id: btnCacheClear
                        text: qsTr("Clear")
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
                        label: qsTr("Size: %1").arg(cacheSize);
                    }

                }

                SectionHeader{
                    text: qsTr("UI")
                }
                Button{
                    text: qsTr("Reload UI")
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: appWindow.reloadUI()
                }

                SectionHeader {
                    text: qsTr("AUTHENTICATION")
                }
                Button {
                    text: qsTr("Reset authentication")
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
                    text: qsTr("ACCESS RATE LIMIT")
                }
                Text{
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: mytheme.fontSizeLarge
                    color: mytheme.colors.textColorOptions
                    text: qsTr("API requests available: %1 / %2").arg(configuration.ratelimit.remaining).arg(configuration.ratelimit.limit)
                }
                Text{
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: mytheme.fontSizeLarge
                    color: mytheme.colors.textColorOptions
                    text: qsTr("You are low on X-RATE requests")
                    visible: configuration.ratelimit.remaining < 10
                }

                SectionHeader{
                    text: qsTr("DEBUG")
                }
                SettingSwitch{
                    text: qsTr("Enable debug")
                    checked: configuration.debugEnabled === "1"
                    onCheckedChanged: {
                        var value = (checked)?"1":"0";
                        settingsChanged("debug.enabled",value);
                    }
                }

                Column {
                    width: parent.width
                    Text{
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: mytheme.fontSizeLarge
                        color: mytheme.colors.textColorOptions
                        text: qsTr("Options will be available soon")
                    }
                    visible: configuration.debugEnabled === "1"
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

}

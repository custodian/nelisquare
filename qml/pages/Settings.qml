import Qt 4.7
import com.nokia.meego 1.0
import "../build.info.js" as BuildInfo
import "../components"
import "../js/api.js" as API

import net.thecust.utils 1.0

//TODO: dont forget about PAGESTACK:

PageWrapper {
    signal authDeleted()

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

    DebugLogger {
        id: debuglogger
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
        onAccepted: appConfig.interfaceLanguage = languageNamesModel.get(selectedIndex).code;
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
            appConfig.foursquareAccessToken = "";
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
                            switch(appConfig.updatesCheck) {
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
                        onClicked: appConfig.updatesCheck = "none"
                    }

                    Button{
                        id: btnUpdateStable
                        text: qsTr("Stable")
                        onClicked: appConfig.updatesCheck = "stable"
                    }
                    Button{
                        id: btnUpdateBeta
                        text: qsTr("Beta")
                        onClicked: appConfig.updatesCheck = "beta"
                    }

                    Button{
                        id: btnUpdateAlpha
                        text: qsTr("Alpha")
                        onClicked: appConfig.updatesCheck = "alpha"
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
                    value: appConfig.gpsUnlockTime
                    onReleased: appConfig.gpsUnlockTime = value
                }
                SettingSlider{
                    enabled: true//!streamingSwitch.checked
                    text: qsTr("Feed autoupdate time") + ": " +
                          (enabled ? (value === 0 ? qsTr("Off") : qsTr("%1 min(s)").arg(value)) : qsTr("Disabled"))
                    maximumValue: 60
                    stepSize: 1
                    value: appConfig.feedUpdateInterval/60
                    onReleased: appConfig.feedUpdateInterval = value * 60
                }

                SectionHeader{
                    text: qsTr("PERMISSIONS")
                }
                SettingSwitch{
                    text: qsTr("Allow use of Location Data")
                    checked: appConfig.gpsAllow === "1" //TODO: make some variable for it
                    onCheckedChanged: appConfig.gpsAllow = (checked)?"1":"0";
                }
                SettingSwitch {
                    text: qsTr("Always run in background")
                    checked: appConfig.interfaceDisableSwypeDown === "1"
                    onCheckedChanged: appConfig.interfaceDisableSwypeDown = (checked)?"1":"0";
                }
                SettingSwitch{
                    text: qsTr("Enable notifications")
                    checked: appConfig.integrationNotification === "1"
                    onCheckedChanged: appConfig.integrationNotification = (checked)?"1":"0";
                }
                SettingSwitch{
                    text: qsTr("Feed at Home screen")
                    checked: appConfig.integrationHomeFeed === "1"
                    onCheckedChanged: appConfig.integrationHomeFeed = (checked)?"1":"0";
                }
                SettingSwitch{
                    text: qsTr("Push notifications")
                    //checked: appConfig.pushEnable === "1" //TODO: make some variable for it
                    onCheckedChanged: {
                        if (checked) {
                            pushNotificationDialog.open();
                            checked = false;
                        }                        
                        appConfig.pushEnable = "0"
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
                            appConfig.interfaceTheme = "light";
                            appWindow.reloadUI();
                        }
                    }

                    Button{
                        id: btnThemeDark
                        text: qsTr("Dark")
                        onClicked: {
                            appConfig.interfaceTheme = "dark";
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
                            switch(appConfig.interfaceOrientation) {
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
                        onClicked: appConfig.interfaceOrientation = "auto"
                    }

                    Button{
                        id: btnOrientationLandscape
                        text: qsTr("Landscape")
                        onClicked: appConfig.interfaceOrientation = "landscape"
                    }
                    Button{
                        id: btnOrientationPortrait
                        text: qsTr("Portrait")
                        onClicked: appConfig.interfaceOrientation = "portrait"
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
                            switch(appConfig.interfaceStartPage) {
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
                        onClicked: appConfig.interfaceStartPage = "feed"
                    }

                    Button{
                        id: btnPageVenues
                        text: qsTr("Venues")
                        onClicked: appConfig.interfaceStartPage = "venues"
                    }
                    Button{
                        id: btnPageMe
                        text: qsTr("Self")
                        onClicked: appConfig.interfaceStartPage = "self"
                    }
                }

                SectionHeader{
                    text: qsTr("LANGUAGE")
                }
                Button{
                    text: translator.getLanguageName(appConfig.interfaceLanguage) //"Default"
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
                            switch(appConfig.mapProvider) {
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
                        onClicked: appConfig.mapProvider = "nokia"
                    }

                    Button{
                        id: btnMapsGoogle
                        text: qsTr("Google")
                        onClicked: appConfig.mapProvider = "google"
                    }
                    Button{
                        id: btnMapsOsm
                        text: qsTr("OSM")
                        onClicked: appConfig.mapProvider = "openstreetmap"
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
                            switch(appConfig.interfaceImageLoad) {
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
                        onClicked: appConfig.interfaceImageLoad = "all"
                    }
                    Button{
                        id: btnImageCache
                        text: qsTr("Cached")
                        onClicked: appConfig.interfaceImageLoad = "cached"
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
                        visible: !molome.molome_present
                    }

                    SettingSwitch{
                        property bool internalEnabled: molome.molome_installed
                        property bool __active: true

                        onInternalEnabledChanged: {
                            __active = false;
                            checked = internalEnabled;
                            __active = true;
                            enabled = true;
                            waiting_hide();
                        }

                        text: qsTr("MOLO.ME Photos")
                        checked: molome.molome_installed
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
                        visible: molome.molome_present
                    }

                    visible: appConfig.platform === "meego"
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
                    text: qsTr("API requests available: %1 / %2").arg(API.api.ratelimit.remaining).arg(API.api.ratelimit.limit)
                }
                Text{
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: mytheme.fontSizeLarge
                    color: mytheme.colors.textColorOptions
                    text: qsTr("You are low on X-RATE requests")
                    visible: API.api.ratelimit.remaining < 10
                }

                SectionHeader{
                    text: qsTr("DEBUG")
                }
                SettingSwitch{
                    text: qsTr("Enable debug")
                    checked: appConfig.debugEnabled === "1"
                    onCheckedChanged: appConfig.debugEnabled = (checked)?"1":"0";
                }
                SectionHeader {
                    text: qsTr("DATA SUBMISSION")
                }
                Button {
                    text: qsTr("Send debug log")
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        stack.push(Qt.resolvedUrl("../pages/DebugSubmit.qml"), {"content": { "DebugLogger": debuglogger.getData()}});
                    }
                }

                Column {
                    width: parent.width
                    SectionHeader {
                        text: qsTr("DEBUG INFO RECORD")
                    }
                    Text{
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: mytheme.fontSizeLarge
                        color: mytheme.colors.textColorOptions
                        text: qsTr("More options will be available soon")
                    }
                    SettingSwitch {
                        text: qsTr("Feed API data");
                        checked: appConfig.debugFeed === "1"
                        onCheckedChanged: appConfig.debugFeed = (checked)?"1":"0";
                    }
                    SettingSwitch {
                        text: qsTr("Checkins API data");
                        checked: appConfig.debugCheckins === "1"
                        onCheckedChanged: appConfig.debugCheckins = (checked)?"1":"0";
                    }
                    SettingSwitch {
                        text: qsTr("Notifications API data");
                        checked: appConfig.debugNotis === "1"
                        onCheckedChanged: appConfig.debugNotis = (checked)?"1":"0";
                    }
                    SettingSwitch {
                        text: qsTr("Photos API data");
                        checked: appConfig.debugPhotos === "1"
                        onCheckedChanged: appConfig.debugPhotos = (checked)?"1":"0";
                    }
                    SettingSwitch {
                        text: qsTr("Tips API data");
                        checked: appConfig.debugTips === "1"
                        onCheckedChanged: appConfig.debugTips = (checked)?"1":"0";
                    }
                    SettingSwitch {
                        text: qsTr("Users API data");
                        checked: appConfig.debugUsers === "1"
                        onCheckedChanged: appConfig.debugUsers = (checked)?"1":"0";
                    }
                    SettingSwitch {
                        text: qsTr("Venues API data");
                        checked: appConfig.debugVenues === "1"
                        onCheckedChanged: appConfig.debugVenues = (checked)?"1":"0";
                    }
                    visible: appConfig.debugEnabled === "1"
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

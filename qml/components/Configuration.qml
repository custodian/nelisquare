import QtQuick 1.1
import QtMobility.systeminfo 1.2

import "../build.info.js" as BuildInfo
import "../js/update.js" as Updater
import "../js/storage.js" as Storage
import "../js/api.js" as Api

Item {
    id: configuration

    property string platform: windowHelper.isMaemo() ? "maemo" : "meego"
    property bool isPortrait: screen.orientationString === "Portrait"

    property string orientationType: "auto"
    property string mapprovider: "google"
    property string checkupdates: "none"
    property string startPage: ""

    property string imageLoadType: "all"
    property int gpsUplockTime: 0 //in seconds
    property string gpsAllow: ""
    property int feedAutoUpdate: 0 //in seconds

    property string disableSwypedown: "1" //1 == hide on swype down instead of exit

    property string feedIntegration: "0" //1 == integrate
    property string feedNotification: "0" //1 == notify

    property string interfaceLanguage: translator.getDefaultLanguage()
    property string accessToken: "empty"

    property variant ratelimit: {}

    property string debugEnabled: "0"
    property string debugTips: "0"
    property string debugUsers: "0"
    property string debugVenues: "0"
    property string debugPhotos: "0"
    property string debugCheckins: "0"
    property string debugFeed: "0"
    property string debugNotis: "0"

    property string sharePhotoPublic: "0"
    property string sharePhotoFacebook: "0"
    property string sharePhotoTwitter: "0"

    property string shareCheckinFriends: "1"
    property string shareCheckinFacebook: "0"
    property string shareCheckinTwitter: "0"

    property bool molome_present: false
    property bool molome_installed: false

    onCheckupdatesChanged: {
        if (checkupdates!="none") {
            updateTimer.restart();
            getupdates();
        } else {
            updateTimer.stop();
        }
    }

    Component.onCompleted: {
        Api.setPositionSource(positionSource);
        loadSettings();
    }

    function getupdates() {
        Updater.getUpdateInfo(configuration.platform,checkupdates,onUpdateAvailable);
    }

    /*AlignedTimer {
        id: updateTimer
        singleShot:false
        maximumInterval: 15//180//4*3600
        minimumInterval: 10//60//1*3600
        onTimeout: {
            getupdates();
        }
    }*/
    Timer {
        id: updateTimer
        repeat: true
        interval: 600 * 1000
        onTriggered: {
            getupdates();
        }
    }

    function setAccessToken(token) {
        settingChanged("accesstoken",token)
    }

    function settingLoaded(key, value) {
        if(key==="accesstoken") {
            Api.setAccessToken(value);
            accessToken = value;
        } else if (key === "settings.orientation") {
            if (value === "") value = "auto";
            configuration.orientationType = value;
            appWindow.lockWindowOrientation(value);
        } else if (key === "settings.mapprovider") {
            if (value === "") value = "google";
            configuration.mapprovider = value;
        } else if (key === "settings.checkupdates") {
            if (value === "") value = "stable";
            //DBG for 2-3 beta builds
            if (value === "developer") {
                value = "beta";
                settingChanged(key,value);
            }
            configuration.checkupdates = value;
        } else if (key === "settings.molome") {
            //TODO: make install/uninstall (first see) notification enable
            //console.log("molome settings loaded");
            molome.updateinfo();
        } else if (key === "settings.imageload") {
            if (value === "") value = "all";
            configuration.imageLoadType = value;
            cache.loadtype(value);
        } else if (key === "settings.gpsunlock") {
            if (value === "") value = 0;
            configuration.gpsUplockTime = value;
        } else if (key === "settings.gpsallow") {
            if (value === "") {
                //locationAllowDialog.state = "shown";
                locationAllowDialog.open();
            } else {
                configuration.gpsAllow = value;
                appWindow.windowActiveChanged();
            }
        } else if (key === "settings.feedupdate") {
            if (value === "") value = 0;
            if (value === 60) value = 120;
            configuration.feedAutoUpdate = value;
        } else if (key === "settings.theme") {
            if (value === "") value = "light";
            mytheme.loadTheme(value);
        } else if (key === "settings.push.enabled") {
            if (value === "") {
                pushNotificationDialog.open();
            }
        } else if (key === "settings.feed.integration") {
            if (value === "") value = "0";
            configuration.feedIntegration = value;
        } else if (key === "settings.feed.notification") {
            if (value === "") value = "1";
            configuration.feedNotification = value;
        } else if (key === "settings.disableswypedown") {
            if (value === "") value = "1";
            configuration.disableSwypedown = value;
            windowHelper.disableSwype(value === "1");
        } else if (key === "settings.language") {
            if (value !== "") {
                configuration.interfaceLanguage = value;
            }
            Api.setLocale(interfaceLanguage.substring(0,2));
            translator.changeLanguage(interfaceLanguage);
        } else if (key === "settings.startpage") {
            configuration.startPage = value;
        } else if (key === "settings.debug.enabled") {
            if (value === "") value = "0";
            configuration.debugEnabled = value;
            Api.api.debugenabled = (value === "1") ? 2 : 1;
        } else if (key === "settings.debug.feed") {
            if (value === "") value = "0";
            configuration.debugFeed = value;
            Api.feed.debuglevel = (value === "1") ? 2 : 1;
        } else if (key === "settings.debug.checkins") {
            if (value === "") value = "0";
            configuration.debugCheckins = value;
            Api.checkin.debuglevel = (value === "1") ? 2 : 1;
        } else if (key === "settings.debug.notis") {
            if (value === "") value = "0";
            configuration.debugNotis = value;
            Api.notifications.debuglevel = (value === "1") ? 2 : 1;
        } else if (key === "settings.debug.photos") {
            if (value === "") value = "0";
            configuration.debugPhotos = value;
            Api.photos.debuglevel = (value === "1") ? 2 : 1;
        } else if (key === "settings.debug.tips") {
            if (value === "") value = "0";
            configuration.debugTips = value;
            Api.tips.debuglevel = (value === "1") ? 2 : 1;
        } else if (key === "settings.debug.users") {
            if (value === "") value = "0";
            configuration.debugUsers = value;
            Api.users.debuglevel = (value === "1") ? 2 : 1;
        } else if (key === "settings.debug.venues") {
            if (value === "") value = "0";
            configuration.debugVenues = value;
            Api.venues.debuglevel = (value === "1") ? 2 : 1;
        } else {
            console.log("Unknown setting: " + key + "=" + value);
        }
    }

    function settingChanged(key, value) {
        Storage.setKeyValue(key, value);
        configuration.settingLoaded(key, value);
    }

    function loadSettings() {
        Storage.getKeyValue("settings.language", settingLoaded);
        Storage.getKeyValue("settings.startpage", settingLoaded);

        Storage.getKeyValue("settings.orientation", settingLoaded);
        Storage.getKeyValue("settings.mapprovider", settingLoaded);
        Storage.getKeyValue("settings.checkupdates", settingLoaded);

        Storage.getKeyValue("settings.imageload", settingLoaded);
        Storage.getKeyValue("settings.gpsunlock", settingLoaded);
        Storage.getKeyValue("settings.feedupdate", settingLoaded);

        Storage.getKeyValue("settings.disableswypedown", settingLoaded);
        Storage.getKeyValue("settings.feed.integration", settingLoaded);
        Storage.getKeyValue("settings.feed.notification", settingLoaded);
        Storage.getKeyValue("settings.theme", settingLoaded);

        Storage.getKeyValue("settings.molome", settingLoaded);

        Storage.getKeyValue("settings.debug.enabled", settingLoaded);
        Storage.getKeyValue("settings.debug.feed", settingLoaded);
        Storage.getKeyValue("settings.debug.checkins", settingLoaded);
        Storage.getKeyValue("settings.debug.notis", settingLoaded);
        Storage.getKeyValue("settings.debug.photos", settingLoaded);
        Storage.getKeyValue("settings.debug.tips", settingLoaded);
        Storage.getKeyValue("settings.debug.users", settingLoaded);
        Storage.getKeyValue("settings.debug.venues", settingLoaded);

        //Ask dialogs on first start
        Storage.getKeyValue("settings.push.enabled",settingLoaded);
        Storage.getKeyValue("settings.gpsallow", settingLoaded);

        Storage.getKeyValue("accesstoken", settingLoaded);
    }

    function resetSettings() {
        cache.reset();
        Storage.clear();
        loadSettings();
    }

    function onUpdateAvailable(build, version, changelog, url) {
        var update = false;
        if (checkupdates == "beta") {
            if (build > BuildInfo.build) {
                update = true;
            }
        } else if (checkupdates == "alpha") {
            if (build > BuildInfo.build) {
                update = true;
            }
        } else if (checkupdates == "stable") {
            if (version !== BuildInfo.version || build !== BuildInfo.build) {
                update = true;
            }
        }

        if (update){
            console.log("UPDATE IS AVAILABLE: " + build);
            updateDialog.build = build;
            updateDialog.version = version;
            updateDialog.url = url;
            updateDialog.changelog = changelog;
            if (accessToken.length > 0) {
                updateDialog.open();
            }
        }
    }
}

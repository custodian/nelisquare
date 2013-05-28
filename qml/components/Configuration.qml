import QtQuick 1.1
import QtMobility.systeminfo 1.2

import "../build.info.js" as BuildInfo
import "../js/update.js" as Updater
import "../js/storage.js" as Storage
import "../js/api.js" as Api

Item   {
    id: configuration

    property string platform: windowHelper.isMaemo() ? "maemo" : "meego"

    property string orientationType: "auto"
    property string mapprovider: "google"
    property string checkupdates: "none"

    property string imageLoadType: "all"
    property int gpsUplockTime: 0 //in seconds
    property string gpsAllow: ""
    property int feedAutoUpdate: 0 //in seconds

    property string disableSwypedown: "1" //1 == hide on swype down instead of exit

    property string feedIntegration: "0" //1 == integrate
    property string feedNotification: "0" //1 == notify

    property int commentUpdateRate: 300 //currently hardcoded to be 5 mins

    property string accessToken: "empty"

    property variant ratelimit: {}

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
            appWindow.onLockOrientation(value);
        } else if (key === "settings.mapprovider") {
            if (value === "") value = "google";
            configuration.mapprovider = value;
        } else if (key === "settings.checkupdates") {
            if (value === "") value = "stable";
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
        } else {
            console.log("Unknown setting: " + key + "=" + value);
        }
    }

    function settingChanged(key, value) {
        Storage.setKeyValue(key, value);
        configuration.settingLoaded(key, value);
    }

    function loadSettings() {
        Storage.getKeyValue("accesstoken", settingLoaded);

        Storage.getKeyValue("settings.orientation", settingLoaded);
        Storage.getKeyValue("settings.mapprovider", settingLoaded);
        Storage.getKeyValue("settings.checkupdates", settingLoaded);

        Storage.getKeyValue("settings.imageload", settingLoaded);
        Storage.getKeyValue("settings.gpsunlock", settingLoaded);
        Storage.getKeyValue("settings.gpsallow", settingLoaded);
        Storage.getKeyValue("settings.feedupdate", settingLoaded);

        Storage.getKeyValue("settings.disableswypedown", settingLoaded);
        Storage.getKeyValue("settings.feed.integration", settingLoaded);
        Storage.getKeyValue("settings.feed.notification", settingLoaded);
        Storage.getKeyValue("settings.theme", settingLoaded);

        Storage.getKeyValue("settings.push.enabled",settingLoaded);

        Storage.getKeyValue("settings.molome", settingLoaded);
    }

    function resetSettings() {
        cache.reset();
        Storage.clear();
        loadSettings();
    }

    function onUpdateAvailable(build, version, changelog, url) {
        var update = false;
        if (checkupdates == "developer") {
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
            updateDialog.open();
        }
    }
}

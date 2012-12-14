import QtQuick 1.1

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

    property string feedIntegration: "0" //1 == integrate
    property string feedNotification: "0" //1 == notify

    property int commentUpdateRate: 300 //currently hardcoded to be 5 mins

    property string accessToken: "empty"

    onCheckupdatesChanged: {
        if (checkupdates!="none") {
            Updater.getUpdateInfo(checkupdates,onUpdateAvailable);
        }
    }

    Component.onCompleted: {
        loadSettings();
    }

    function settingLoaded(key, value) {
        if(key==="accesstoken") {
            console.log("token loaded: " + value);
            Api.setAccessToken(value);
        } else if (key === "settings.orientation") {
            if (value === "") value = "auto";
            configuration.orientationType = value;
            mainWindowStack.onLockOrientation(value);
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
                window.windowActiveChanged();
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
            /*
            //TODO: Create update "Sheet" component
            */
            updateDialog.build = build;
            updateDialog.version = version;
            updateDialog.url = url;
            updateDialog.changelog = changelog;
            updateDialog.state = "shown";
        }
    }
}

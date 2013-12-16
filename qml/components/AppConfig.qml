import QtQuick 1.1
import "../js/database.js" as Database

QtObject {
    id: config

    signal settingsLoaded
    signal settingsReseted

    Component.onCompleted: {
        loadSettings();
    }

    function loadSettings() {
        var results = Database.getAllSettings()
        for (var s in results) {
            settingChanged(s, results[s]);
        }
        settingsLoaded()
    }

    function resetSettings() {
        Database.resetSettings();
        interfaceTheme = "light"
        interfaceLanguage = ""
        interfaceOrientation = "auto"
        interfaceDisableSwypeDown = "1"
        interfaceImageLoad = "all"
        interfaceStartPage = ""
        gpsAllow = ""
        gpsUnlockTime = 0
        mapProvider = "google"
        updatesCheck = "none"
        feedUpdateInterval = 0
        integrationHomeFeed = "0"
        integrationNotification = "0"
        pushEnable = "0"
        sharePhotoPublic = "0"
        sharePhotoFacebook = "0"
        sharePhotoTwitter = "0"
        shareCheckinFriends = "1"
        shareCheckinFacebook = "0"
        shareCheckinTwitter = "0"
        debugEnabled = "0"
        debugTips = "0"
        debugUsers = "0"
        debugVenues = "0"
        debugPhotos = "0"
        debugCheckins = "0"
        debugFeed = "0"
        debugNotis = "0"
        foursquareAccessToken = ""
        settingsReset()
    }

    function settingChanged(name, value) {
        if (config.hasOwnProperty(name)) {
            console.log("Loaded setting: %1 = %2".arg(name).arg(value))
            config[name] = value;
        }
    }

    function save(name) {
        if (config.hasOwnProperty(name)) {
            var data = JSON.parse("{ \"%1\" : \"%2\" }".arg(name).arg(config[name]));
            console.log("Saved setting: " + JSON.stringify(data));
            Database.setSetting(data);
        }
    }

    //TODO: change to getPlatform (or something)
    property string platform: windowHelper.isMaemo() ? "maemo" : "meego"

    property string foursquareAccessToken: ""
    onFoursquareAccessTokenChanged: save("foursquareAccessToken")

    property string interfaceTheme: "light"
    onInterfaceThemeChanged: save("interfaceTheme")

    property string interfaceLanguage: ""
    onInterfaceLanguageChanged: save("interfaceLanguage")

    property string interfaceOrientation: "auto"
    onInterfaceOrientationChanged: save("interfaceOrientation")

    property string interfaceDisableSwypeDown: "1" //1 == hide on swype down instead of exit
    onInterfaceDisableSwypeDownChanged: save("interfaceDisableSwypeDown")

    property string interfaceImageLoad: "all"
    onInterfaceImageLoadChanged: save("interfaceImageLoad")

    property string interfaceStartPage: ""
    onInterfaceStartPageChanged: save("interfaceStartPage")

    property string gpsAllow: "" //Empty until first application start
    onGpsAllowChanged: save("gpsAllow")

    property int gpsUnlockTime: 0 //In Seconds
    onGpsUnlockTimeChanged: save("gpsUnlockTime")

    property string mapProvider: "google"
    onMapProviderChanged: save("mapProvider")

    property string updatesCheck: "none"
    onUpdatesCheckChanged: save("updatesCheck")

    property int feedUpdateInterval: 0 //In Seconds
    onFeedUpdateIntervalChanged: save("feedUpdateInterval")

    property string integrationHomeFeed: "0" //1 == integrate
    onIntegrationHomeFeedChanged: save("integrationHomeFeed")

    property string integrationNotification: "0" //1 == integrate
    onIntegrationNotificationChanged: save("integrationNotification")

    property string pushEnable: "0" //disabled since unavailable
    onPushEnableChanged: save("pushEnable")


    property string sharePhotoPublic: "0"
    onSharePhotoPublicChanged: save("sharePhotoPublic")

    property string sharePhotoFacebook: "0"
    onSharePhotoFacebookChanged: save("sharePhotoFacebook")

    property string sharePhotoTwitter: "0"
    onSharePhotoTwitterChanged: save("sharePhotoTwitter")

    property string shareCheckinFriends: "1"
    onShareCheckinFriendsChanged: save("shareCheckinFriends")

    property string shareCheckinFacebook: "0"
    onShareCheckinFacebookChanged: save("shareCheckinFacebook")

    property string shareCheckinTwitter: "0"
    onShareCheckinTwitterChanged: save("shareCheckinTwitter")


    property string debugEnabled: "0"
    onDebugEnabledChanged: save("debugEnabled")

    property string debugTips: "0"
    onDebugTipsChanged: save("debugTips")

    property string debugUsers: "0"
    onDebugUsersChanged: save("debugUsers")

    property string debugVenues: "0"
    onDebugVenuesChanged: save("debugVenues")

    property string debugPhotos: "0"
    onDebugPhotosChanged: save("debugPhotos")

    property string debugCheckins: "0"
    onDebugCheckinsChanged: save("debugCheckins")

    property string debugFeed: "0"
    onDebugFeedChanged: save("debugFeed")

    property string debugNotis: "0"
    onDebugNotisChanged: save("debugNotis")
}

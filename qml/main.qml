import Qt 4.7
import QtQuick 1.1
import com.nokia.meego 1.0
import QtMobility.location 1.2

import "components"
import "js/api.js" as Api //DBG: possibly have to rebuild that stuff

PageStackWindow {
    id: appWindow
    property bool windowActive: Qt.application.active
    property string lastNotiCount: "0"
    property int notificationsCount: 0

    property alias stack: tabgroup.currentTab;

    showToolBar: tabgroup.currentTab !== tabLogin
    showStatusBar: inPortrait

    onWindowActiveChanged: {
        console.log("active: " + windowActive);

        if (configuration.gpsAllow !== "1") {
            positionSource.active = false;
            return;
        }
        if (!windowActive) {
            if (positionSource.position.latitudeValid) {
                timerGPSUnlock.start();
            } else {
                positionSource.active = windowActive;
            }
        } else {
            timerGPSUnlock.stop();
            positionSource.active = windowActive;
        }
    }

    initialPage: mainPage

    Page {
        id: mainPage
        //tools: commonTools
        tools: stack.currentPage !== undefined ? stack.currentPage.tools : null
        onToolsChanged: {
            if (pageStack) {
                pageStack.toolBar.tools = tools;
            }
        }

        TabGroup {
            id: tabgroup
            currentTab: tabLogin
            anchors.fill: parent
            /*anchors {
                top: pageHeader.bottom;
                left: parent.left;
                right: parent.right;
                bottom: parent.bottom;
            }*/
            property variant lastTab

            onCurrentTabChanged: {
                if (currentTab.depth === 0) {
                    currentTab.load();
                }
            }

            PageStack {
                id: tabFeed
                function load() {
                    tabFeed.push(Qt.resolvedUrl("pages/FriendsFeed.qml"))
                }
            }

            PageStack {
                id: tabVenues
                function load() {
                    tabVenues.push(Qt.resolvedUrl("pages/VenuesList.qml"))
                }
            }

            PageStack {
                id: tabMe
                function load() {
                    tabMe.push(Qt.resolvedUrl("pages/User.qml"),{"userID":"self"})
                }
            }

            PageStack {
                id: tabLogin
                function load() {
                    tabLogin.clear();
                    tabLogin.push(Qt.resolvedUrl("pages/Welcome.qml"),{"newuser":true},true);
                }
            }
        }

        //TODO: remove to single "Sheet"
        UpdateDialog {
            id: updateDialog
            z: 30
        }

        QueryDialog  {
            id: locationAllowDialog
            icon: "image://theme/icon-m-common-location-selected"
            titleText: "Location data"
            message: "Nelisquare requires use of user location data. Data is needed to make geo-location services work properly."
            acceptButtonText: "Allow"
            rejectButtonText: "Deny"
            onAccepted: {
                configuration.settingChanged("settings.gpsallow","1");
            }
            onRejected: {
                configuration.settingChanged("settings.gpsallow","0");
            }
        }

        QueryDialog  {
            id: pushNotificationDialog
            icon: "image://theme/icon-m-settings-notification"
            titleText: "Push notifications"
            message: "Incoming push notifications are not supported at this version and are disabled by default.<br/><br/>You will be promted again when they will be available at future versions."
            onAccepted: {
                configuration.settingChanged("settings.push.enabled","0");
            }
            acceptButtonText: "OK"
            /*buttons: ButtonRow {
                style: ButtonStyle { }
                anchors.horizontalCenter: parent.horizontalCenter
                Button { text: "OK"; onClicked: pushNotificationDialog.accept(); }
            }*/
        }

        NotificationDialog {
            id: notificationDialog
            z: 20
            width: parent.width
            state: "hidden"
            onClose: {
                /* TODO: this doesnt work atm. Should be deleted
                if (objectID != "") {
                    objectType = "";
                    objectID = "";
                    if(objectType=="checkin") {
                        stack.push(Qt.resolvedUrl("pages/Checkin.qml"),{"checkinID":objectID});
                    }
                }*/
                notificationDialog.state = "hidden";
            }
        }
    }

    Menu {
        id: dummyMenu
        MenuLayout {
            MenuItem {
                text: qsTr("Check updates")
                onClicked: {
                    configuration.getupdates();
                }
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: {
                    stack.push(Qt.resolvedUrl("pages/Settings.qml"));
                }
            }
            MenuItem {
                text: qsTr("Exit")
                onClicked: {
                    windowHelper.disableSwype(false);
                    Qt.quit();
                }
            }
        }
    }

    ToolBarLayout {
        id: commonTools
        //visible: true
        /* TODO: Should be upper left corner? */
        /*ToolIcon {
            iconId: stack.depth > 1 ? "toolbar-back" : "toolbar-refresh"
            onClicked: {
                if (stack.depth > 1)
                    stack.pop();
                else if (tabgroup.currentTab.currentPage.update) {
                    tabgroup.currentTab.currentPage.update()
                }
            }
        }*/
        ButtonRow {
            style: TabButtonStyle {}

            TabButtonIcon {
                platformIconId: "toolbar-home"
                tab: tabFeed
                onClicked: popToTop(tabFeed);
            }
            TabButtonIcon {
                //platformIconId: "toolbar-venues" //TODO: add icons to theme extension
                iconSource: "icons/icon-m-toolbar-venues".concat(theme.inverted ? "-white" : "").concat(".png")
                tab: tabVenues
                onClicked: popToTop(tabVenues);
            }
            TabButtonIcon {
                platformIconId: "toolbar-contact"
                tab: tabMe
                onClicked: popToTop(tabMe);
            }
        }

        ToolIcon {
            platformIconId: "toolbar-view-menu"
            onClicked: {
                //TODO: add menu
                dummyMenu.open();
            }
        }
    }

    Configuration {
        id: configuration

        onAccessTokenChanged: {
            if(accessToken.length>0) {
                tabgroup.currentTab = tabFeed;
                tabLogin.clear();
            } else {
                tabFeed.clear();
                tabVenues.clear();
                tabMe.clear();
                tabLogin.load();
                tabgroup.currentTab = tabLogin;
            }
        }
    }

    ThemeLoader {
        id: mytheme
        onNameChanged: {
            Api.api.inverted = theme.inverted;
        }
    }

    Timer {
        id: timerGPSUnlock
        interval: configuration.gpsUplockTime * 1000;
        repeat: false
        onTriggered: {
            positionSource.active = appWindow.windowActive;
        }
    }

    PositionSource {
        id: positionSource
        updateInterval: 5000
        active: false
        onPositionChanged: {
            if (configuration.platform === "maemo") {
                if(positionSource.position.latitudeValid) {
                    //TODO: signalIcon.visible = false;
                } else {
                    //TODO: signalIcon.visible = true;
                }
            }
        }
    }

    function popToTop(tab) {
        if (tabgroup.lastTab === tab) {
            while (tab.depth > 1) {
                tab.pop(tab.depth > 2);
            }
        }
        tabgroup.lastTab = tab;
    }

    function processUINotification(id) {
        stack.push(Qt.resolvedUrl("pages/Notifications.qml"));
    }

    function processURI(url) {
        var params = url.split("/");
        var type = params[0];
        var id = params[1];
        switch(type) {
        case "start":
            break;
        case "user":
            stack.push(Qt.resolvedUrl("pages/User.qml"),{"userID":id});
            break;
        case "checkin":
            stack.push(Qt.resolvedUrl("pages/Checkin.qml"),{"checkinID":id});
            break;
        }

    }

    function onCacheUpdated(callbackObject, status, url) {
        //console.log("Cache updated: " + status + " url: " + url );
        if (callbackObject !== undefined) {
            if (callbackObject.cacheCallback !== undefined) {
                try {
                    callbackObject.cacheCallback(status,url);
                }
                catch(err) {
                    console.log("Cache error: " + err);
                    console.log("Callback Object:" + JSON.stringify(callbackObject));
                }
            }
        }
    }

    function onPictureUploaded(response, page) {
        Api.photos.parseAddPhoto(response, page);
    }

    function onMolomeInfoUpdate(present,installed) {
        configuration.molome_present = present;
        configuration.molome_installed = installed;
    }

    function onMolomePhoto(state, photoUrl) {
        if (stack.currentPage.molomePhoto !== undefined) {
            stack.currentPage.molomePhoto(state, photoUrl);
        }
    }

    function onLockOrientation(value) {
        if (value === "auto") {
            mainPage.orientationLock = PageOrientation.Automatic
        } else if (value === "landscape") {
            mainPage.orientationLock = PageOrientation.LockLandscape
        } else if (value === "portrait") {
            mainPage.orientationLock = PageOrientation.LockPortrait
        }
    }
}

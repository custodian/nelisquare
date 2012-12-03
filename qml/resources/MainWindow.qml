import Qt 4.7
import QtMobility.location 1.1
import QtWebKit 1.0

import "components"
import "themes"
import "stack"
import "pages"

import "js/utils.js" as Utils
import "js/api-checkin.js" as CheckinAPI
import "js/api-photo.js" as PhotoAPI

Rectangle {
    id: window

    property bool isPortrait: true
    property bool windowActive: false

    property bool molome_present: false
    property bool molome_installed: false

    property alias positionSource: positionSource

    anchors.fill:  parent

    color: theme.colors.backgroundMain

    onWindowActiveChanged: {
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

    function onMolomePhoto(state, photoUrl) {
        //console.log("MOLO PHOTO: state:" + state + " path:" + photoUrl);
        waiting.hide();
        if (state && pageStack.currentPage.parent.url == Qt.resolvedUrl("pages/PhotoAdd.qml")) {
            photoShareDialog.photoUrl = photoUrl;
            photoShareDialog.state = "shown";
        }
    }

    function onPictureUploaded(response, page) {
        PhotoAPI.parseAddPhoto(response, page);
    }

    Component.onCompleted: {
        if (configuration.platform === "maemo") {
            signalTimer.start();
        }
        window.isPortrait = window.height > (window.width*2/3);//window.width<(window.height/2);
    }

    onHeightChanged: {
        window.isPortrait = window.height > (window.width*2/3);//window.width<(window.height/2);
    }

    Timer {
        id: signalTimer
        interval: 2000
        repeat: true
        onTriggered: {
            if(!positionSource.position.latitudeValid) {
                signalIcon.visible = !signalIcon.visible;
            }
        }
    }

    Timer {
        id: timerGPSUnlock
        interval: configuration.gpsUplockTime * 1000;
        repeat: false
        onTriggered: {
            positionSource.active = window.windowActive;
        }
    }

    PositionSource {
        id: positionSource
        updateInterval: 5000
        active: false
        onPositionChanged: {
            if (configuration.platform === "maemo") {
                if(positionSource.position.latitudeValid) {
                    signalIcon.visible = false;
                } else {
                    signalIcon.visible = true;
                }
            }
        }
    }

    function updateNotificationCount(value) {
        toolbar.notificationsCount.text = value
    }

    function showFriendsFeed() {
        if (pageStack.depth == 0) {
            pageStack.push(Qt.resolvedUrl("pages/FriendsFeed.qml"));
        } else {
            /*if (pageStack.depth == 1) {
                if (configuration.feedAutoUpdate === 0) {
                    pageStack.currentPage.lastUpdateTime = "0";
                    pageStack.currentPage.leadingMarker = "";
                }
            }*/
            pageStack.pop(null);
            if (pageStack.currentPage.update)
                pageStack.currentPage.update();
        }
    }

    ThemeLoader {
        id: theme
    }

    Configuration {
        id: configuration

        onAccessTokenChanged: {
            if(accessToken.length>0) {
                window.showFriendsFeed();
                loginStack.clear();
            } else {
                pageStack.clear();
                loginStack.push(Qt.resolvedUrl("pages/Welcome.qml"),{"newuser":true},true);
            }
        }
    }

    PageStack {
        id: loginStack
        z: 5
        visible: depth > 0
    }

    PageStack {
        id: pageStack
        y: toolbar.height
        height: window.isPortrait ? parent.height - menubar.height - toolbar.height : parent.height - toolbar.height
        width: window.isPortrait ? parent.width : parent.width - menubar.width

        WaitingIndicator {
            id: waiting
            z: 10
        }

        NotificationDialog {
            id: pushNotificationDialog
            z: 30
            width: parent.width
            state: "hidden"
            message: ""
            onStateChanged: {
                if (state === "shown")
                    message = "<span><font='+1'>Push notifications</font><br/><br/>Incoming notifications are not supported at this version and are disabled by default.<br/>You will be promted again when they will be available at future versions.</span>"
            }
            onClose: {
                configuration.settingChanged("settings.push.enabled","0");
                pushNotificationDialog.state = "hidden";
            }
        }

        NotificationDialog {
            id: notificationDialog
            z: 20
            width: parent.width
            state: "hidden"
            onClose: {
                if (objectID != "") {
                    objectType = "";
                    objectID = "";
                    if(objectType=="checkin") {
                        pageStack.push(Qt.resolvedUrl("pages/Checkin.qml"),{"checkinID":objectID});
                    }
                }
                notificationDialog.state = "hidden";

            }
        }

        //TODO: remove to single "Sheet"
        UpdateDialog {
            id: updateDialog
            z: 30
        }

        //TODO: remove to single "Sheet"
        CheckinDialog {
            id: checkinDialog
            z: 20
            width: parent.width
            state: "hidden"

            onCancel: { checkinDialog.state = "hidden"; }
            onCheckin: {
                var realComment = comment;
                if(realComment === theme.textDefaultComment) {
                    realComment = "";
                }
                var callback = function(checkinID) {
                    pageStack.push(Qt.resolvedUrl("pages/Checkin.qml"),{"checkinID":checkinID});
                }
                CheckinAPI.addCheckin(venueID, callback, realComment, friends, facebook, twitter);
                checkinDialog.state = "hidden";
            }
        }

        //TODO: remove to single "Sheet"
        PhotoShareDialog {
            id: photoShareDialog
            z: 20
            width: parent.width
            state: "hidden"
            onCancel:{
                photoShareDialog.state="hidden";
            }
            onUploadPhoto: {
                photoShareDialog.state="hidden";
                PhotoAPI.addPhoto(params);
                pageStack.pop();
            }
        }

        Item {
            id: signalIcon
            z: 1
            width: 32
            height: 32
            x: parent.width - 40
            y: parent.height - 40
            Image {
                width: 32
                height: 32
                anchors.centerIn: parent
                source: "pics/sat_dish.png"
            }
            visible: false
        }
    }

    Toolbar {
        id: toolbar
    }

    Menubar {
        id: menubar
    }

    Image {
        id: bottomShadow
        width: parent.width
        anchors.bottom: menubar.top
        visible: menubar.visible
        source:  "pics/bottom-shadow.png"
    }
}

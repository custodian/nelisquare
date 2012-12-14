import Qt 4.7
import QtMobility.location 1.2
import com.nokia.meego 1.0
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

    property bool windowActive: false

    property bool molome_present: false
    property bool molome_installed: false

    property string lastNotiCount: "0"

    property alias positionSource: positionSource
    property alias pageStack: pageStack

    anchors.fill:  parent

    color: mytheme.colors.backgroundMain

    onWindowActiveChanged: {
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

    function processUINotification(id) {
        pageStack.push(Qt.resolvedUrl("pages/Notifications.qml"));
    }

    function processURI(url) {
        var params = url.split("/");
        var type = params[0];
        var id = params[1];
        switch(type) {
        case "start":
            break;
        case "user":
            pageStack.push(Qt.resolvedUrl("pages/User.qml"),{"userID":id});
            break;
        case "checkin":
            pageStack.push(Qt.resolvedUrl("pages/Checkin.qml"),{"checkinID":id});
            break;
        }
    }

    Component.onCompleted: {
        if (configuration.platform === "maemo") {
            signalTimer.start();
        }
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
        upperbar.notificationsCount.text = value
        //console.log("last: " + lastNotiCount + " new: " + value);
        if (configuration.feedNotification!=="0") {
            if (value != lastNotiCount) {
                platformUtils.removeNotification("nelisquare.notification");
                if (value!="0") {
                    platformUtils.addNotification("nelisquare.notification",value + " new notification" +((value=="1")?"":"s"),"Nelisquare", 1);
                }
                lastNotiCount = value;
            }
        }
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
        id: mytheme
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
        y: upperbar.height
        //DBG menu tools
        height: parent.height - upperbar.height
        width: parent.width

        WaitingIndicator {
            id: waiting
            z: 10
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
                if(realComment === mytheme.textDefaultComment) {
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

    UpperBar {
        id: upperbar
    }
}

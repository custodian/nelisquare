import Qt 4.7
import QtMobility.location 1.2
import com.nokia.meego 1.0
import QtWebKit 1.0

import "components"
import "themes"
import "stack"
import "pages"

import "js/utils.js" as Utils
import "js/api-photo.js" as PhotoAPI

Rectangle {
    id: window

    property bool windowActive: false

    property alias positionSource: positionSource
    property alias pageStack: pageStack

    anchors.fill:  parent

    color: mytheme.colors.backgroundMain

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

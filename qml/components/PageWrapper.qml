import Qt 4.7
import QtQuick 1.1
import com.nokia.meego 1.0
import "."

Page {
    id: pageWrapper

    width: parent.width
    height: parent.height

    property string color
    property alias pagetop: pageHeader.bottom

    tools : commonTools
    property alias dummyMenu: dummyMenu
    property alias headerText: pageHeader.headerText
    property alias headerIcon: pageHeader.headerIcon
    property alias headerBubble: pageHeader.countBubbleVisible
    orientationLock: mainPage.orientationLock

    signal headerSelectedItem(int index)

    Component.onCompleted: {
        if (pageWrapper.load)
            pageWrapper.load()
    }

    PageHeader {
        id: pageHeader
        z: 1
        headerText: "Awesome header";

        /*onSelectedItem: {
            pageWrapper.headerSelectedItem(index);
        }*/
        visible: headerText.length > 0
    }

    function waiting_show() {
        pageHeader.busy = true;
    }

    function waiting_hide() {
        pageHeader.busy = false;
    }


    function show_error(msg) {
        show_error_base(msg);
    }

    function show_error_base(msg){
        waiting_hide();
        console.log("Error: "+ msg);
        notificationDialog.message += msg + "<br/>"
        notificationDialog.state = "shown";
        notificationDialog.hider.restart();
    }

    function show_info(msg) {
        notificationDialog.message = msg
        notificationDialog.state = "shown";
    }

    function updateNotificationCount(value) {
        appWindow.notificationsCount = value
        //console.log("last: " + lastNotiCount + " new: " + value);
        if (configuration.feedNotification!=="0") {
            if (value != appWindow.lastNotiCount) {
                platformUtils.removeNotification("nelisquare.notification");
                if (value != "0") {
                    platformUtils.addNotification("nelisquare.notification", "Nelisquare", value + " new notification" +((value=="1")?"":"s"), 1);
                }
                appWindow.lastNotiCount = value;
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
                    stack.replace(Qt.resolvedUrl("../pages/Settings.qml"));
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

}

import Qt 4.7
import "."
import "../js/utils.js" as Utils

Rectangle {
    id: toolbar

    property alias notificationsCount: notificationsCount

    height: 60
    width:parent.width
    gradient: mytheme.gradientToolbar

    MouseArea{
        anchors.fill: parent
    }

    Image {
        id: logoImage
        source: Utils.isXmas() ? "../pics/logo_xmas.png" : "../pics/logo.png"
        anchors.centerIn: parent
    }

    Image {
        id: notificationsButton
        source:
            (notificationsCount.text > 0)
                ?"../pics/notification_alarm.png"
                :"../pics/notification.png"
        x: logoImage.x + logoImage.width + 50
        anchors.verticalCenter: parent.verticalCenter

        Text {
            id: notificationsCount
            anchors.horizontalCenter: parent.horizontalCenter
            x: 5
            font.pixelSize: mytheme.font.sizeDefault - 2
            font.family: mytheme.font.name
            text: "0"
            //visible: text > 0
            color: mytheme.colors.textHeader
        }
        MouseArea {
            anchors.fill: parent
            onClicked: pageStack.push(Qt.resolvedUrl("../pages/Notifications.qml"));
        }
    }

    /*Image {
        id: settingsButton
        source: ("../pics/cogwheel_"+((pageStack.currentPage && pageStack.currentPage.parent.url == Qt.resolvedUrl("../pages/Settings.qml"))?"active.png":"passive.png"))

        x: logoImage.x - width - 50
        anchors.verticalCenter: parent.verticalCenter
        MouseArea {
            anchors.fill: parent
            onClicked: pageStack.push(Qt.resolvedUrl("../pages/Settings.qml"));
        }
    }*/

    Image {
        id: minimizeButton
        x: 4
        anchors.verticalCenter: parent.verticalCenter
        source: "../pics/minimize.png"
        width: 48
        height: 48

        MouseArea {
            anchors.fill: parent
            onClicked: windowHelper.minimize();
            enabled: pageStack.depth === 1
        }
        visible: configuration.platform === "maemo" && pageStack.depth === 1
    }

    Image {
        id: buttonClose
        x: parent.width - width - 4
        anchors.verticalCenter: parent.verticalCenter
        source: "../pics/close.png"
        width: 48
        MouseArea {
            anchors.fill: parent
            onClicked: Qt.quit();
            enabled: pageStack.depth === 1
        }
        visible: configuration.platform === "maemo" && pageStack.depth === 1
    }

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 2
        color: mytheme.colors.toolbarLightColor
    }

    Image {
        id: shadow
        source:  "../pics/top-shadow.png"
        width: parent.width
        y: parent.height - 1
    }
}

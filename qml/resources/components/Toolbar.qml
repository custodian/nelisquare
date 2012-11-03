import Qt 4.7
import "."

Rectangle {
    id: toolbar

    property alias notificationsCount: notificationsCount

    height: 60
    width:parent.width
    gradient: theme.gradientToolbar

    MouseArea{
        anchors.fill: parent
    }

    Image {
        id: logoImage
        source: "../pics/logo.png"
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
            font.pixelSize: theme.font.sizeDefault - 2
            font.family: theme.font.name
            text: "0"
            //visible: text > 0
            color: theme.colors.textHeader
        }
        MouseArea {
            anchors.fill: parent
            onClicked: window.showNotifications();
        }
    }

    Image {
        id: settingsButton
        source: ("../pics/cogwheel_"+(topWindowType == "Settings"?"active.png":"passive.png"))
        x: logoImage.x - width - 50
        anchors.verticalCenter: parent.verticalCenter
        MouseArea {
            anchors.fill: parent
            onClicked: window.showSettingsPage();
        }
    }

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
        }
        visible: theme.platform === "maemo"
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
        }
        visible: theme.platform === "maemo"
    }

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 2
        color: theme.colors.toolbarLightColor
    }

    Image {
        id: shadow
        source:  "../pics/top-shadow.png"
        width: parent.width
        y: parent.height - 1
    }
}

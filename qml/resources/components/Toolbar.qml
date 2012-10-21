import Qt 4.7
import "."

Rectangle {
    id: toolbar

    property alias notificationsCount: notificationsCount

    height: 60
    width:parent.width
    gradient: Gradient{
        GradientStop{position: 0; color: "#3098c7"; }
        GradientStop{position: 1.0; color: "#1477a8"; }
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
            color: theme.textColorSign
        }
        MouseArea {
            anchors.fill: parent
            onClicked: window.showNotifications();
        }
    }

    Image {
        id: settingsButton
        source: ("../pics/cogwheel_"+(settings.visible?"active.png":"passive.png"))
        x: logoImage.x - width - 50
        anchors.verticalCenter: parent.verticalCenter
        MouseArea {
            anchors.fill: parent
            onClicked: window.showSettingsPage();
        }
    }

    ButtonEx {
        id: minimizeButton
        pic: "minimize.png"
        x: 4
        anchors.verticalCenter: parent.verticalCenter
        width: 48
        height: 48
        border.width: 0
        gradient: toolbar.gradient
        onClicked: {
            windowHelper.minimize();
        }
        visible: windowHelper.isMaemo()
    }

    ButtonEx {
        id: buttonClose
        pic: "close.png"
        x: parent.width - width - 4
        width: 48
        anchors.verticalCenter: parent.verticalCenter
        gradient: toolbar.gradient
        border.width: 0
        onClicked: Qt.quit();
        visible: windowHelper.isMaemo()
    }

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 2
        color: theme.toolbarLightColor
    }

    Image {
        id: shadow
        source:  "../pics/top-shadow.png"
        width: parent.width
        y: parent.height - 1
    }
}
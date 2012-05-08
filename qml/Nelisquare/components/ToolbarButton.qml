import Qt 4.7

Item {
    id: toolbarButton
    property string image: ""
    property string label: ""
    property bool selected: false
    property bool shown: true
    signal clicked()
    width: window.isSmallScreen ? 80 : 90
    height: 58
    //border.color: mouse.pressed ? "#333" : "#555"
    //border.width: 1
    //gradient: mouse.pressed ? pressedColor : idleColor

    Rectangle {
        radius: 6
        smooth: true
        visible: toolbarButton.selected || mouse.pressed
        anchors.fill: parent
        gradient: Gradient {
            GradientStop{position: 0; color: "#bbb"; }
            GradientStop{position: 0.49; color: "#aaa"; }
            GradientStop{position: 0.5; color: "#888"; }
            GradientStop{position: 0.9; color: "#777"; }
        }
    }

    Gradient {
        id: idleColor
        GradientStop{position: 0.2; color: "#6f6f6f"; }
        GradientStop{position: 0.49; color: "#666"; }
        GradientStop{position: 0.5; color: "#707070"; }
        GradientStop{position: 0.8; color: "#606060"; }
    }

    Gradient {
        id: pressedColor
        GradientStop{position: 0; color: "#bbb"; }
        GradientStop{position: 0.49; color: "#aaa"; }
        GradientStop{position: 0.5; color: "#888"; }
        GradientStop{position: 0.9; color: "#777"; }
    }


    Image {
        source: "../pics/" + toolbarButton.image
        anchors.horizontalCenter: parent.horizontalCenter
        y: 8
        visible: shown
    }

    Text {
        text: toolbarButton.label
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        color: "#eee"
        font.pixelSize: 12
        visible: shown && toolbarButton.label.length > 0
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        onClicked: {
            if (shown) {
                toolbarButton.clicked();
            }
        }
    }
}

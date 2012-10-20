import Qt 4.7

Rectangle {
    id: button
    width: 100
    height: 50
    property string label: "-"
    signal clicked()

    smooth: true
    border.color: theme.greenButtonBorderColor
    border.width: 2
    gradient: mouse.pressed ? pressedColor : theme.gradientGreen //idleColor

    Gradient {
        id: pressedColor
        GradientStop{position: 0; color: "#666"; }
        GradientStop{position: 0.1; color: "#aaa"; }
        GradientStop{position: 0.6; color: "#888"; }
        GradientStop{position: 0.9; color: "#777"; }
    }

    Text {
        text: button.label
        font.pixelSize: 24
        color: "#fff"
        anchors.centerIn: parent
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        onClicked: button.clicked();
    }
}

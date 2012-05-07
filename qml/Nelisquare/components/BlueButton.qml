import Qt 4.7

Rectangle {
    id: button
    width: 100
    height: 50
    property string label: "-"
    signal clicked()
    radius: 6
    property bool pressed: false

    smooth: true
    //border.color: mouse.pressed ? "#17649A" : "#3784cA"
    //border.width: button.pressed ? 0 : 2
    gradient: button.pressed ? pressedColor : (mouse.pressed ? pressedColor : idleColor)

    Gradient {
        id: idleColor
        //GradientStop{position: 0; color: "#3784cA"; }
        GradientStop{position: 0.3; color: "#3784cA"; }
        //GradientStop{position: 0.6; color: "#17649A"; }
        GradientStop{position: 1; color: "#19548A"; }
    }

    Gradient {
        id: pressedColor
        GradientStop{position: 0; color: "#10446A"; }
        GradientStop{position: 0.1; color: "#17548A"; }
        GradientStop{position: 0.6; color: "#17447A"; }
        GradientStop{position: 0.9; color: "#2060a0"; }
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

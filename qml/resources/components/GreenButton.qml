import Qt 4.7

Rectangle {
    id: button
    width: 100
    height: 50
    property string label: "-"
    signal clicked()
    radius: 6

    smooth: true
    //border.color: mouse.pressed ? "#666" : "#A8CB17" // "#98bB17" : "#c8eB37"
    //border.width: 2
    gradient: mouse.pressed ? pressedColor : idleColor

    Gradient {
        id: idleColor
        GradientStop{position: 0; color: "#c8eB37"; }
        //GradientStop{position: 0.1; color: "#A8CB17"; }
        GradientStop{position: 0.6; color: "#A8CB17"; }
        //GradientStop{position: 1.0; color: "#98bB17"; }
        //GradientStop{position: 1.0; color: "#98bB17"; }
    }

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

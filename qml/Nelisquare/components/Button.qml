import Qt 4.7

Rectangle {
    id: button
    width: 100
    height: 50
    property string label: ""
    property string pic: ""
    signal clicked()
    radius: 6

    smooth: true
    border.color: mouse.pressed ? "#666" : "#999"
    border.width: 1
    gradient: mouse.pressed ? pressedColor : idleColor

    Gradient {
        id: idleColor
        GradientStop{position: 0; color: "#bbb"; }
        GradientStop{position: 0.1; color: "#ccc"; }
        GradientStop{position: 0.6; color: "#aaa"; }
        GradientStop{position: 0.9; color: "#999"; }
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

    Image {
        source: "../pics/" + button.pic
        anchors.centerIn: parent
        visible: pic.length>0
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        onClicked: button.clicked();
    }
}

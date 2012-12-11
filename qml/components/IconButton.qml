import Qt 4.7

Item {
    id: toolbarButton
    property string image: ""
    property int imageSize: 32
    property string label: ""
    property bool selected: false
    property bool shown: true
    signal clicked()
    width: imageSize + 42
    height: imageSize + 26

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
        source: "../pics/"+mytheme.name+"/" + toolbarButton.image
        anchors.horizontalCenter: parent.horizontalCenter
        y: 8
        width: imageSize
        height: imageSize
        visible: shown
    }

    Text {
        text: toolbarButton.label
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        color: "#eee"
        font.pixelSize: 14 //TODO: is too small ?
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

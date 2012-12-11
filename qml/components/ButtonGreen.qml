import Qt 4.7

Rectangle {
    id: button
    width: 100
    height: 50
    property string label: "-"
    signal clicked()

    smooth: true
    border.color: mouse.pressed ? mytheme.colors.greenButtonBorderColorPressed : mytheme.colors.greenButtonBorderColor
    border.width: 2
    gradient: mouse.pressed ? mytheme.gradientGreenPressed : mytheme.gradientGreen //idleColor

    Text {
        text: button.label
        font.pixelSize: 24
        color: mouse.pressed ? mytheme.colors.textColorButtonPressed : mytheme.colors.textColorButton
        anchors.centerIn: parent
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        onClicked: button.clicked();
    }
}

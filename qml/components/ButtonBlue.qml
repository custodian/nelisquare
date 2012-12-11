import Qt 4.7

Rectangle {
    id: button
    signal clicked()

    property string label: "-"
    property bool pressed: false

    property int fontDeltaSize: 0

    width: 100
    height: 50
    border.width: 2
    border.color: pressed?mytheme.colors.blueButtonBorderColorPressed:mytheme.colors.blueButtonBorderColor

    smooth: true
    gradient: button.pressed ? mytheme.gradientBluePressed : (mouse.pressed ? mytheme.gradientBluePressed : mytheme.gradientBlue)

    Text {
        text: button.label
        font.pixelSize: mytheme.font.sizeDefault + fontDeltaSize
        color: button.pressed ? mytheme.colors.textColorButtonPressed : mytheme.colors.textColorButton
        anchors.centerIn: parent
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        onClicked: button.clicked();
    }
}

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
    border.color: pressed?theme.colors.blueButtonBorderColorPressed:theme.colors.blueButtonBorderColor

    smooth: true
    gradient: button.pressed ? theme.gradientBluePressed : (mouse.pressed ? theme.gradientBluePressed : theme.gradientBlue)

    Text {
        text: button.label
        font.pixelSize: theme.font.sizeDefault + fontDeltaSize
        color: button.pressed ? theme.colors.textColorButtonPressed : theme.colors.textColorButton
        anchors.centerIn: parent
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        onClicked: button.clicked();
    }
}

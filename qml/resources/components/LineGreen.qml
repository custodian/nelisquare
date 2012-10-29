import Qt 4.7

Rectangle   {
    id: greenLine

    property string text: ""
    property int size: theme.font.sizeSigns

    width: parent.width
    height: 30

    gradient: theme.gradientGreen

    Text {
        color: theme.textColorSign
        text: greenLine.text
        font.pixelSize: theme.font.sizeSigns
        anchors.centerIn: parent
    }
}

import Qt 4.7

Rectangle   {
    id: greenLine

    property string text: ""
    property int size: theme.font.sizeSigns

    width: parent.width
    height: 30

    gradient: theme.gradientHeader

    Text {
        text: greenLine.text
        color: theme.colors.textHeader
        font.pixelSize: size
        anchors.centerIn: parent
    }
}

import Qt 4.7

Rectangle   {
    id: greenLine

    property string text: ""
    property int size: mytheme.font.sizeSigns

    width: parent.width
    height: 30

    gradient: mytheme.gradientHeader

    Text {
        text: greenLine.text
        color: mytheme.colors.textHeader
        font.pixelSize: size
        anchors.centerIn: parent
    }
}

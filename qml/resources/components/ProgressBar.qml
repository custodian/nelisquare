import Qt 4.7

Item {
    id: progress
    property int percent: 0;
    property int percentMax: 100;
    property string types: "";
    property bool showPercent: false
    property int radiusValue: 0

    width: parent.width
    height: 32

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        radius: radiusValue
        height: parent.height
        width: parent.width
        color: mytheme.colors.scoreBackgroundColor
    }
    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        radius: radiusValue
        height: parent.height
        width: parent.width * percent / percentMax
        color: mytheme.colors.scoreForegroundColor
        onWidthChanged: {
            if (width > 50) {
                percentText.anchors.left = undefined;
                percentText.anchors.right = right;
                percentText.color = mytheme.colors.textColorSign;
            } else {
                percentText.anchors.right = undefined;
                percentText.anchors.left = right;
                percentText.color = mytheme.colors.textColorOptions;
            }
        }
        Text {
            id: percentText
            text: "  " + percent + progress.types + "  "
            font.pixelSize: mytheme.font.sizeHelp
            anchors.verticalCenter: parent.verticalCenter
            color: mytheme.colors.textColorSign
            visible: showPercent>0
        }
    }
}

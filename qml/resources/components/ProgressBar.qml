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
        color: theme.scoreBackgroundColor
    }
    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        radius: radiusValue
        height: parent.height
        width: parent.width * percent / percentMax
        color: theme.scoreForegroundColor
        onWidthChanged: {
            if (width > 50) {
                percentText.anchors.left = undefined;
                percentText.anchors.right = right;
            } else {
                percentText.anchors.right = undefined;
                percentText.anchors.left = right;
            }
        }
        Text {
            id: percentText
            text: "  " + percent + progress.types + "  "
            font.pixelSize: theme.font.sizeHelp
            anchors.verticalCenter: parent.verticalCenter
            color: theme.textColorSign
            visible: showPercent>0
        }
    }
}

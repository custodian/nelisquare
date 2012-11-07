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
        color: theme.colors.scoreBackgroundColor
    }
    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        radius: radiusValue
        height: parent.height
        width: parent.width * percent / percentMax
        color: theme.colors.scoreForegroundColor
        onWidthChanged: {
            if (width > 50) {
                percentText.anchors.left = undefined;
                percentText.anchors.right = right;
                percentText.color = theme.colors.textColorSign;
            } else {
                percentText.anchors.right = undefined;
                percentText.anchors.left = right;
                percentText.color = theme.colors.textColorOptions;
            }
        }
        Text {
            id: percentText
            text: "  " + percent + progress.types + "  "
            font.pixelSize: theme.font.sizeHelp
            anchors.verticalCenter: parent.verticalCenter
            color: theme.colors.textColorSign
            visible: showPercent>0
        }
    }
}
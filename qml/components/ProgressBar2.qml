import Qt 4.7

Item {
    id: progress
    property int value: 0
    property int minimumValue: 0
    property int maximumValue: 100
    property string types: ""
    property bool showPercent: false
    property int radiusValue: 0
    property bool indeterminate: false

    width: parent.width
    height: 32

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        radius: radiusValue
        height: parent.height
        width: parent.width
        color: mytheme.colors.scoreBackgroundColor
        visible: !indeterminate
    }
    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        radius: radiusValue
        height: parent.height
        width: parent.width * value / (maximumValue - minimumValue)
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
            text: "  " + value + progress.types + "  "
            font.pixelSize: mytheme.font.sizeHelp
            anchors.verticalCenter: parent.verticalCenter
            color: mytheme.colors.textColorSign
            visible: showPercent>0
        }
        visible: !indeterminate
    }
    Image {
        id: loader
        source: "../pics/waiting.gif"
        width: parent.width
        //height: parent.height
        anchors.centerIn: parent
        visible: indeterminate
    }
}

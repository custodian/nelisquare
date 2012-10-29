import Qt 4.7

Rectangle {
    id: button
    width: 100
    height: 50
    property string label: ""
    property string pic: ""
    property int imageSize: 48
    signal clicked()

    smooth: true
    border.color: mouse.pressed ? theme.grayButtonBorderColorPressed : theme.grayButtonBorderColor
    border.width: 1
    gradient: mouse.pressed ? theme.gradientGrayPressed : theme.gradientGray

    Image {
        id: icon
        source: button.pic.length>0?"../pics/" + button.pic:""
        anchors.centerIn: parent
        width: imageSize
        height: imageSize
        visible: pic.length>0
    }

    Text {
        text: button.label
        font.pixelSize: 24
        color: theme.textColorSign
        anchors.centerIn: parent
        visible: button.label.length>0
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        onClicked: button.clicked();
    }
}

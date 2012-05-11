import Qt 4.7

Rectangle {
    signal clicked()
    property string photoUrl: ""
    property int photoSize: 64
    property int photoBorder: 4
    property bool enableMouseArea: true
    property variant photoAspect: Image.PreserveAspectFit

    id: profileImage
    x: photoBorder
    y: photoBorder
    width: photoSize
    height: photoSize
    color: "#fff"
    border.color: "#ccc"
    border.width: 1

    Image {
        id: image
        x: photoBorder
        y: photoBorder
        source: photoUrl
        smooth: true
        fillMode: photoAspect
        width: photoSize - 2*photoBorder + 1
        height: photoSize - 2*photoBorder + 1
    }

    MouseArea {
        anchors.fill: profileImage
        onClicked: {
            profileImage.clicked();
        }
        visible: enableMouseArea
    }
}

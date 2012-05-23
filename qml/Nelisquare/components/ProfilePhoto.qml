import Qt 4.7

Rectangle {
    signal clicked()
    property string photoUrl: ""
    property int photoSize: 64
    property int photoBorder: 4
    property variant photoSourceSize: undefined
    property bool enableMouseArea: true
    property alias photoSmooth: image.smooth
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
        asynchronous: true
        source: photoUrl
        smooth: true
        fillMode: photoAspect
        width: photoSize - 2*photoBorder + 1
        height: photoSize - 2*photoBorder + 1
        sourceSize.width: photoSourceSize
        sourceSize.height: photoSourceSize
        onStatusChanged: {
            image.visible = (image.status == Image.Ready)
            loader.visible = (image.status != Image.Ready)
        }
    }

    /*Animated*/Image {
        id: loader
        anchors.centerIn: image
        source: "../pics/"+window.iconset+"/loader.gif"
    }

    MouseArea {
        anchors.fill: profileImage
        onClicked: {
            profileImage.clicked();
        }
        visible: enableMouseArea
    }
}

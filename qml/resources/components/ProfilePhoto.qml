import Qt 4.7

Rectangle {
    signal clicked()
    property string photoUrl: ""
    property int photoSize: 64
    property int photoBorder: 4
    property bool photoCache: true
    property variant photoSourceSize: undefined
    property bool enableMouseArea: true
    property alias photoSmooth: image.smooth
    property variant photoAspect: Image.PreserveAspectCrop

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
        source: cache.get(photoUrl)
        //cache: photoCache
        smooth: true
        fillMode: photoAspect
        width: photoSize - 2*photoBorder + 1
        height: photoSize - 2*photoBorder + 1
        sourceSize.width: width // photoSourceSize
        //sourceSize.height: height //photoSourceSize
        clip: true
        onStatusChanged: {
            image.visible = (image.status == Image.Ready)
            loader.visible = (image.status != Image.Ready)
        }
    }

    /*Animated*/Image {
        id: loader
        anchors.centerIn: image
        source: "../pics/loader.png"
    }

    MouseArea {
        anchors.fill: profileImage
        onClicked: {
            profileImage.clicked();
        }
        visible: enableMouseArea
    }
}

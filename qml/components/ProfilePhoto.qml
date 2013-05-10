import Qt 4.7
import com.nokia.meego 1.0
//import com.nokia.extras 1.1 //MaskedItem

Rectangle {
    id: profileImage

    signal clicked()

    property string photoUrl: ""
    property int photoSize: 64
    property int photoWidth: photoSize
    property int photoHeight: photoSize
    property int photoBorder: 4
    property bool photoCache: true
    property variant photoSourceSize: undefined
    property bool enableMouseArea: true
    property alias photoSmooth: image.smooth
    property variant photoAspect: Image.PreserveAspectCrop

    x: photoBorder
    y: photoBorder
    width: photoWidth
    height: photoHeight
    color: mytheme.colors.photoBackground
    border.color: mytheme.colors.photoBorderColor
    border.width: 1

    /*MaskedItem {
        width: photoWidth
        height: photoHeight
        anchors.fill: parent

        mask: Image{ source: "../pics/image_mask.png"}
    */

        CacheImage {
            id: image
            x: photoBorder
            y: photoBorder
            asynchronous: true
            source: photoCache ? cache.get(photoUrl, image) : photoUrl
            //cache: photoCache
            smooth: true
            fillMode: photoAspect
            width: parent.width - 2*photoBorder + 1
            height: parent.height - 2*photoBorder + 1
            sourceSize.width: width // photoSourceSize
            //sourceSize.height: height //photoSourceSize
            clip: true

            onStatusChanged: {
                image.visible = (image.status == Image.Ready)
                loader.visible = (image.status != Image.Ready)
                if (image.status == Image.Error) {
                    console.log("Remove bad cached element");
                    //cache.remove(photoUrl); //DBG
                }
            }
            Image {
                id: loader
                anchors.centerIn: image
                source: "../pics/"+mytheme.name+"/loader.png"
            }
        }
    //}

    MouseArea {
        anchors.fill: profileImage
        onClicked: {
            profileImage.clicked();
        }
        visible: enableMouseArea
    }
}

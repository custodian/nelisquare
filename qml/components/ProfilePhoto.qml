import Qt 4.7
import com.nokia.meego 1.0
import com.nokia.extras 1.1 //MaskedItem

//DBG Split into 2 different parts
Item {//DBG Rectangle {
    id: profileImage

    signal clicked()

    property string photoUrl: ""
    property int photoSize: 64
    property int photoWidth: photoSize
    property int photoHeight: photoSize
    property int photoBorder: 0 //DBG 4 //Removing edges and backgroundcolor
    property bool photoCache: true
    property variant photoSourceSize: undefined
    property bool enableMouseArea: true
    property alias photoSmooth: image.smooth
    property variant photoAspect: Image.PreserveAspectCrop

    x: 4*2//photoBorder //DBG
    y: 4*2//photoBorder //DBG
    width: photoWidth
    height: photoHeight
    //color: mytheme.colors.photoBackground
    //border.color: mytheme.colors.photoBorderColor
    //border.width: 1

    /*MaskedItem {
        width: photoWidth
        height: photoHeight
        anchors.fill: parent
        mask: Image{
            width: photoWidth
            height: photoHeight
            source: "../pics/image_mask.png"
        }*/


        CacheImage {
            id: image
            //x: photoBorder //DBG
            //y: photoBorder //DBG
            asynchronous: true
            sourceUncached: photoUrl //photoCache
            //cache: photoCache
            smooth: true
            fillMode: photoAspect
            width: parent.width //- 2*photoBorder + 1 //DBG
            height: parent.height //- 2*photoBorder + 1 //DBG
            sourceSize.width: width // photoSourceSize
            //sourceSize.height: height //photoSourceSize
            clip: true
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

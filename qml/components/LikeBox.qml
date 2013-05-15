import Qt 4.7

Item {
    id: likeBox
    signal like(bool state)
    signal dislike(bool state)
    signal showlikes()

    property int likes: 0
    property bool mylike: false
    property bool mydislike: false
    property string likeText: ""

    property bool showDislike: false

    width: parent.width
    height: likeRow.height + 30

    visible: likes>0

    function toggleLike() {
        likeBox.mylike = !likeBox.mylike;
        likeBox.like(likeBox.mylike);
    }

    Column {
        id: likeRow
        width: parent.width
        spacing: 20
        anchors.verticalCenter: parent.verticalCenter

        SectionHeader {
            text: "USER LIKES"
        }

        /*Row {
            width: parent.width
            spacing: 20

            Image {
                id: likeImage
                y: 10
                //width: 48
                //height: 48
                smooth: true
                asynchronous: true
                source: "../pics/"+mytheme.name+"/"+((likeBox.mylike)?"heart_liked.png":"heart_like.png")


            }*/

            Text {
                //anchors.verticalCenter: likeImage.verticalCenter
                text: likeBox.likeText
                width: parent.width
                font.pixelSize: mytheme.font.sizeSigns
                color: mytheme.colors.textColorTimestamp
                wrapMode: Text.Wrap
                //visible: likeBox.likes>0
            }
        //}
    }

    MouseArea {
        anchors.fill: parent

        onClicked: {
            showlikes();
        }
    }
}

import Qt 4.7
import com.nokia.meego 1.0
import QtQuick 1.1
import "../components"

import "../js/api.js" as Api

PageWrapper {
    signal user(string user)
    signal venue(string venueid)
    signal prevPhoto()
    signal nextPhoto()

    id: photoDetails
    width: parent.width
    height: parent.height

    color: mytheme.colors.backgroundMain

    headerText: qsTr("PHOTO")
    headerIcon: "../icons/icon-header-photos.png"

    property string photoID: ""
    property string photoUrl: ""
    property alias owner: photoOwner

    tools: ToolBarLayout{
        ToolIcon{
            platformIconId: "toolbar-back"
            onClicked: stack.pop()
        }
        ToolIcon{
            iconSource: "../icons/icon-m-toolbar-mediacontrol-backwards"+(theme.inverted?"-white":"")+".png"
            onClicked: photoDetails.prevPhoto()
        }
        ToolIcon{
            iconSource: "../icons/icon-m-toolbar-mediacontrol-forward"+(theme.inverted?"-white":"")+".png"
            onClicked: photoDetails.nextPhoto()
        }
        ToolIcon {
            iconSource: "../icons/icon-m-toolbar-directory-move-to"+(theme.inverted?"-white":"")+".png"
            onClicked: {
                waiting_show();
                if (fullImage.status != Image.Ready) {
                    show_error(qsTr("You cannot save image until download is finished"))
                } else {
                    var filePath = pictureHelper.saveImage(fullImage);
                    if (filePath) {
                        show_info(qsTr("Image saved to %1").arg(filePath));
                    } else {
                        show_error(qsTr("Failed to save image"));
                    }
                }
                waiting_hide();
            }
        }
        ToolIcon {
            platformIconId: "toolbar-view-menu"
            onClicked: {
                //TODO: add menu
                dummyMenu.open();
            }
        }
    }

    function load() {
        var page = photoDetails;
        page.user.connect(function(user) {
            stack.push(Qt.resolvedUrl("User.qml"),{"userID":user});
        });
        page.venue.connect(function(venueid) {
            stack.push(Qt.resolvedUrl("Venue.qml"),{"venueID":venueid});
        });
        Api.photos.loadPhoto(page,photoID);
    }

    Flickable {
        id: imageFlickable
        anchors {
            top: pagetop
            bottom: photoOwner.top
        }
        width: parent.width

        contentWidth: imageContainer.width; contentHeight: imageContainer.height
        clip: true
        onHeightChanged: if (fullImage.status === Image.Ready) fullImage.fitToScreen()

        Item {
            id: imageContainer
            width: Math.max(fullImage.width * fullImage.scale, imageFlickable.width)
            height: Math.max(fullImage.height * fullImage.scale, imageFlickable.height)

            Image {
                id: fullImage

                anchors.centerIn: parent
                fillMode: Image.PreserveAspectFit
                cache: false
                asynchronous: true
                source: photoDetails.photoUrl
                sourceSize.height: 1000
                smooth: !imageFlickable.moving

                onProgressChanged: {
                    loadProgress.value = progress*100;
                }

                onStatusChanged: {
                    if (status == Image.Ready) {
                        fitToScreen()
                    }
                }

                onScaleChanged: {
                    if ((width * scale) > imageFlickable.width) {
                        var xoff = (imageFlickable.width / 2 + imageFlickable.contentX) * scale / prevScale;
                        imageFlickable.contentX = xoff - imageFlickable.width / 2
                    }
                    if ((height * scale) > imageFlickable.height) {
                        var yoff = (imageFlickable.height / 2 + imageFlickable.contentY) * scale / prevScale;
                        imageFlickable.contentY = yoff - imageFlickable.height / 2
                    }
                    prevScale = scale
                }

                property real prevScale

                function fitToScreen() {
                    scale = Math.min(imageFlickable.width / width, imageFlickable.height / height, 1)
                    pinchArea.minScale = scale
                    prevScale = scale
                }
            }

            ProgressBar2 {
                id: loadProgress
                anchors.centerIn: imageContainer
                minimumValue: 0
                maximumValue: 100
                width: parent.width*0.8
                visible: (fullImage.status != Image.Ready)
                indeterminate: fullImage.status == Image.Null || value === 0
            }
        }

        PinchArea {
            id: pinchArea

            property real minScale: 1.0
            property real maxScale: 4.0

            anchors.fill: parent
            enabled: fullImage.status === Image.Ready
            pinch.target: fullImage
            pinch.minimumScale: minScale * 0.5 // This is to create "bounce back effect"
            pinch.maximumScale: maxScale * 1.5 // when over zoomed

            onPinchFinished: {
                imageFlickable.returnToBounds()
                if (fullImage.scale < pinchArea.minScale) {
                    bounceBackAnimation.to = pinchArea.minScale
                    bounceBackAnimation.start()
                }
                else if (fullImage.scale > pinchArea.maxScale) {
                    bounceBackAnimation.to = pinchArea.maxScale
                    bounceBackAnimation.start()
                }
            }

            NumberAnimation {
                id: bounceBackAnimation
                target: fullImage
                duration: 250
                property: "scale"
                from: fullImage.scale
            }
        }
    }
    ScrollDecorator { flickableItem: imageFlickable }

    EventBox {
        id: photoOwner
        anchors.bottom: parent.bottom
        fontSize: 18
        onUserClicked: {
            user(photoDetails.owner.userID);
        }
        onAreaClicked: {
            venue(photoDetails.owner.venueID);
        }
    }
}

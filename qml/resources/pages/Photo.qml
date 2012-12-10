import Qt 4.7
import com.nokia.meego 1.0
import QtQuick 1.1
import "../components"

import "../js/api-photo.js" as PhotoAPI

PageWrapper {
    signal user(string user)
    signal prevPhoto()
    signal nextPhoto()

    id: photoDetails
    width: parent.width
    height: parent.height

    color: mytheme.colors.backgroundMain

    property string photoID: ""
    property string photoUrl: ""
    property alias owner: photoOwner

    tools: ToolBarLayout{
        ToolIcon{
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
        ToolIcon{
            platformIconId: "toolbar-mediacontrol-backwards"
            onClicked: photoDetails.prevPhoto()
        }
        ToolIcon{
            platformIconId: "toolbar-mediacontrol-forward"
            onClicked: photoDetails.nextPhoto()
        }
        ToolIcon {
            platformIconId: "toolbar-directory-move-to"
            onClicked: {
                //TODO: save image to disk
            }
        }
        ToolIcon {
            platformIconId: "toolbar-view-menu"
            onClicked: {
                //TODO: add menu
            }
        }
    }

    function load() {
        var page = photoDetails;
        page.user.connect(function(user) {
            pageStack.push(Qt.resolvedUrl("User.qml"),{"userID":user});
        });
        PhotoAPI.loadPhoto(page,photoID);
    }

    Item {
        id: imageHolder
        width: parent.width
        height: parent.height - photoOwner.height
        anchors.top: parent.top

        Image {
            id: fullImage
            width: imageHolder.width
            height: imageHolder.height

            asynchronous: true
            //cache: false
            fillMode: Image.PreserveAspectFit
            source: photoDetails.photoUrl
            onProgressChanged: {
                loadProgress.percent = progress*100;
            }

            ProgressBar {
                id: loadProgress
                anchors.centerIn: fullImage
                radiusValue: 5
                height: 16
                width: parent.width*0.8
                visible: (fullImage.status != Image.Ready)
            }
        }

        SwypeArea {
            id: swypeArea
            onPan: {
                //console.log("PAN: dx:" + dx + " dy:" + dy);
                if (dx>0) {
                    if (fullImage.x<0)
                        fullImage.x += dx;
                } else {
                    if ((fullImage.x + fullImage.width) > imageHolder.width)
                        fullImage.x += dx;
                }

                if (dy>0) {
                    if (fullImage.y<0)
                        fullImage.y += dy;
                } else {
                    if ((fullImage.y + fullImage.height) > imageHolder.height)
                        fullImage.y += dy;
                }
            }

            onZoom: {
                //console.log("ZOOM: " + zoom);
                var delta;
                //TODO: polish zoomin/zoomout for full fit
                if (zoom>0) {
                    if (fullImage.width < fullImage.sourceSize.width){
                        delta = (fullImage.width * zoom);
                        fullImage.width += delta;
                        fullImage.x -= delta/2;
                    }
                    if (fullImage.height < fullImage.sourceSize.height) {
                        delta = (fullImage.height * zoom);
                        fullImage.height += delta;
                        fullImage.y -= delta/2;
                    }
                } else {
                    if (fullImage.width > imageHolder.width) {
                        delta = (fullImage.width * zoom);
                        fullImage.x -= delta/2;
                        if (fullImage.x>0) {
                            delta -= fullImage.x
                            fullImage.x = 0;
                        }
                        fullImage.width += delta
                    }
                    if (fullImage.height > imageHolder.height) {
                        delta = (fullImage.height * zoom);
                        fullImage.y -= delta/2;
                        if (fullImage.y>0) {
                            delta -= fullImage.y
                            fullImage.y = 0;
                        }
                        fullImage.height += delta
                    }
                }
            }

            onSwype: {
                if (fullImage.width <= imageHolder.width) {
                    fullImage.width = imageHolder.width;
                    fullImage.height = imageHolder.height;
                    if (type === 4 || type === 8) {
                        photoDetails.prevPhoto();
                    } else if (type === 6 || type === 2) {
                        photoDetails.nextPhoto();
                    }
                }
            }
        }
    }

    EventBox {
        id: photoOwner
        anchors.bottom: parent.bottom
        fontSize: 18
        onAreaClicked: {
            user(photoDetails.owner.userID);
        }
    }
}

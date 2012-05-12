import Qt 4.7
import QtMobility.gallery 1.1

Rectangle {
    signal path(string checkin, string photo)

    property string checkinID: ""
    property int galleryOffset: 0
    property int galleryLimit: 2


    id: photoAddDialog
    width: parent.width
    height: parent.height

    ListModel {
        id: galleryModelFake
    }

    DocumentGalleryModel {
        id: galleryModelReal

        limit: galleryLimit
        offset: galleryOffset
        autoUpdate: true
        scope: DocumentGallery.Image
        properties: [ "filePath" ]
        //rootType: DocumentGallery.Image
        //properties: [ "fileName" ]
        filter: GalleryWildcardFilter {
            property: "fileName";
            value: "*.jpg";
        }
        sortProperties: [ "-lastModified" ]
    }

    Component {
         id: photoDelegate
         ProfilePhoto {
            photoUrl: model.filePath
            //photoUrl: model.fileName
            photoSize: photoGrid.cellWidth
            photoBorder: 2
            photoAspect: Image.PreserveAspectFit
            onClicked: {
                //console.log("PHOTOADD MODEL: " + JSON.stringify(model));
                photoAddDialog.path(checkinID, model.filePath);
            }
         }
     }

    GridView {
        id: photoGrid
        width: parent.width
        height: parent.height - rowNavigation.height
        cellWidth: Math.min(width/2,height)
        cellHeight: cellWidth
        clip: true
        //model: galleryModel
        delegate: photoDelegate
    }

    Row {
        id: rowNavigation
        width: parent.width
        anchors.bottom: parent.bottom
        //TODO: fast image paginator
        BlueButton {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            width: 200
            label: "<-- Prev"
            visible: galleryOffset > 0
            onClicked: {
                galleryOffset -= galleryLimit;
                if (galleryOffset<0)
                    galleryOffset = 0;
            }
        }

        BlueButton {
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            width: 100
            label: "Latest"
            visible: galleryOffset > 0
            onClicked: {
                galleryOffset = 0;
            }
        }

        BlueButton {
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            width: 200
            label: "Next -->"
            visible: photoGrid.count >= galleryLimit
            onClicked: {
                galleryOffset += galleryLimit;
            }
        }
    }

    onStateChanged: {
        if (photoAddDialog.state == "shown") {
            photoGrid.model = galleryModelReal;
        } else {
            photoGrid.model = galleryModelFake;
        }
    }

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: photoAddDialog
                x: -parent.width
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: photoAddDialog
                x: 0
            }
        }
    ]

    transitions: [
        Transition {
            SequentialAnimation {
                PropertyAnimation {
                    target: photoAddDialog
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}

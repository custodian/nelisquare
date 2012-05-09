import Qt 4.7
import QtMobility.gallery 1.1

Rectangle {
    signal path(string checkin, string photo, int size)

    property string checkinID: ""
    property variant galleryModel: ""

    id: photoAddDialog
    width: parent.width
    height: parent.height

    DocumentGalleryModel {
        id: galleryModelReal
        rootType: DocumentGallery.Image
        properties: [ "fileName", "fileSize" ]
        filter: GalleryWildcardFilter {
            property: "fileName";
            value: "*.jpg";
        }
    }

    Component {
         id: delegate
         ProfilePhoto {
            photoUrl: model.fileName
            photoSize: photoGrid.cellWidth
            photoBorder: 2
            photoAspect: Image.PreserveAspectFit
            onClicked: {
                //console.log("PHOTOADD MODEL: " + JSON.stringify(model));
                photoAddDialog.path(checkinID, model.fileName, model.fileSize);
            }
         }
     }

    GridView {
        id: photoGrid
        anchors.fill: parent
        cellWidth: parent.width/3
        cellHeight: cellWidth

        model: galleryModel
        delegate: delegate
     }

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                galleryModel: ""
                target: photoAddDialog
                x: -parent.width
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                galleryModel: galleryModelReal
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

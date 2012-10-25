import Qt 4.7
import QtMobility.gallery 1.1

Rectangle {
    signal uploadPhoto(string photo)

    id: photoAdd
    width: parent.width
    height: parent.height
    state: "hidden"
    color: theme.backgroundMain

    ListModel {
        id: emptyModel
    }

    DocumentGalleryModel {
        id: galleryModel

        autoUpdate: true
        scope: DocumentGallery.Image  //real
        properties: [ "filePath" ]    //real
        //rootType: DocumentGallery.Image //sim
        //properties: [ "fileName" ]      //sim
        filter: GalleryWildcardFilter {
            property: "fileName";
            value: "*.jpg";
        }
        sortProperties: [ "-lastModified" ]
    }

    GridView {
        id: photoGrid
        width: parent.width
        height: parent.height
        cellWidth: Math.min((width-5)/3,height)
        cellHeight: cellWidth
        clip: true
        model: emptyModel
        delegate: photoDelegate
        header: GreenLine {
            height: 30
            text: "Select photo for upload"
        }
    }

    Component {
         id: photoDelegate
         ProfilePhoto {
            photoUrl: model.filePath      //real
            //photoUrl: model.fileName        //sim
            photoSize: photoGrid.cellWidth
            photoSourceSize: photoGrid.cellWidth
            photoBorder: 2
            photoSmooth: false
            photoAspect: Image.PreserveAspectFit
            onClicked: {
                photoAdd.uploadPhoto(photoUrl);
            }
         }
     }

    onStateChanged: {
        if (state == "shown") {
            galleryModel.reload();
            photoGrid.model = galleryModel;
        } else {
            photoGrid.model = emptyModel;
        }
    }

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: photoAdd
                x: -parent.width
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: photoAdd
                x: 0
            }
        }
    ]

    transitions: [
        Transition {
            from: "shown"
            SequentialAnimation {
                PropertyAnimation {
                    target: photoAdd
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
                ScriptAction {
                    script: {
                        photoAdd.visible = false;
                        photoGrid.model = emptyModel;
                    }
                }
            }
        },
        Transition {
            to: "shown"
            SequentialAnimation {
                ScriptAction {
                    script: {
                        photoAdd.visible = true;
                        photoGrid.model = galleryModel;
                    }
                }
                PropertyAnimation {
                    target: photoAdd
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}

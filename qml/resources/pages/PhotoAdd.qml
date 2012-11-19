import Qt 4.7
import QtMobility.gallery 1.1
import "../components"

Rectangle {
    signal uploadPhoto(string photo)

    property variant options: {}

    id: photoAdd
    width: parent.width
    height: parent.height
    color: theme.colors.backgroundMain

    function load() {
        var page = photoAdd;
        page.uploadPhoto.connect(function(photo){
            photoShareDialog.photoUrl = photo;
            photoShareDialog.state = "shown";
        });
        photoShareDialog.options = options;
        photoShareDialog.owner = page;
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
        model: galleryModel
        delegate: photoDelegate
        header: Column {
            width: parent.width
            LineGreen {
                height: 30
                text: "Select photo for upload"
            }
            Column {
                width: parent.width
                Item {
                    width: parent.width
                    height: 20
                }
                ButtonBlue {
                    label: "Create Molo.me!"
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 280
                    onClicked: {
                        waiting.show();
                        molome.getphoto();
                    }
                }
                Item {
                    width: parent.width
                    height: 20
                }
                visible: window.molome_installed && window.molome_present
            }
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
            photoCache: false
            onClicked: {
                photoAdd.uploadPhoto(photoUrl);
            }
         }
     }

    //TODO: reload on "reload" toolbar action
    /*onReload: {
            galleryModel.reload();
    }*/
}

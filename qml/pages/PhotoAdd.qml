import Qt 4.7
import com.nokia.meego 1.0
import QtMobility.gallery 1.1
import "../components"

PageWrapper {
    signal uploadPhoto(string photo)

    property variant options: {}

    id: photoAdd
    width: parent.width
    height: parent.height
    color: mytheme.colors.backgroundMain

    headerText: "Select photo for upload"

    tools: ToolBarLayout{
        ToolIcon{
            platformIconId: "toolbar-back"
            onClicked: stack.pop()
        }

        ToolIcon{
            iconSource: "../pics/molome.png"
            onClicked: {
                //TODO: make Connections {} to molome object
                //waiting_show();
                molome.getphoto();
            }
            visible: configuration.molome_installed && configuration.molome_present
        }

        ToolIcon {
            platformIconId: "toolbar-refresh"
            onClicked: {
                galleryModel.reload();
            }
        }
    }

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

        property bool ready: status === DocumentGalleryModel.Idle || status === DocumentGalleryModel.Finished

        autoUpdate: true
        scope: DocumentGallery.Image  //real
        properties: [ "filePath", "url" ]    //real
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
        anchors.top: pagetop
        width: parent.width
        height: parent.height - y
        cellWidth: Math.min((width-5)/3,height)
        cellHeight: cellWidth
        clip: true
        model: galleryModel.ready ? galleryModel : undefined
        delegate: photoDelegate
    }

    Component {
         id: photoDelegate
         ProfilePhoto {
            photoUrl: url               //real
            //photoUrl: model.fileName        //sim
            photoSize: photoGrid.cellWidth
            photoSourceSize: photoGrid.cellWidth
            photoBorder: 2
            photoSmooth: false
            photoAspect: Image.PreserveAspectFit
            photoCache: false
            onClicked: {
                photoAdd.uploadPhoto(model.filePath);
            }

            //TODO: make textname overlap photo
         }
     }
}

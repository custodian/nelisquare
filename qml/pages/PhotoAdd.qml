import Qt 4.7
import com.nokia.meego 1.0
import QtMobility.gallery 1.1
import "../components"
import "../js/api.js" as Api

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
                waiting_show();
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

    function molomePhoto(state, photoUrl) {
        if (state) {
            uploadPhoto(photoUrl);
        }
        waiting_hide();
        galleryModel.reload();
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

    PhotoShareDialog {
        id: photoShareDialog
        z: 20
        width: parent.width
        state: "hidden"
        onCancel:{
            photoShareDialog.state="hidden";
        }
        onUploadPhoto: {
            photoShareDialog.state="hidden";
            Api.photos.addPhoto(params, options.owner);
            stack.pop();
        }
    }
}

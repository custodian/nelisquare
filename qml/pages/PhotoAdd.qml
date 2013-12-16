import Qt 4.7
import com.nokia.meego 1.0
import QtMobility.gallery 1.1
import "../components"
import "../js/api.js" as Api

PageWrapper {
    signal selectPhoto(string photo)
    signal uploadPhoto(variant params)

    property variant options: {}
    property int maxPhotoSize: options.type === "avatar" ? 100 : 5000

    id: photoAdd
    width: parent.width
    height: parent.height
    color: mytheme.colors.backgroundMain

    headerText: qsTr("Select photo for upload")
    headerIcon: "../icons/icon-header-photos.png"

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
        page.selectPhoto.connect(function(photo){
            stack.push(Qt.resolvedUrl("../pages/PhotoShareDialog.qml"), {"photoUrl": photo, "options": options, "owner":page});
        });
        page.uploadPhoto.connect(function(params) {
            waiting_show();
            Api.photos.addPhoto(params, options.owner,
                function(url) {
                    waiting_hide();
                    //TODO: change to HttpUpload + add comment
                    var result = pictureHelper.upload(url, params.path, params.owner, maxPhotoSize);
                    if (result === true) {
                        //photo selection
                        stack.pop();
                    } else {
                        params.owner.show_error(qsTr("Error uploading photo!<br>Photo size should be less than %1KB").arg(maxPhotoSize));
                        //stack.pop();
                    }
                }
            );
            //sharing dialog
            stack.pop();
        });
    }

    function molomePhoto(state, photoUrl) {
        if (state) {
            selectPhoto(photoUrl);
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
        filter: GalleryFilterUnion {
            filters: [
                GalleryWildcardFilter {
                    property: "fileName";
                    value: "*.jpg";
                },
                GalleryWildcardFilter {
                    property: "fileName";
                    value: "*.jpeg";
                },
                GalleryWildcardFilter {
                    property: "fileName";
                    value: "*.png";
                }
                /*GalleryEqualsFilter {
                    property: "fileName"
                    value: /.+(jpg|jpeg|JPG|JPEG|png|PNG)/
                }*/
            ]
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
            photoUrl: decodeURIComponent(url)               //real
            //photoUrl: model.fileName        //sim
            photoSize: photoGrid.cellWidth
            photoSourceSize: photoGrid.cellWidth
            photoBorder: 2
            photoSmooth: false
            photoAspect: Image.PreserveAspectFit
            photoCache: false
            onClicked: {
                photoAdd.selectPhoto(decodeURIComponent(model.filePath)); //real
                //photoAdd.selectPhoto(model.fileName); //sim
            }

            //TODO: make textname overlap photo
        }
    }
}

import Qt 4.7
import com.nokia.meego 1.0
import QtMobility.gallery 1.1
import "../components"

import "../js/api.js" as Api

PageWrapper {
    signal photo(string photo)
    signal change(string photo)
    signal update()

    property string caption: qsTr("VENUE PHOTOS")

    property alias photosModel: photosModel
    property int currentPhotoIndex: 0

    property int loaded: 0
    property int batchsize: 20
    property alias options: options

    headerText: caption
    headerIcon: "../icons/icon-header-photos.png"

    id: venuePhotos
    width: parent.width
    height: parent.height
    color: mytheme.colors.backgroundMain

    function load() {
        var page = venuePhotos;
        page.photo.connect(function(photo){
            var photopage = stack.push(Qt.resolvedUrl("Photo.qml"),{"photoID":photo});
            photopage.nextPhoto.connect(function() {
                page.loadNextPhoto();
            });
            photopage.prevPhoto.connect(function() {
                page.loadPrevPhoto();
            });
        });
        page.change.connect(function(photo) {
            Api.photos.loadPhoto(stack.currentPage,photo);
        });
    }

    function done() {
        var result = true;
        for(var i=0;i<options.count;i++){
            result &= options.get(i).completed;
        }
        return result;
    }

    function loadNextPhoto() {
        if (currentPhotoIndex >= photosModel.count - 1 ) {
            //console.log("ALREADY LAST PHOTO");
        } else {
            //console.log("LOADING NEXT PHOTO");
            currentPhotoIndex = currentPhotoIndex + 1
            venuePhotos.change(photosModel.get(currentPhotoIndex).objectID);
        }
    }
    function loadPrevPhoto() {
        if (currentPhotoIndex == 0) {
            //console.log("ALREADY FIRST PHOTO");
        } else {
            //console.log("LOADING PREV PHOTO");
            currentPhotoIndex = currentPhotoIndex - 1
            venuePhotos.change(photosModel.get(currentPhotoIndex).objectID);
        }
    }

    ListModel {
        id: options
    }

    ListModel {
        id: photosModel
    }

    GridView {
        id: photoGrid
        anchors.top: pagetop
        width: parent.width
        height: parent.height - y
        cellWidth: Math.min((width-5)/3,height)
        cellHeight: cellWidth
        clip: true
        cacheBuffer: 400
        model: photosModel
        delegate: photoDelegate
    }

    ScrollDecorator{ flickableItem: photoGrid }

    Component {
         id: photoDelegate

         ProfilePhoto {
             photoUrl: model.photoThumb
             photoCache: true
             photoSize: photoGrid.cellWidth
             photoSourceSize: photoGrid.cellWidth
             onClicked: {
                 currentPhotoIndex = index;
                 venuePhotos.photo(model.objectID);
             }

             Component.onCompleted: {
                 if (loaded === (index + 1)){
                     if (!done()) {
                         update();
                     }
                 }
             }
         }         
     }
}

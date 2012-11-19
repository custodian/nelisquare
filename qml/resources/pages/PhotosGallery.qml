import Qt 4.7
import QtMobility.gallery 1.1
import "../components"

import "../js/api-photo.js" as PhotoAPI

Rectangle {
    signal photo(string photo)
    signal change(string photo)
    signal update()

    property string caption: "VENUE PHOTOS"

    property alias photosModel: photosModel
    property int currentPhotoIndex: 0

    property int loaded: 0
    property int batchsize: 20
    property alias options: options

    id: venuePhotos
    width: parent.width
    height: parent.height
    color: theme.colors.backgroundMain

    function load() {
        var page = venuePhotos;
        page.photo.connect(function(photo){
            var photopage = pageStack.push(Qt.resolvedUrl("Photo.qml"),{"photoID":photo});
            photopage.nextPhoto.connect(function() {
                page.loadNextPhoto();
            });
            photopage.prevPhoto.connect(function() {
                page.loadPrevPhoto();
            });
        });
        page.change.connect(function(photo) {
            PhotoAPI.loadPhoto(pageStack.currentPage,photo);
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
        width: parent.width
        height: parent.height
        cellWidth: Math.min((width-5)/3,height)
        cellHeight: cellWidth
        clip: true
        cacheBuffer: 400
        model: photosModel
        delegate: photoDelegate
        header: LineGreen {
            height: 30
            text: caption
        }
    }

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

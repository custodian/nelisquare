import Qt 4.7
import QtMobility.gallery 1.1
import "../components"

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
    state: "hidden"
    color: theme.colors.backgroundMain

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

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: venuePhotos
                x: parent.width
            }
        },
        State {
            name: "hiddenLeft"
            PropertyChanges {
                target: venuePhotos
                x: -parent.width
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: venuePhotos
                x: 0
            }
        }
    ]

    transitions: [
        Transition {
            from: "shown"
            SequentialAnimation {
                PropertyAnimation {
                    target: venuePhotos
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
                PropertyAction {
                    target: venuePhotos
                    properties: "visible"
                    value: false
                }
            }
        },
        Transition {
            to: "shown"
            SequentialAnimation {
                PropertyAction {
                    target: venuePhotos
                    properties: "visible"
                    value: true
                }
                PropertyAnimation {
                    target: venuePhotos
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}

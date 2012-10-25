import Qt 4.7
import QtMobility.gallery 1.1

Rectangle {
    signal photo(string photo)

    property alias photosModel: photosModel

    id: venuePhotos
    width: parent.width
    height: parent.height
    state: "hidden"
    color: theme.backgroundMain

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
        header: GreenLine {
            height: 30
            text: "VENUE PHOTOS"
        }
    }

    Component {
         id: photoDelegate

         ProfilePhoto {
             photoUrl: model.photoThumb
             photoCache: false
             photoSize: photoGrid.cellWidth
             photoSourceSize: photoGrid.cellWidth
             onClicked: {
                 venuePhotos.photo(model.objectID);
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
            }
        },
        Transition {
            to: "shown"
            SequentialAnimation {
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

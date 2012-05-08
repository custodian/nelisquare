import Qt 4.7

Item {
    signal photo(string photo)
    id: photosBox
    width: parent.width

    property string caption: "Photos: "
    property bool showButtons: true
    property int photoSize: photosBox.sizeMini

    property int sizeMini: 150
    property int sizeMidi: 220
    property int sizeMaxi: 300

    property alias photosModel: photosModel

    ListModel {
        id: photosModel
    }

    Column {
        id: photoColumn
        width: parent.width
        onHeightChanged: {
            photosBox.height = height;
        }

        Text {
            id: photoAreaCaption
            width: parent.width
            height: 48
            text: caption
        }

        Flickable {
            id: photoArea
            width: parent.width

            clip: true
            flickableDirection: Flickable.HorizontalFlick
            boundsBehavior: Flickable.StopAtBounds

            pressDelay: 100
            Row {
                onWidthChanged: {
                    photoArea.contentWidth = width;
                }
                onHeightChanged: {
                    photoArea.contentHeight = height;
                    photoArea.height = height + 10;
                }
                spacing: 5
                Repeater {
                    id: photoRepeater
                    width: parent.width
                    model: photosModel
                    delegate: photoDelegate
                }
            }
        }
        Rectangle {
            width: parent.width
            height: 1
            color: "#ccc"
        }
    }

    Row {
        anchors.right: photoColumn.right
        anchors.top: photoColumn.top

        ToolbarButton {
            width: 48
            height: 48
            image: "photo_mini.png"
            selected: photosBox.photoSize == sizeMini;
            onClicked: {
                photosBox.photoSize = sizeMini;
            }
        }
        ToolbarButton {
            width: 48
            height: 48
            image: "photo_midi.png"
            selected: photosBox.photoSize == sizeMidi;
            onClicked: {
                photosBox.photoSize = sizeMidi;
            }
        }
        ToolbarButton {
            width: 48
            height: 48
            image: "photo_maxi.png"
            selected: photosBox.photoSize == sizeMaxi;
            onClicked: {
                photosBox.photoSize = sizeMaxi;
            }
        }
    }

    Component {
        id: photoDelegate

        ProfilePhoto {
            photoUrl: model.photoThumb
            photoSize: photosBox.photoSize
            onClicked: {
                photosBox.photo(model.photoID)
            }
        }
    }
    visible: photosModel.count>0
}

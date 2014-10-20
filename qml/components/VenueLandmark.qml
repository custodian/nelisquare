import QtQuick 1.1
import QtMobility.location 1.2

MapGroup {
    property Coordinate coordinate: Coordinate {}
    property string text: ""

    signal onClicked()

    MapImage {
        id: image
        offset.x: -14
        offset.y: -14
        source: "../pics/pin_venue.png" // TODO better image
        coordinate: parent.coordinate
    }

    MapText {
        font.bold: true
        font.pixelSize: mytheme.fontSizeLarge
        color: "black"
        text: parent.text
        coordinate: parent.coordinate
    }

    MapMouseArea {
        // FIXME
        anchors.fill: image
        onClicked: parent.onClicked()
    }
}

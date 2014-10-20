import QtQuick 1.1
import QtMobility.location 1.2

MapImage {
    property alias label: label

    signal onClicked()

    offset.x: -14
    offset.y: -14
    source: "../pics/pin_venue.png"

    coordinate: Coordinate {}

    MapText {
        id: label

        coordinate: parent.coordinate

        font.bold: true
        font.pixelSize: mytheme.fontSizeLarge
        color: "black"
    }

    MapMouseArea {
        anchors.fill: parent
        onClicked: parent.onClicked()
    }
}

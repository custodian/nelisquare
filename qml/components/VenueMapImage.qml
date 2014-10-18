import QtQuick 1.1
import QtMobility.location 1.2

MapImage {
    signal onClicked()

    offset.x: -24
    offset.y: -24
    source: "../pics/pin_venue.png"

    coordinate: Coordinate {}

    MapMouseArea {
        anchors.fill: parent
        onClicked: parent.onClicked()
    }
}

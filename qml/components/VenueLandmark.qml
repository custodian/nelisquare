import QtQuick 1.1
import QtMobility.location 1.2

MapGroup {
    id: group
    property Coordinate coordinate: Coordinate {}
    property int index: -1
    property bool special: false
    property bool selected: false

//    signal onClicked()

    MapImage {
        id: image
        offset.x: -17
        offset.y: -44
        source: "../pics/lnd/lnd" + (special ? "-special" : "") + (selected ? "-selected" : "") + ".png"
        coordinate: parent.coordinate

//        MapMouseArea {
//            anchors.fill: parent
//            onClicked: group.onClicked()
//        }
    }

    MapText {
        offset.y: -24
        font.bold: true
        font.pixelSize: 18
        color: selected ? (special ? "#ff850b" : "#008ab9") : "#ffffff"
        text: parent.index + 1
        coordinate: parent.coordinate
    }
}

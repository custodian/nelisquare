import QtQuick 1.1
import QtMobility.location 1.2

MapGroup {
    property Coordinate coordinate: Coordinate {}
    property string text: ""
    property bool special: false
    property bool selected: false

    signal onClicked()

    MapImage {
        id: image
        offset.x: -17
        offset.y: -44
        source: "../pics/lnd/lnd" + (special ? "-special" : "") + (selected ? "-selected" : "") + ".png"
        coordinate: parent.coordinate
    }

    MapText {
        offset.y: -24
        font.bold: true
        font.pixelSize: 18
        color: selected ? (special ? "#ff850b" : "#008ab9") : "#ffffff"
        text: parent.text
        coordinate: parent.coordinate
    }

    MapMouseArea {
        // FIXME
        anchors.fill: image
        onClicked: parent.onClicked()
    }
}

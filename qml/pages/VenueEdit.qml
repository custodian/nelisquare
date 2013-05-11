import Qt 4.7
import QtMobility.location 1.2
import com.nokia.meego 1.0
import "../components"

import "../js/api.js" as Api

PageWrapper {
    id: venueEdit
    signal update(variant venue)
    signal updateCompleted(string venue)

    property string venueID: ""
    property alias venueCategories: venueCategories

    property string mapprovider: configuration.mapprovider

    width: parent.width
    height: parent.height

    color: mytheme.colors.backgroundMain

    onMapproviderChanged: {
        mapplugin.name = mapprovider
        map.plugin = mapplugin;
    }

    Plugin {
        id: mapplugin
        name: configuration.mapprovider
    }

    function load() {
        var page = venueEdit;
        page.update.connect(function(params){
            Api.venues.updateVenueInfo(page,params);
        });
        page.updateCompleted.connect(function(venue){
            stack.push(Qt.resolvedUrl("Venue.qml"),{"venueID":venue});
        });
        Api.venues.prepareVenueEdit(page,venueID);
    }

    ListModel{
        id: venueCategories
    }

    SelectionDialog {
        id: selectionvenue
        model: venueCategories
    }

    Flickable{

        id: flickableArea
        anchors.fill: parent
        contentWidth: parent.width

        clip: true
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds
        pressDelay: 100

        Column {
            onHeightChanged: {
                flickableArea.contentHeight = height + y;
            }

            x: 10
            width: parent.width - 20
            spacing: 20

            LineGreen {
                id: editVenueLabel
                height: 40
                width: venueEdit.width
                anchors.horizontalCenter: parent.horizontalCenter
                text: "ENTER DETAILS FOR VENUE"
            }

            Text {
                id: textNameLabel
                text: "NAME"
                color: mytheme.colors.textColorOptions
                font.pixelSize: mytheme.font.sizeToolbar
                font.family: "Nokia Pure" //mytheme.font.name
                font.bold: true

                TextField {
                    id: textVenueName
                    placeholderText: qsTr("Venue name")
                    anchors.left: textNameLabel.right
                    anchors.leftMargin: 20
                    anchors.verticalCenter: textNameLabel.verticalCenter
                    width: parent.parent.width - textNameLabel.width - 20
                }
            }

            LineGreen{
                height: 30
                width: venueEdit.width
                anchors.horizontalCenter: parent.horizontalCenter
                text: "VENUE LOCATION"
            }

            Map {
                id: map
                center: positionSource.position.coordinate
                size.width: parent.width
                zoomLevel: 15
                size.height: 150

                MapImage{
                    id: markerVenue
                    offset.x: -24
                    offset.y: -24
                    coordinate: positionSource.position.coordinate
                    source: "../pics/pin_venue.png"
                }
            }

            LineGreen{
                height: 30
                width: venueEdit.width
                anchors.horizontalCenter: parent.horizontalCenter
                text: "VENUE CATEGORY"
            }

            EventBox {
                userName: "Select category"
                userShout: "Venue category"
            }
            EventBox {
                userShout: "Venue subcategory"
            }

            LineGreen{
                height: 30
                text: "VENUE DESCRIPTION"
            }

            /*TextArea {

            }*/

            ButtonBlue {
                width: parent.width * 0.7
                anchors.horizontalCenter: parent.horizontalCenter
                label: "CREATE VENUE"
            }

            Item {
                width: parent.width
                height: 50
            }
        }
    }
}

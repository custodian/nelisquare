import Qt 4.7
import "../components"

import "../js/api-venue.js" as VenueAPI

Rectangle {
    id: venueEdit
    signal update(variant venue)
    signal updateCompleted(string venue)

    property string venueID: ""
    property alias venueCategories: venueCategories

    width: parent.width
    height: parent.height

    color: theme.colors.backgroundMain

    function load() {
        var page = venueEdit;
        page.update.connect(function(params){
            VenueAPI.updateVenueInfo(page,params);
        });
        page.updateCompleted.connect(function(venue){
            pageStack.push(Qt.resolvedUrl("Venue.qml"),{"venueID":venue});
        });
        VenueAPI.prepareVenueEdit(page,venueID);
    }

    ListModel{
        id: venueCategories
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            hideKeyboard();
        }
    }

    LineGreen {
        id: editVenueLabel
        height: 40
        text: "ENTER DETAILS FOR VENUE"
    }

    Flickable{

        id: flickableArea
        anchors.top: editVenueLabel.bottom
        width: parent.width
        contentWidth: parent.width
        height: venueEdit.height - y

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
            spacing: 10

            Item {
                width: parent.width
                height: 10
            }

            Text {
                id: textNameLabel
                text: "NAME"
                color: theme.colors.textColorOptions
                font.pixelSize: theme.font.sizeToolbar
                font.family: "Nokia Pure" //theme.font.name
                font.bold: true

                LineEdit {
                    text: theme.textEnterVenueName
                    anchors.left: textNameLabel.right
                    anchors.leftMargin: 20
                    anchors.verticalCenter: textNameLabel.verticalCenter
                    width: parent.parent.width - textNameLabel.width - 20
                    onAccepted: {
                        var query = text;
                        if(query===theme.textEnterVenueName) {
                            query = "";
                        }
                        hideKeyboard();
                    }
                }
            }

            LineGreen{
                height: 30
                width: venueEdit.width
                anchors.horizontalCenter: parent.horizontalCenter
                text: "VENUE LOCATION"
            }

            LineGreen{
                height: 30
                width: venueEdit.width
                anchors.horizontalCenter: parent.horizontalCenter
                text: "VENUE CATEGORY"
            }
            //Category icon and type
            EventBox {
                userName: "Main category"
            }
            EventBox {
                userName: "Secondary category"
            }

            LineGreen{
                height: 30
                text: "VENUE DESCRIPTION"
            }

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

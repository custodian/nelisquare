import Qt 4.7
import com.nokia.meego 1.0
import "../components"
import "../js/api-venue.js" as VenueAPI

PageWrapper {
    id: venuesList
    signal checkin(string venueid, string venuename)
    signal clicked(string venueid)
    signal search(string query)
    signal addVenue()

    property alias placesModel: placesModel

    width: parent.width
    height: parent.height
    color: mytheme.colors.backgroundMain

    tools: ToolBarLayout{
        ToolIcon{
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }

        ToolIcon{
            platformIconId: "toolbar-refresh"
            onClicked: searchButton.clicked();
        }

        ToolIcon {
            platformIconId: "toolbar-view-menu"
            onClicked: {
                //TODO: add menu
            }
        }
    }

    function load() {
        var page = venuesList;
        page.checkin.connect(function(venueID, venueName) {
            //TODO: create "Sheet" checkin dialog
            checkinDialog.reset();
            checkinDialog.venueID = venueID;
            checkinDialog.venueName = venueName;
            checkinDialog.state = "shown";

        });
        page.clicked.connect(function(venueid) {
            pageStack.push(Qt.resolvedUrl("Venue.qml"),{"venueID":venueid});
        });
        page.search.connect(function(query) {
            VenueAPI.loadVenues(page, query);
        });
        page.addVenue.connect(function(){
            pageStack.push(Qt.resolvedUrl("VenueEdit.qml"),{"venueID":""});
        });
        search("");
    }

    ListModel {
        id: placesModel
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { }
    }

    Rectangle {
        width: parent.width
        height: 80
        color: mytheme.colors.backgroundBlueDark

        LineEdit {
            id: searchText
            text: mytheme.textSearchVenue
            width: parent.width - 150
            x: 10
            y: 20

            onAccepted: {
                var query = text;
                if(query===mytheme.textSearchVenue) {
                    query = "";
                }
                venuesList.search(query);
            }
        }

        ButtonBlue {
            id: searchButton
            x: parent.width - width - 10
            y: 20
            height: 40
            label: "SEARCH"
            width: 120

            onClicked: {
                // Search
                var query = searchText.text;
                if(query===mytheme.textSearchVenue) {
                    query = "";
                }
                searchText.hideKeyboard();
                venuesList.search(query);
            }
        }
    }

    ListView {
        id: placesView
        y: 80
        width: parent.width
        height: parent.height - y
        model: placesModel
        delegate: venuesListDelegate
        //highlightFollowsCurrentItem: true
        clip: true
        cacheBuffer: 400
        spacing: 5
        header:
            LineGreen {
                height: 30
                text: "PLACES NEAR YOU"
            }

        /* //DBG
        footer: Column {
            width: placesView.width
            Item {
                width: placesView.width
                height: 10
            }
            ButtonBlue {
                width: placesView.width * 0.7
                anchors.horizontalCenter: parent.horizontalCenter
                label: "ADD NEW VENUE"
                onClicked: {
                    venuesList.addVenue();
                }
            }
            Item {
                width: placesView.width
                height: 30
            }
        }*/
    }

    Component {
        id: venuesListDelegate

        EventBox {
            activeWhole: true

            userShout: (model.todoComment)? model.todoComment : model.address
            //userMayor: model.mayor
            venueName: model.name
            venuePhoto: model.photo !== undefined ? model.photo : ""
            createdAt: model.distance + " meters"
            peoplesCount: model.peoplesCount

            Component.onCompleted: {
                userPhoto.photoUrl = model.icon
            }

            onAreaClicked: {
                venuesList.clicked( model.id );
            }

            onAreaPressAndHold: {
                venuesList.checkin( model.id, model.name);
            }
        }
    }
}

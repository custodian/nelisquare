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
                menu.open();
            }
        }
    }

    Menu {
        id: menu
        visualParent: mainWindowPage
        MenuLayout {
            MenuItem {
                text: qsTr("Add new venue")
                onClicked: {
                    venuesList.addVenue();
                }
            }
        }
    }

    function load() {
        var page = venuesList;
        page.checkin.connect(function(venueID, venueName) {
            checkinDialog.reset();
            checkinDialog.venueID = venueID;
            checkinDialog.venueName = venueName;
            checkinDialog.open();
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

        TextField {
            id: searchText
            placeholderText: mytheme.textSearchVenue
            width: parent.width - 180
            x: 10
            y: 20
        }

        ButtonBlue {
            id: searchButton
            x: parent.width - width - 10
            y: 20
            height: searchText.height
            label: "SEARCH"
            width: 150

            onClicked: {
                venuesList.search(searchText.text);
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

    ScrollDecorator{ flickableItem: placesView }

    CheckinDialog {
        id: checkinDialog

        function show_error(msg) {
            venuesList.show_error(msg);
        }
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
            specialsCount: model.specialsCount

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

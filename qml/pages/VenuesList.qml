import Qt 4.7
import QtMobility.location 1.2
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import "../components"

import "../js/api.js" as Api

PageWrapper {
    id: venuesList
    signal checkin(string venueid, string venuename)
    signal clicked(string venueid)
    signal search(string query)
    signal explore()
    signal addVenue()

    property alias placesModel: placesModel

    width: parent.width
    height: parent.height
    color: mytheme.colors.backgroundMain

    headerText: qsTr("NEARBY VENUES")
    headerIcon: "../icons/icon-header-venueslist.png"

    function load() {
        var page = venuesList;
        page.checkin.connect(function(venueID, venueName) {
            stack.push(Qt.resolvedUrl("CheckinDialog.qml"),{ "venueID": venueID, "venueName": venueName});
        });
        page.clicked.connect(function(venueid) {
            stack.push(Qt.resolvedUrl("Venue.qml"),{"venueID":venueid});
        });
        page.search.connect(function(query) {
            if (positionSource.position.latitudeValid) {
                Api.venues.loadVenues(page, query);
            } else {
                page.show_error(qsTr("GPS signal is fuzzy, cannot get your location"));
            }
        });
        page.explore.connect(function() {
            //TODO: explorer mode
            stack.push(Qt.resolvedUrl("Explore.qml"));
        });
        page.addVenue.connect(function(){
            stack.push(Qt.resolvedUrl("VenueAdd.qml"),{"venueID":""});
        });
        updateView();
    }
    function updateView() {
        updateTimer.start();
    }

    Timer{
        id: updateTimer
        interval: 50
        repeat: true
        onTriggered: {
            if (positionSource.position.latitudeValid) {
                updateTimer.stop();
                updateTimer.interval = 50;
                waiting_hide();
                infoBanner.shown = false;
                search("");
            } else {
                updateTimer.interval = 1000;
                if (!infoBanner.shown) {
                    infoBanner.shown = true;
                    infoBanner.show();
                }
                waiting_show();
            }
        }
    }

    ListModel {
        id: placesModel
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { }
    }

    Item {
        id: mapArea
        anchors {
            top: pagetop
            left: parent.left
        }
        height: configuration.isPortrait ? 100 : parent.height
        width: configuration.isPortrait ? parent.width : parent.width * 2/5
        Plugin {
            property string provider: configuration.mapprovider
            onProviderChanged: {
                mapProvider.name = provider;
                map.plugin = mapProvider;
            }
            id: mapProvider
            name : configuration.mapprovider
        }
        Map {
            id: map
            anchors.fill: parent

            zoomLevel: 15

            center: positionSource.position.coordinate
            MapMouseArea {
                onClicked: {
                    venuesList.explore();
                }
            }
            MapImage{
                id: markerUser
                offset.x: -24
                offset.y: -24
                coordinate: positionSource.position.coordinate
                source: "../pics/pin_user.png"
            }
        }
        InfoBanner {
            id: infoBanner
            property bool shown: false
            text: qsTr("Locking GPS, please wait")
            topMargin: 10
        }
    }

    Item {
        id: searchBox
        anchors {
            top: configuration.isPortrait? mapArea.bottom : pagetop
            left: configuration.isPortrait ? parent.left : mapArea.right
            right: parent.right
        }
        height: 70

        TextField {
            id: searchText
            placeholderText: qsTr("Tap to search place...")
            width: parent.width - 180
            x: 10
            y: 10

            Keys.onReturnPressed: {
                searchBox.forceActiveFocus();
                venuesList.search(searchText.text);
            }
        }

        Button {
            id: searchButton
            x: parent.width - width - 10
            y: 10
            height: searchText.height
            text: qsTr("SEARCH")
            width: 150

            onClicked: {
                venuesList.search(searchText.text);
            }
        }
        SectionHeader {
            anchors.bottom: parent.bottom
        }
    }

    ListViewEx {
        id: placesView
        anchors {
            top: searchBox.bottom
            left: configuration.isPortrait ? parent.left : mapArea.right
            right: parent.right
        }
        height: parent.height - y
        model: placesModel
        delegate: venuesListDelegate
        //highlightFollowsCurrentItem: true
        clip: true
        cacheBuffer: 400
        spacing: 5

        onPulledDown: {
            update();
        }

        //Add new venue functionality
        footer: Column {
            width: placesView.width
            Item {
                width: placesView.width
                height: 10
            }
            Button {
                width: placesView.width * 0.7
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("ADD NEW VENUE")
                onClicked: {
                    venuesList.addVenue();
                }
            }
            Item {
                width: placesView.width
                height: 30
            }
        }
    }

    ScrollDecorator{ flickableItem: placesView }

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

import Qt 4.7
import QtMobility.location 1.2
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import "../components"

import "../js/api.js" as Api

PageWrapper {
    id: explore
    signal checkin(string venueid, string venuename)
    signal clicked(string venueid)
    signal search()

    property alias placesModel: placesModel

    width: parent.width
    height: parent.height
    color: mytheme.colors.backgroundMain

    headerText: qsTr("EXPLORE VENUES")
    headerIcon: "../icons/icon-header-venueslist.png"

    // search options
    property string query: ""
    property string section: ""
    property bool specialsOnly: false
    property bool openNow: false
    property bool savedOnly: false
    property bool sortByDistance: false
    property variant price
    property string novelty: ""

    function load() {
        var page = explore;
        page.checkin.connect(function(venueID, venueName) {
            stack.push(Qt.resolvedUrl("CheckinDialog.qml"),{ "venueID": venueID, "venueName": venueName});
        });
        page.clicked.connect(function(venueid) {
            stack.push(Qt.resolvedUrl("Venue.qml"),{"venueID":venueid});
        });
        page.search.connect(function() {
            if (positionSource.position.latitudeValid) {
                var prices = []
                if(price)
                    for(var p = 0; p < price.length; p++)
                        if(price[p])
                            prices.push(p + 1)

                pageStack.pop()
                Api.venues.loadVenuesExplore(page, query, section, formatBoolean(specialsOnly),
                    formatBoolean(openNow), formatBoolean(savedOnly), formatBoolean(sortByDistance),
                    prices.join(','), novelty);
            } else {
                page.show_error(qsTr("GPS signal is fuzzy, cannot get your location"));
            }
        });
        //updateView();
    }
    function updateView() {
        updateTimer.start();
    }

    function formatBoolean(v) {
        return v ? "1" : "0"
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
                search();
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
        height: configuration.isPortrait ? 300 : parent.height
        width: configuration.isPortrait ? parent.width : parent.width * 3/5
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

            zoomLevel: 14.5

            center: positionSource.position.coordinate
            MapMouseArea {
                onClicked: {
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

        Button {
            id: searchButton
            anchors.centerIn: parent
            width: parent.width - 130
            text: qsTr("SEARCH OPTIONS")

            onClicked: {
                stack.push(Qt.resolvedUrl("ExploreOptions.qml"), { "searchAction": explore })
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

        section.property: "group"
        section.criteria: ViewSection.FullString
        section.delegate: SectionHeader {
            text: section
        }

        onPulledDown: {
            updateView();
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
            group: model.group

            Component.onCompleted: {
                userPhoto.photoUrl = model.icon
            }

            onAreaClicked: {
                explore.clicked( model.id );
            }

            onAreaPressAndHold: {
                explore.checkin( model.id, model.name);
            }
        }
    }
}

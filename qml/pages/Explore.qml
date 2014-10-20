import Qt 4.7
import QtMobility.location 1.2
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import QtQuick 1.1
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
    property int price: 0
    property string novelty: ""
    // TODO Must have: radius, near. Optional: friendVisits, time, day, lastVenue

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
                Api.venues.loadVenuesExplore(page, query, section, formatBoolean(specialsOnly),
                    formatBoolean(openNow), formatBoolean(savedOnly), formatBoolean(sortByDistance),
                    getPrices(), novelty);
            } else {
                page.show_error(qsTr("GPS signal is fuzzy, cannot get your location"));
            }
        });
        updateView();
    }
    function updateView() {
        updateTimer.start();
    }
    function formatBoolean(v) {
        return v ? "1" : "0"
    }
    function getPrices() {
        if(price === 0)
            return ''

        var prices = []
        for(var p = 0; p < 4; p++)
            if(price & (1 << p))
                prices.push(p + 1)
        return prices.join(',')
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
                map.center.latitude = positionSource.position.coordinate.latitude;
                map.center.longitude = positionSource.position.coordinate.longitude;
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

    Item {
        id: mapArea
        anchors {
            top: pagetop
            left: parent.left
        }
        height: configuration.isPortrait ? 300 : parent.height
        width: configuration.isPortrait ? parent.width : parent.width * 3/5
        focus: true

        Plugin {
            property string provider: configuration.mapprovider
            onProviderChanged: {
                mapProvider.name = provider;
                map.plugin = mapProvider;
            }
            id: mapProvider
            name : configuration.mapprovider
        }

        PinchArea {
            property double __oldZoom;
            anchors.fill: mapArea;
            function calcZoomDelta(zoom, percent) {
                return zoom + Math.log(percent)/Math.log(2);
            }
            onPinchStarted: {
                __oldZoom = map.zoomLevel;
            }
            onPinchUpdated: {
                map.zoomLevel = calcZoomDelta(__oldZoom, pinch.scale);
            }
            onPinchFinished: {
                map.zoomLevel = calcZoomDelta(__oldZoom, pinch.scale);
            }
            enabled: configuration.platform !== "maemo"
        }

        MouseArea {
            property bool __isPanning: false;
            property int __lastX: -1;
            property int __lastY: -1;
            anchors.fill : mapArea;

            onPressed: {
                __isPanning = true;
                __lastX = mouse.x;
                __lastY = mouse.y;
            }
            onReleased: {
                __isPanning = false;
            }
            onPositionChanged: {
                if (__isPanning) {
                    var dx = mouse.x - __lastX;
                    var dy = mouse.y - __lastY;
                    map.pan(-dx, -dy);
                    __lastX = mouse.x;
                    __lastY = mouse.y;
                }
            }
            onCanceled: {
                __isPanning = false;
            }
        }

        Map {
            id: map
            anchors.fill: parent
            zoomLevel: 14.5
            center: Coordinate {}

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
            text: qsTr("EXPLORE OPTIONS")

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
        highlightFollowsCurrentItem: true
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

            property int index: model.index
            property double lat: model.lat
            property double lng: model.lng
            property VenueLandmark landmark

            Component.onCompleted: {
                userPhoto.photoUrl = model.icon
            }

            onAreaClicked: {
                explore.clicked( model.id );
            }

            onAreaPressAndHold: {
                explore.checkin( model.id, model.name);
            }

            ListView.onAdd: {
                var component = Qt.createComponent('../components/VenueLandmark.qml')
                if (component.status === Component.Ready) {
                    var img = component.createObject(map)
                    img.coordinate.latitude = lat
                    img.coordinate.longitude = lng
                    img.label.text = index + 1
                    img.onClicked.connect(function() { placesView.currentIndex = index })

                    map.addMapObject(img)
                    map.addMapObject(img.label)

                    landmark = img
                }
            }

            ListView.onRemove: {
                map.removeMapObject(landmark.label) // TypeError: Result of expression 'image' [null] is not an object.
                map.removeMapObject(landmark)
            }
        }
    }
}

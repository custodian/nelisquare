import Qt 4.7
import QtQuick 1.1
import QtMobility.location 1.2
import "../components"
import "../js/utils.js" as Utils

Rectangle {
    id: venueMap
    width: parent.width
    height: parent.height
    color: theme.colors.backgroundMain

    property string venueMapLat: "0"
    property string venueMapLng: "0"
    property string venueMapUrl: ""
    property int venueMapZoom: 15

    property string venueName: ""
    property string venueAddress: ""
    property string venueTypeUrl: ""

    property variant userLocation: {}
    property variant route

    property string provider: configuration.mapprovider

    function load() {
        venueMap.updateMap();
    }

    onProviderChanged: {
        mapProvider.name = provider;
        map.plugin = mapProvider;
    }

    property alias venue: venue

    Plugin {
        id: mapProvider
        name : configuration.mapprovider
    }

    onRouteChanged: {
        while(routeLine.path.length>0)
            routeLine.removeCoordinate(routeLine.path[0]);
        route.Directions.Routes[0].Steps
        .forEach(function(step) {
            var coord = Qt.createQmlObject("import QtQuick 1.1; import QtMobility.location 1.1; Coordinate {}",venueMap);
            coord.longitude = step.Point.coordinates[0];
            coord.latitude = step.Point.coordinates[1];
            routeLine.addCoordinate(coord);
        });
        routeLine.visible = true;
        //console.log("NEW ROUTE: " + JSON.stringify(route));
        //console.log("NEW ROUTELINE: " + JSON.stringify(routeLine.path));
    }

    function updateMap() {
        markerVenue.coordinate.latitude = venueMapLat;
        markerVenue.coordinate.longitude = venueMapLng;
        if (userLocation.lng!==undefined) {
            markerUser.coordinate.latitude = userLocation.lat;
            markerUser.coordinate.longitude = userLocation.lng;
        }
    }

    onVenueTypeUrlChanged: {
        venue.userPhoto.photoUrl = venueMap.venueTypeUrl
    }

    EventBox {
        id: venue
        activeWhole: true
        width: parent.width - 20
        anchors.horizontalCenter: parent.horizontalCenter

        userName: venueMap.venueName
        userShout: venueMap.venueAddress
    }

    Item {
        id: fullMap
        width: parent.width
        height: parent.height - venue.height - 100
        anchors.top: venue.bottom
        anchors.topMargin: 10

        Map {
            id: map
            anchors.fill: parent
            zoomLevel: venueMapZoom
            center: Coordinate{
               latitude: venueMapLat
               longitude: venueMapLng
            }

            MapImage{
                id: markerUser
                offset.x: -24
                offset.y: -24
                coordinate: Coordinate{
                }
                source: "../pics/pin_user.png"
            }
            MapImage{
                id: markerVenue
                offset.x: -24
                offset.y: -24
                coordinate: Coordinate{
                }
                source: "../pics/pin_venue.png"
            }
            MapPolyline {
                id: routeLine
                border.color: "blue"
                border.width: 10
                visible: false
            }
        }

        Component.onCompleted: {
            if (configuration.platform !== "maemo") {
               Qt.createQmlObject("import QtQuick 1.1; \
                        PinchArea { \
                            id: pincharea; \
                            property double __oldZoom; \
                            anchors.fill: parent; \
                            function calcZoomDelta(zoom, percent) { \
                                return zoom + Math.log(percent)/Math.log(2); \
                            } \
                            onPinchStarted: { \
                                __oldZoom = venueMapZoom; \
                            } \
                            onPinchUpdated: { \
                                venueMapZoom = calcZoomDelta(__oldZoom, pinch.scale); \
                            } \
                            onPinchFinished: { \
                                venueMapZoom = calcZoomDelta(__oldZoom, pinch.scale); \
                            } \
                    }", fullMap);
            }

            Qt.createQmlObject("import Qt 4.7; \
                MouseArea { \
                  id: mousearea; \
                  property bool __isPanning: false; \
                  property int __lastX: -1; \
                  property int __lastY: -1; \
                  anchors.fill : parent; \
                  onPressed: { \
                     __isPanning = true; \
                     __lastX = mouse.x; \
                     __lastY = mouse.y; \
                  } \
                  onReleased: { \
                     __isPanning = false; \
                  } \
                  onPositionChanged: { \
                     if (__isPanning) { \
                        var dx = mouse.x - __lastX; \
                        var dy = mouse.y - __lastY; \
                        map.pan(-dx, -dy); \
                        __lastX = mouse.x; \
                        __lastY = mouse.y; \
                     } \
                  } \
                  onCanceled: { \
                     __isPanning = false; \
                  } \
                } \
            ", fullMap);
        }
    }

    Item {
        width: parent.width
        anchors.top: fullMap.bottom
        anchors.topMargin: 10

        height: zoomInBtn.height
        ToolbarButton {
            id: zoomInBtn
            anchors.right: parent.right
            anchors.rightMargin: 20
            width: 48
            height: 48
            image: "zoom_in.png"
            onClicked: {
                venueMapZoom++;
                if (venueMapZoom > 18)
                    venueMapZoom = 18;
            }
        }
        ButtonBlue {
            id: routeButton
            width: 200
            anchors.horizontalCenter: parent.horizontalCenter
            label: "GET ROUTE"
            onClicked: {
                userLocation = {
                    "lat": window.positionSource.position.coordinate.latitude,
                    "lng": window.positionSource.position.coordinate.longitude
                };
                var venueLocation = {
                    "lng":venueMapLng,
                    "lat":venueMapLat
                };
                Utils.getRoutePoints(venueMap.userLocation,
                                     venueLocation,
                                     function(data){
                                         //console.log("ROUTE: " + JSON.stringify(data))
                                         venueMap.route = data;
                                         updateMap();
                                     });
            }
        }
        ToolbarButton {
            anchors.left: parent.left
            anchors.leftMargin: 20
            width: 48
            height: 48
            image: "zoom_out.png"
            onClicked: {
                venueMapZoom--;
                if (venueMapZoom < 1)
                    venueMapZoom = 1;
            }
        }
    }
}

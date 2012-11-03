import Qt 4.7
import QtQuick 1.1
import QtMobility.location 1.1
import "../components"
import "../js/utils.js" as Utils

Rectangle {
    id: venueMap
    width: parent.width
    height: parent.height
    state: "hidden"
    color: theme.colors.backgroundMain

    property string venueMapLat: ""
    property string venueMapLng: ""
    property string venueMapUrl: ""
    property int venueMapZoom: 15

    property string venueName: ""
    property string venueAddress: ""
    property string venueTypeUrl: ""

    property variant userLocation
    property variant centerLocation
    property variant route

    property alias venue: venue

    function loadMapImage() {
        Utils.createMapUrl(
            venueMap,
            {
                "lat":venueMapLat,
                "lng":venueMapLng,
                "zoom":venueMapZoom,
                "width":fullImage.width,
                "height":fullImage.height,
            },
            userLocation);
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

    Image {
        id: fullImage
        width: parent.width
        height: parent.height - venue.height - 100
        anchors.top: venue.bottom
        anchors.topMargin: 10
        asynchronous: true
        //cache: false
        fillMode: Image.PreserveAspectFit
        source: venueMap.venueMapUrl
        onProgressChanged: {
            loadProgress.percent = progress*100;
        }

        ProgressBar {
            id: loadProgress
            anchors.centerIn: fullImage
            radiusValue: 5
            height: 16
            width: parent.width*0.8
            visible: (fullImage.status != Image.Ready)
        }

        SwypeArea {
            onSwype: {
                if (type === direction.LEFT || type === direction.UP) {
                    //venueMap.prevPhoto();
                } else if (type === direction.RIGHT || type === direction.DOWN) {
                    //venueMap.nextPhoto();
                }
            }
        }
    }

    Item {
        width: parent.width
        anchors.top: fullImage.bottom
        anchors.topMargin: 10
        //anchors.left: venueMapImage.right
        //anchors.top: venueMapImage.top
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
                else
                    loadMapImage();
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
                loadMapImage();
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
                else
                    loadMapImage();
            }
        }
    }

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: venueMap
                x: parent.width
            }
        },
        State {
            name: "hiddenLeft"
            PropertyChanges {
                target: venueMap
                x: -parent.width
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: venueMap
                x: 0
            }
        }
    ]

    transitions: [
        Transition {
            from: "shown"
            SequentialAnimation {
                PropertyAnimation {
                    target: venueMap
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
                PropertyAction {
                    target: venueMap
                    properties: "visible"
                    value: false
                }
            }
        },
        Transition {
            to: "shown"
            SequentialAnimation {
                PropertyAction {
                    target: venueMap
                    properties: "visible"
                    value: true
                }
                PropertyAnimation {
                    target: venueMap
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}

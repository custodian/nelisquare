import Qt 4.7
import "../js/utils.js" as Utils;

Rectangle {
    id: place
    signal checkin(string venueid, string venuename)
    signal markToDo(string venueid, string venuename)
    signal showAddTip(string venueid, string venuename)
    signal showAddPhoto(string venueid)
    signal user(string user)
    signal photo(string photo)
    signal like(string venueid, bool state)

    width: parent.width
    height: parent.height
    color: theme.backgroundMain
    state: "hidden"

    property string venueID: ""
    property string venueName: ""
    property string venueAddress: ""
    property string venueCity: ""
    property string venueMajor: ""
    property string venueMajorID: ""
    property string venueMajorPhoto: ""
    property string venueHereNow: ""
    property string venueCheckinsCount: ""
    property string venueUsersCount: ""
    property string venueMapLat: ""
    property string venueMapLng: ""
    property string venueMapUrl: ""
    property string venueTypeUrl: ""
    property int venueMapZoom: 15

    property alias tipsModel: tipsModel
    property alias photosBox: photosBox
    property alias usersBox: usersBox
    property alias likeBox: likeBox

    function loadMapImage() {
        place.venueMapUrl = Utils.createMapUrl(venueMapLat,venueMapLng,venueMapZoom);
    }

    onVenueMajorPhotoChanged: {
        venueMayorDetails.userPhoto.photoUrl = place.venueMajorPhoto;
    }

    onVenueTypeUrlChanged: {
        venueNameDetails.userPhoto.photoUrl = place.venueTypeUrl
    }

    ListModel {
        id: tipsModel
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { }
    }

    Column {
        anchors.fill: parent

        Flickable {
            id: flickableArea
            width: parent.width
            contentWidth: parent.width
            height: place.height - y

            clip: true
            flickableDirection: Flickable.VerticalFlick
            boundsBehavior: Flickable.StopAtBounds
            pressDelay: 100

            Column {
                width: parent.width

                onHeightChanged: {
                    flickableArea.contentHeight = height + 10;
                }

                Rectangle {
                    z: 100
                    width: parent.width
                    height: columnCheckin.height + 30
                    color: place.color//theme.toolbarLightColor

                    Column {
                        id: columnCheckin
                        y: 10
                        width: parent.width
                        spacing: 10

                        EventBox {
                            id: venueNameDetails
                            activeWhole: true
                            width: parent.width - 20
                            anchors.horizontalCenter: parent.horizontalCenter

                            userName: place.venueName
                            userShout: place.venueAddress
                        }

                        GreenButton {
                            label: "CHECK-IN HERE!"
                            width: parent.width - 20
                            anchors.horizontalCenter: parent.horizontalCenter

                            onClicked: {
                                place.checkin(place.venueID,place.venueName);
                            }
                        }

                        Row {
                            width: parent.width - 20
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 10

                            BlueButton {
                                label: "ADD TIP"
                                width: parent.width / 3 - parent.spacing
                                onClicked: {
                                    place.showAddTip(place.venueID,place.venueName);
                                }
                            }
                            BlueButton {
                                label: "ADD PHOTO"
                                width: parent.width / 3 - parent.spacing
                                onClicked: {
                                    place.showAddPhoto(place.venueID)
                                }
                            }

                            /*BlueButton {
                                label: "Mark to-do"
                                width: parent.width / 3 - parent.spacing
                                anchors.right: parent.right
                                onClicked: {
                                    place.markToDo(place.venueID,place.venueName);
                                }
                            }*/

                            BlueButton {
                                id: venueMapButton
                                //anchors.right: parent.right
                                width: parent.width / 3 //- parent.spacing
                                label: venueMapBox.visible ? "HIDE MAP" :"SHOW MAP"
                                onClicked: {
                                    venueMapBox.visible = !venueMapBox.visible;
                                    if (venueMapBox.visible) {
                                        loadMapImage();
                                    }
                                }
                                visible: venueMapLat != "" && venueMapLng != ""
                            }
                        }
                    }
                }

                Column {
                    width: parent.width// - 20
                    //x: 10
                    spacing: 10

                    Row {
                        x: 10
                        width: parent.width - 20
                        EventBox {
                            id: venueMayorDetails
                            width: parent.width - venueMapButton.width
                            userName: place.venueMajor.length>0 ? place.venueMajor : "Venue doesn't have mayor yet!"
                            userShout: place.venueMajor.length>0 ? "is the mayor." : "It could be you!"

                            onUserClicked: {
                                place.user(venueMajorID);
                            }
                        }
                    }

                    LikeBox {
                        id: likeBox
                        x: 10
                        width: parent.width - 20

                        onLike: {
                            place.like(place.venueID, state);
                        }
                    }

                    Row {
                        id: venueMapBox
                        x: 10
                        anchors.horizontalCenter: parent.horizontalCenter

                        ProfilePhoto {
                            id: venueMapImage
                            photoSize: 320
                            photoSmooth: false
                            photoUrl: place.venueMapUrl
                        }
                        Item {
                            width: zoomInBtn.width
                            //anchors.left: venueMapImage.right
                            //anchors.top: venueMapImage.top
                            height: venueMapImage.height
                            ToolbarButton {
                                id: zoomInBtn
                                anchors.top: parent.top
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
                            ToolbarButton {
                                anchors.bottom: parent.bottom
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
                        visible: false
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: "#ccc"
                        visible: venueMapBox.visible
                    }

                    PhotosBox {
                        id: photosBox
                        onItemSelected: {
                            place.photo(object);
                        }
                    }

                    PhotosBox {
                        id: usersBox
                        showButtons: false
                        photoSize: 64
                        onItemSelected: {
                            place.user(object)
                        }
                    }

                    GreenLine {
                        height: 30
                        text: "USER TIPS"
                    }

                    Repeater {
                        id: tipRepeater

                        //x: 10
                        width: parent.width //- 20

                        model: tipsModel
                        delegate: tipDelegate
                        visible: tipsModel.count>0
                    }
                }
            }
        }
    }

    Component {
        id: tipDelegate

        EventBox {
            x: 10
            width: tipRepeater.width - 20

            userShout: model.tipText
            createdAt: model.tipAge
            fontSize: 18

            Component.onCompleted: {
                userPhoto.photoUrl = model.userPhoto
                userPhoto.photoSize = 48
                userPhoto.photoBorder = 2
            }
            onUserClicked: {
                place.user(model.userID);
            }
        }
    }

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: place
                x: parent.width
            }
            PropertyChanges {
                target: venueMapImage
                photoUrl: ""
            }
        },
        State {
            name: "hiddenLeft"
            PropertyChanges {
                target: place
                x: -parent.width
            }
            PropertyChanges {
                target: venueMapImage
                photoUrl: ""
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: place
                x: 0
            }
        }
    ]

    transitions: [
        Transition {
            from: "shown"
            SequentialAnimation {
                PropertyAnimation {
                    target: place
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
                PropertyAction {
                    target: place
                    properties: "visible"
                    value: false
                }
            }
        },
        Transition {
            to: "shown"
            SequentialAnimation {
                PropertyAction {
                    target: place
                    properties: "visible"
                    value: true
                }
                PropertyAnimation {
                    target: place
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}

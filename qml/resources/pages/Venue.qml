import Qt 4.7
import "../js/utils.js" as Utils;
import "../components"

Rectangle {
    id: place
    signal checkin(string venueid, string venuename)
    signal markToDo(string venueid, string venuename)
    signal showAddTip(string venueid, string venuename)
    signal showAddPhoto(string venueid)
    signal showMap()
    signal user(string user)
    signal photo(string photo)
    signal like(string venueid, bool state)
    signal tip(string tipid)
    signal tips()

    width: parent.width
    height: parent.height
    color: theme.colors.backgroundMain
    state: "hidden"

    property string venueID: ""
    property string venueName: ""
    property string venueAddress: ""
    property string venueCity: ""
    property string venueMajor: ""
    property string venueMajorID: ""
    property int venueMajorCount: 0
    property string venueMajorPhoto: ""
    property string venueHereNow: ""
    property string venueCheckinsCount: ""
    property string venueUsersCount: ""

    property string venueMapLat: ""
    property string venueMapLng: ""

    property string venueTypeUrl: ""

    property alias tipsModel: tipsModel
    property alias photosBox: photosBox
    property alias usersBox: usersBox
    property alias likeBox: likeBox

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
                    color: place.color

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

                        ButtonGreen {
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

                            ButtonBlue {
                                label: "ADD TIP"
                                width: parent.width / 3 - parent.spacing
                                fontDeltaSize: -2
                                onClicked: {
                                    place.showAddTip(place.venueID,place.venueName);
                                }
                            }
                            ButtonBlue {
                                label: "ADD PHOTO"
                                width: parent.width / 3 - parent.spacing
                                fontDeltaSize: -2
                                onClicked: {
                                    place.showAddPhoto(place.venueID)
                                }
                            }

                            /*ButtonBlue {
                                label: "Mark to-do"
                                width: parent.width / 3 - parent.spacing
                                anchors.right: parent.right
                                onClicked: {
                                    place.markToDo(place.venueID,place.venueName);
                                }
                            }*/

                            ButtonBlue {
                                id: venueMapButton
                                width: parent.width / 3 //- parent.spacing
                                label: "SHOW MAP"
                                fontDeltaSize: -2
                                onClicked: {
                                    place.showMap()
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
                            createdAt: place.venueMajorCount > 0 ? place.venueMajorCount + " checkins" : ""

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

                    PhotosBox {
                        id: usersBox
                        photoSize: 64
                        onItemSelected: {
                            place.user(object)
                        }
                    }

                    PhotosBox {
                        id: photosBox
                        onItemSelected: {
                            place.photo(object);
                        }
                    }

                    LineGreen {
                        height: 30
                        text: "BEST USERS TIPS"
                        visible: tipsModel.count>0
                    }

                    Repeater {
                        id: tipRepeater
                        x: 10
                        width: parent.width - 20
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
            activeWhole: true
            width: tipRepeater.width

            userName: model.userName
            userShout: model.tipText
            createdAt: model.tipAge
            likesCount: model.likesCount
            peoplesCount: model.peoplesCount
            venuePhoto: model.tipPhoto
            venuePhotoSize: 150
            fontSize: 18 //TODO: tie with font settings

            Component.onCompleted: {
                userPhoto.photoUrl = model.userPhoto
                userPhoto.photoSize = 48
                userPhoto.photoBorder = 2
            }
            onAreaClicked: {
                if (tipsModel.count >= 10)
                    place.tips()
                else {
                    place.tip(model.tipID);
                }
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
        },
        State {
            name: "hiddenLeft"
            PropertyChanges {
                target: place
                x: -parent.width
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

import Qt 4.7
import com.nokia.meego 1.0
import "../components"

import "../js/api-venue.js" as VenueAPI
import "../js/utils.js" as Utils;

PageWrapper {
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
    color: mytheme.colors.backgroundMain

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

    tools: ToolBarLayout{
        ToolIcon{
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }

        ToolIcon{
            iconSource: "../icons/icon-m-toolbar-edit"+(theme.inverted?"-white":"")+".png"
            onClicked: {
                place.showAddTip(place.venueID,place.venueName);
            }
        }

        ToolIcon {
            iconSource: "../icons/icon-m-toolbar-image-edit"+(theme.inverted?"-white":"")+".png"
            onClicked: {
                place.showAddPhoto(place.venueID)
            }
        }

        ToolIcon {
            iconSource: "../icons/icon-m-toolbar-showonmap"+(theme.inverted?"-white":"")+".png"
            visible: venueMapLat != "" && venueMapLng != ""
            onClicked: {
                place.showMap()
            }
        }

        ToolIcon {
            platformIconId: "toolbar-view-menu"
            onClicked: {
                //TODO: add menu
                dummyMenu.open();
            }
        }
    }

    function load() {
        var page = place;
        page.checkin.connect(function(venueID, venueName) {
            checkinDialog.reset();
            checkinDialog.venueID = venueID;
            checkinDialog.venueName = venueName;
            checkinDialog.open();
        });
        page.showAddTip.connect(function(venueID, venueName) {
            tipDialog.reset();
            tipDialog.venueName = venueName;
            tipDialog.action = 0;
            tipDialog.state = "shown";
        });
        page.markToDo.connect(function(venueID, venueName) {
            tipDialog.reset();
            tipDialog.venueName = venueName;
            tipDialog.action = 1;
            tipDialog.state = "shown";
        });
        page.user.connect(function(user) {
            pageStack.push(Qt.resolvedUrl("User.qml"),{"userID":user});
        });
        page.tip.connect(function(tip){
            pageStack.push(Qt.resolvedUrl("TipPage.qml"),{"tipID":tip});
        });
        page.tips.connect(function(){
            pageStack.push(Qt.resolvedUrl("TipsList.qml"),{"baseType":"venues","baseID":venueID});
        });
        page.photo.connect(function() {
            var photogallery = pageStack.push(Qt.resolvedUrl("PhotosGallery.qml"));
            photogallery.update.connect(function(){
               VenueAPI.loadVenuePhotos(photogallery,venueID);
            });
            photogallery.caption = "VENUE PHOTOS";
            photogallery.options.append({"offset":0,"completed":false});
            photogallery.options.append({"offset":0,"completed":false});
            photogallery.update();
        });
        page.showMap.connect(function() {
            pageStack.push(Qt.resolvedUrl("VenueMap.qml"),{
                               "venueMapLat": page.venueMapLat,
                               "venueMapLng": page.venueMapLng,
                               "venueName": page.venueName,
                               "venueTypeUrl": page.venueTypeUrl,
                               "venueAddress": page.venueAddress,
                           });
        });
        page.showAddPhoto.connect(function(venueID) {
            pageStack.push(Qt.resolvedUrl("PhotoAdd.qml"),{"options":{
                "type": "venue",
                "id": venueID,
                "owner": page
            }});
        });
        page.like.connect(function(venueID,state) {
            VenueAPI.likeVenue(page,venueID,state);
        });
        VenueAPI.loadVenue(page, venueID);
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

    //TODO: remove to single "Sheet"
    TipDialog {
        id: tipDialog
        z: 20
        width: parent.width
        state: "hidden"
        onCancel: {tipDialog.state = "hidden";}
        onAddTip: {
            if(tipDialog.action==0) {
                //console.log("Tip: " + comment + " on " + tipDialog.venueID);
                VenueAPI.addTip(place, venueID, comment);
            } else {
                //console.log("mark: " + comment + " on " + tipDialog.venueID);
                VenueAPI.markVenueToDo(venueID, comment);
            }
            tipDialog.state = "hidden";
        }
    }

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
                        width: parent.width
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
    ScrollDecorator{ flickableItem: flickableArea }

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
}

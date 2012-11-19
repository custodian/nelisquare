import Qt 4.7
import "../components"

import "../js/api-tip.js" as TipAPI

Rectangle {
    signal like(bool state)
    signal user(string user)
    signal venue(string venueID)
    signal photo(string photoID)
    signal save()
    signal markDone()

    id: tipPage
    width: parent.width
    height: parent.height
    color: theme.colors.backgroundMain

    property string tipID: ""

    property alias ownerVenue: ownerVenue
    property alias ownerUser: ownerUser
    property alias likeBox: likeBox
    property alias tipPhoto: tipPhoto
    property string tipPhotoID: ""

    function load() {
        var page = tipPage;
        page.like.connect(function(state){
            TipAPI.likeTip(page, tipID, state)
        });
        page.user.connect(function(user){
            pageStack.push(Qt.resolvedUrl("User.qml"),{"userID":user});
        });
        page.venue.connect(function(venue){
            pageStack.push(Qt.resolvedUrl("Venue.qml"),{"venueID":venue});
        });
        page.photo.connect(function(photo){
            pageStack.push(Qt.resolvedUrl("Photo.qml"),{"photoID":photo});
        });
        page.save.connect(function(){
            TipAPI.showError("Lists not implemented yet!");
        });
        page.markDone.connect(function(){
            TipAPI.showError("Lists not implemented yet!");
        });
        TipAPI.loadTipInfo(page,tipID);
    }

    Flickable{
        id: flickableArea
        width: parent.width
        height: parent.height
        contentWidth: parent.width

        clip: true
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds
        pressDelay: 100

        Column {
            x: 10
            y: 20
            width: parent.width - 20
            spacing: 20

            onHeightChanged: {
                flickableArea.contentHeight = y + height + spacing;
            }

            EventBox {
                id: ownerVenue
                activeWhole: true

                onAreaClicked: {
                    tipPage.venue(venueID);
                }
            }

            EventBox {
                id: ownerUser
                activeWhole: true

                onAreaClicked: {
                    tipPage.user(userID);
                }
            }

            LikeBox {
                id: likeBox
                onLike: {
                    tipPage.like(state);
                }
            }

            ProfilePhoto{
                id: tipPhoto
                photoWidth: parent.width
                photoHeight: 300
                visible: tipPhotoID!=""

                onClicked: {
                    tipPage.photo(tipPhotoID);
                }
            }

            Row {
                width: parent.width
                spacing: 10

                ButtonBlue {
                    label: "Save tip"
                    width: (parent.width - 10)/2
                    onClicked: {
                        tipPage.save();
                    }
                }

                ButtonBlue {
                    label: "Mark as done"
                    width: (parent.width - 10)/2
                    onClicked: {
                        tipPage.markDone();
                    }
                }
            }

        }
    }
}

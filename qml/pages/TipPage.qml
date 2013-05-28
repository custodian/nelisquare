import Qt 4.7
import com.nokia.meego 1.0
import "../components"

import "../js/api.js" as Api

PageWrapper {
    signal like(bool state)
    signal showlikes()
    signal user(string user)
    signal venue(string venueID)
    signal photo(string photoID)
    signal save()
    signal markDone()

    id: tipPage
    width: parent.width
    height: parent.height
    color: mytheme.colors.backgroundMain

    headerText: "Usefull tip"
    headerIcon: "../icons/icon-header-tipslist.png"

    property string tipID: ""

    property alias ownerVenue: ownerVenue
    property alias ownerUser: ownerUser
    property alias likeBox: likeBox
    property alias tipPhoto: tipPhoto
    property string tipPhotoID: ""

    tools: ToolBarLayout{
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: stack.pop()
        }

        ToolIcon {
            iconSource: "../icons/icon-m-toolbar-like"+(likeBox.mylike? "-red":(theme.inverted?"-white":""))+".png"
            onClicked: {
                likeBox.toggleLike();
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
        var page = tipPage;
        page.like.connect(function(state){
            Api.tips.likeTip(page, tipID, state)
        });
        page.showlikes.connect(function() {
            stack.push(Qt.resolvedUrl("UsersList.qml"),{"objType":"tip","objID":tipID, "limit":likeBox.likes});
        })
        page.user.connect(function(user){
            stack.push(Qt.resolvedUrl("User.qml"),{"userID":user});
        });
        page.venue.connect(function(venue){
            stack.push(Qt.resolvedUrl("Venue.qml"),{"venueID":venue});
        });
        page.photo.connect(function(photo){
            stack.push(Qt.resolvedUrl("Photo.qml"),{"photoID":photo});
        });
        page.save.connect(function(){
            tipPage.show_error("Lists not implemented yet!");
        });
        page.markDone.connect(function(){
            tipPage.show_error("Lists not implemented yet!");
        });
        Api.tips.loadTipInfo(page,tipID);
    }

    Flickable{
        id: flickableArea
        anchors.top: pagetop
        width: parent.width
        height: parent.height - y
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

                onShowlikes: {
                    tipPage.showlikes();
                }

                onLike: {
                    tipPage.like(state);
                }
            }

            SectionHeader {
                text: "TIP PHOTO"
                visible: tipPhotoID!=""
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

            SectionHeader { }

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
    ScrollDecorator{ flickableItem: flickableArea }
}

import Qt 4.7
import com.nokia.meego 1.0
import "../components"

import "../js/api.js" as Api

PageWrapper {
    signal like(string checkin, bool state)
    signal showlikes()
    signal venue(string venue)
    signal user(string user)
    signal photo(string photo)
    signal showAddComment(string checkin)
    signal deleteComment(string checkin, string commentID)
    signal showAddPhoto(string checkin)
    id: checkin

    headerText: qsTr("CHECK-IN DETAILS")
    headerIcon: "../icons/icon-header-checkin.png"

    property string checkinID: ""
    property variant checkinCache: undefined
    property variant specials: undefined
    onSpecialsChanged: {
        if (specials === undefined) return;
        specials.items.forEach(function(special) {
            if (!special.unlocked) return;
            specialsList.specialsModel.append({
                  "specialName": special.title,
                  "specialState": special.unlocked,
                  "specialText": special.message,
                  "specialIcon": special.icon,
                  "likesCount": special.likes.count,
            });
        });
    }

    property alias scoreTotal: scoreTotal.text
    property alias owner: checkinOwner

    property alias likeBox: likeBox

    property alias scoresModel: scoresModel
    property alias badgesModel: badgesModel
    property alias commentsModel: commentsModel
    property alias photosBox: photosBox

    tools: ToolBarLayout{
        ToolIcon{
            platformIconId: "toolbar-back"
            onClicked: stack.pop()
        }

        ToolIcon {
            iconSource: "../icons/icon-m-toolbar-like"+(likeBox.mylike? "-red":(theme.inverted?"-white":""))+".png"
            onClicked: {
                likeBox.toggleLike();
            }
        }

        ToolIcon{
            iconSource: "../icons/icon-m-toolbar-edit"+(theme.inverted?"-white":"")+".png"
            onClicked: {
                checkin.showAddComment(checkin.checkinID);
            }
        }

        ToolIcon {
            iconSource: "../icons/icon-m-toolbar-image-edit"+(theme.inverted?"-white":"")+".png"
            visible: checkin.owner.eventOwner === "self"
            onClicked: {
                checkin.showAddPhoto(checkin.checkinID)
            }
        }

        ToolIcon {
            platformIconId: "toolbar-view-menu"
            onClicked: {
                pageMenu.open();
            }
        }
    }

    function load() {
        var page = checkin;
        page.venue.connect(function(venue){
            stack.push(Qt.resolvedUrl("Venue.qml"),{"venueID":venue});
        });
        page.like.connect(function(checkin, state) {
            Api.checkin.likeCheckin(page,checkin,state);
        });
        page.showlikes.connect(function() {
            stack.push(Qt.resolvedUrl("UsersList.qml"),{"objType":"checkin","objID":checkinID, "limit":likeBox.likes});
        })
        page.user.connect(function(user){
            stack.push(Qt.resolvedUrl("User.qml"),{"userID":user});
        });
        page.photo.connect(function(photo){
            stack.push(Qt.resolvedUrl("Photo.qml"),{"photoID":photo});
        });
        page.showAddComment.connect(function(checkin){
            //TODO: add comment dialog "Sheet"
            commentDialog.reset();
            commentDialog.state = "shown";
        });
        page.deleteComment.connect(function(checkin, comment){
            Api.checkin.deleteComment(page,checkin,comment);
        });
        page.showAddPhoto.connect(function(checkin){
            stack.push(Qt.resolvedUrl("PhotoAdd.qml"),{"options":{
                "type": "checkin",
                "id": checkin,
                "owner": page
            }});
        });
        Api.checkin.loadCheckin(page, checkinID);
    }

    onCheckinCacheChanged: {
        if (checkinCache !== undefined ) {
            //owner.userID =
            owner.userName = checkinCache.userName
            owner.createdAt = checkinCache.createdAt
            owner.userPhoto.photoUrl = checkinCache.photo
            //owner.venueID =
            owner.venueName = checkinCache.venueName
            //owner.venueAddress =
            //owner.venueCity =
            //owner.eventOwner =
            owner.userShout = checkinCache.shout
        }
    }

    ListModel {
        id: scoresModel
    }

    ListModel {
        id: badgesModel
    }

    ListModel {
        id: commentsModel
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
        }
    }

    //TODO: remove to single "Sheet"
    CommentDialog {
        id: commentDialog
        z: 20
        width: parent.width
        state: "hidden"

        onCancel: { commentDialog.state = "hidden"; }
        onShout: {
            //console.log("COMMENT FOR: " + checkinID + " VALUE: " + comment);
            Api.checkin.addComment(checkin, checkinID, comment);
            commentDialog.state = "hidden";
        }
    }

    Flickable {
        id: flickableArea
        anchors.top: pagetop
        width: parent.width
        contentWidth: parent.width
        height: checkin.height - y

        //DBG clip: true
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds
        pressDelay: 100

        Rectangle {
            id: scoreBackground
            y: scoreHolder.y - columnView.spacing
            width: parent.width
            height: scoreHolder.height + 2 * columnView.spacing
            gradient: mytheme.gradientDarkBlue
        }

        Column {
            onHeightChanged: {
                flickableArea.contentHeight = height;
            }

            id: columnView
            x: 10
            width: parent.width - 20
            spacing: 10

            EventBox {
                id: checkinOwner
                width: parent.width
                showRemoveButton: false
                showSeparator: false

                onUserClicked: {
                    checkin.user(checkin.owner.userID);
                }
                onAreaClicked: {
                    checkin.venue(checkin.owner.venueID);
                }
            }

            Column {
                id: scoreHolder
                width: parent.width

                Row {
                    id: scoreCaption
                    x: 10
                    width: parent.width - 20
                    spacing: 10
                    Text {
                        width: parent.width * 0.90
                        text: qsTr("TOTAL POINTS")
                        color: mytheme.colors.textPoints
                        font.pixelSize: mytheme.font.sizeDefault
                    }
                    Text {
                        id: scoreTotal
                        text: "--"
                        color: mytheme.colors.textPoints
                        font.pixelSize: mytheme.font.sizeDefault
                    }
                }

                Repeater {
                    id: scoreRepeater
                    width: parent.width
                    model: scoresModel
                    delegate: scoreDelegate
                    visible: scoresModel.count>0
                }
            }

            SpecialsList {
                id: specialsList
            }

            LikeBox {
                id: likeBox

                onShowlikes: {
                    checkin.showlikes();
                }

                onLike: {
                    checkin.like(checkin.checkinID,state);
                }
            }

            SectionHeader {
                text: qsTr("EARNED BADGES")
                visible: badgesModel.count>0
            }

            Repeater {
                id: badgeRepeater
                width: parent.width
                model: badgesModel
                delegate: badgeDelegate
                visible: badgesModel.count>0
            }

            PhotosBox {
                id: photosBox
                width: checkin.width
                anchors.horizontalCenter: parent.horizontalCenter
                onItemSelected: {
                    checkin.photo(object);
                }
            }

            SectionHeader {
                text: qsTr("COMMENTS")
                visible: commentsModel.count>0
            }

            Repeater {
                id: commentRepeater
                width: parent.width
                model: commentsModel
                delegate: commentDelegate
                visible: commentsModel.count>0
            }

            Item {
                width: parent.width
                height: parent.spacing
            }
        }
    }

    ScrollDecorator{ flickableItem: flickableArea }

    Component {
        id: commentDelegate

        EventBox {
            width: commentRepeater.width
            userName: model.user
            userShout: model.shout
            createdAt: model.createdAt
            eventOwner: model.owner

            Component.onCompleted: {
                userPhoto.photoUrl = model.photo
            }

            onUserClicked: {
                checkin.user(model.userID);
            }
            onDeleteEvent: {
                checkin.deleteComment(checkin.checkinID, model.commentID);
            }
        }

    }

    Component {
        id: scoreDelegate

        Row {
            x: 10
            width: scoreRepeater.width - 20
            spacing: 10
            CacheImage {
                sourceUncached: scoreImage
                smooth: true
                width: 24
                height: 24
            }
            Text {
                width: parent.width * 0.8
                wrapMode: Text.Wrap
                text: scoreMessage
                color: mytheme.colors.textPoints
                font.pixelSize: mytheme.font.sizeSigns
            }
            Text {
                wrapMode: Text.NoWrap
                text: "+"+scorePoints
                color: mytheme.colors.textPoints
                font.pixelSize: mytheme.font.sizeSigns
            }
        }
    }

    Component {
        id: badgeDelegate

        Row {
            width: badgeRepeater.width
            Column {
                width: badgeRepeater.width - 105
                Text {
                    width: badgeRepeater.width * 0.95
                    text: badgeTitle
                    font.pixelSize: 24
                    color: mytheme.colors.textColorOptions
                }
                Text {
                    width: parent.width * 0.8
                    wrapMode: Text.Wrap
                    text: badgeMessage
                    color: mytheme.colors.textColorShout
                    font.pixelSize: 18
                }
            }
            Image {
                source: badgeImage
                smooth: true
                width: 100
                height: 100
            }
        }
    }
}

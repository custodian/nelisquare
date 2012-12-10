import Qt 4.7
import com.nokia.meego 1.0
import "../components"

import "../js/api-checkin.js" as CheckinAPI

PageWrapper {
    signal like(string checkin, bool state)
    signal venue(string venue)
    signal user(string user)
    signal photo(string photo)
    signal showAddComment(string checkin)
    signal deleteComment(string checkin, string commentID)
    signal showAddPhoto(string checkin)
    id: checkin

    width: parent.width
    height: parent.height
    color: mytheme.colors.backgroundMain

    property string checkinID: ""

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
            onClicked: pageStack.pop()
        }

        ToolIcon{
            platformIconId: "toolbar-edit"
            onClicked: {
                checkin.showAddComment(checkin.checkinID);
            }
        }

        ToolIcon {
            platformIconId: "toolbar-image-edit"
            visible: checkin.owner.eventOwner === "self"
            onClicked: {
                checkin.showAddPhoto(checkin.checkinID)
            }
        }

        ToolIcon {
            platformIconId: "toolbar-view-menu"
            onClicked: {
                //TODO: add menu
            }
        }
    }

    function load() {
        var page = checkin;
        page.venue.connect(function(venue){
            pageStack.push(Qt.resolvedUrl("Venue.qml"),{"venueID":venue});
        });
        page.like.connect(function(checkin, state) {
            CheckinAPI.likeCheckin(page,checkin,state);
        });
        page.user.connect(function(user){
            pageStack.push(Qt.resolvedUrl("User.qml"),{"userID":user});
        });
        page.photo.connect(function(photo){
            pageStack.push(Qt.resolvedUrl("Photo.qml"),{"photoID":photo});
        });
        page.showAddComment.connect(function(checkin){
            //TODO: add comment dialog "Sheet"
            commentDialog.reset();
            commentDialog.state = "shown";
        });
        page.deleteComment.connect(function(checkin, comment){
            CheckinAPI.deleteComment(page,checkin,comment);
        });
        page.showAddPhoto.connect(function(checkin){
            pageStack.push(Qt.resolvedUrl("PhotoAdd.qml"),{"options":{
                "type": "checkin",
                "id": checkin,
                "owner": page
            }});
        });
        CheckinAPI.loadCheckin(page, checkinID);
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
            CheckinAPI.addComment(checkin, checkinID, comment);
            commentDialog.state = "hidden";
        }
    }

    Flickable {
        id: flickableArea
        width: parent.width
        contentWidth: parent.width
        height: checkin.height - y

        clip: true
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
                        text: "TOTAL POINTS"
                        color: mytheme.colors.textPoints
                        font.pixelSize: mytheme.font.sizeDefault
                    }
                    Text {
                        id: scoreTotal
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

            LikeBox {
                id: likeBox

                onLike: {
                    checkin.like(checkin.checkinID,state);
                }
            }

            LineGreen {
                text: "Earned badges"
                height: 30
                width: checkin.width
                anchors.horizontalCenter: parent.horizontalCenter
                size: mytheme.font.sizeDefault
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

            LineGreen {
                text: "Comments"
                width: checkin.width
                anchors.horizontalCenter: parent.horizontalCenter
                height: 30
                size: mytheme.font.sizeDefault
                visible: commentsModel.count>0
            }

            Repeater {
                id: commentRepeater
                width: parent.width
                model: commentsModel
                delegate: commentDelegate
                visible: commentsModel.count>0
            }

            /*Row {
                width:parent.width
                spacing: 10

                ButtonBlue {
                    id: btnAddPhoto
                    label: "Add photo"
                    width: 150

                    onClicked: {
                        checkin.showAddPhoto(checkin.checkinID)
                    }
                    visible: checkin.owner.eventOwner == "self"
                }

                ButtonBlue{
                    label: "Add comment"
                    width: parent.width - (btnAddPhoto.visible?btnAddPhoto.width:0) - parent.spacing
                    onClicked: {
                        checkin.showAddComment(checkin.checkinID);
                    }
                }
            }*/

            Item {
                width: parent.width
                height: parent.spacing
            }
        }
    }

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
            Image {
                source: cache.get(scoreImage)
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

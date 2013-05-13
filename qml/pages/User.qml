import Qt 4.7
import com.nokia.meego 1.0
import "../components"

import "../js/api.js" as Api

PageWrapper {
    signal openLeaderboard()
    signal user(string user)
    signal venue(string venue);

    signal addFriend(string user)
    signal removeFriend(string user)
    signal approveFriend(string user)
    signal denyFriend(string user)

    signal badges(string user)
    signal checkins(string user)
    signal mayorships(string user)
    signal friends(string user)
    signal photos(string user)
    signal tips(string user)

    id: details
    width: parent.width
    height: parent.height
    color: mytheme.colors.backgroundMain

    property string userID: ""
    property string userName: ""
    property string userPhoto: ""
    property string userPhotoLarge: ""

    property string userContactPhone: ""
    property string userContactEmail: ""
    property string userContactTwitter: ""
    property string userContactFacebook: ""

    property int userBadgesCount: 0
    property int userMayorshipsCount: 0
    property int userCheckinsCount: 0
    property int userFriendsCount: 0
    property int userPhotosCount: 0
    property int userTipsCount: 0

    property string userRelationship: "undefined"

    property int userLeadersboardRank: 0

    property int scoreRecent: 0
    property int scoreMax: 0

    property string lastVenue: ""
    property string lastVenueID: ""
    property string lastTime: ""

    property alias boardModel: boardModel

    headerText: "USER DETAILS"

    /*tools: ToolBarLayout{
        ToolIcon{
            platformIconId: "toolbar-back"
            onClicked: stack.pop()
        }

        ToolIcon {
            platformIconId: "toolbar-view-menu"
            onClicked: {
                //TODO: add menu
                dummyMenu.open();
            }
        }
    }*/

    function load() {
        var page = details;
        page.addFriend.connect(function(user){
            Api.users.addFriend(page,user);
            page.userRelationship = "updated";
        });
        page.removeFriend.connect(function(user){
            Api.users.removeFriend(page,user);
            page.userRelationship = "updated";
        });
        page.approveFriend.connect(function(user){
            Api.users.approveFriend(page,user);
            page.userRelationship = "updated";
        });
        page.denyFriend.connect(function(user){
            Api.users.denyFriend(page,user);
            page.userRelationship = "updated";
        });
        page.user.connect(function(user){
            stack.push(Qt.resolvedUrl("User.qml"),{"userID":user});
        });
        page.venue.connect(function(venue){
            stack.push(Qt.resolvedUrl("Venue.qml"),{"venueID":venue});
        });
        page.openLeaderboard.connect(function(){
            stack.push(Qt.resolvedUrl("LeaderBoard.qml"));
        });
        page.badges.connect(function(user){
            stack.push(Qt.resolvedUrl("Badges.qml"),{"userID":user});
        });
        page.mayorships.connect(function(user){
            stack.push(Qt.resolvedUrl("Mayorships.qml"),{"userID":user});
        });
        page.checkins.connect(function(user){
            stack.push(Qt.resolvedUrl("CheckinHistory.qml"),{"userID":user});
        });
        page.friends.connect(function(user) {
            stack.push(Qt.resolvedUrl("UsersList.qml"),{"userID":user});
        });
        page.photos.connect(function(user) {
            var photogallery = stack.push(Qt.resolvedUrl("PhotosGallery.qml"));
            photogallery.update.connect(function(){
               Api.users.loadUserPhotos(photogallery,user);
            });
            photogallery.caption = "USER PHOTOS";
            photogallery.options.append({"offset":0,"completed":false});
            photogallery.update();
        });
        page.tips.connect(function(user) {
            stack.push(Qt.resolvedUrl("TipsList.qml"),{"baseType":"user","baseID":user});
        });
        Api.users.loadUser(page,userID);
    }

    Component.onCompleted: {
        checkinOwner.userPhoto.photoSize = 200;
    }

    onUserPhotoChanged: {
        checkinOwner.userPhoto.photoSize = 200;
        checkinOwner.userPhoto.photoUrl = details.userPhoto;
    }

    function switchUserPhoto() {
        if (checkinOwner.userPhoto.photoSize == checkinOwner.width) {
            checkinOwner.userPhoto.photoSize = 200;
            checkinOwner.userPhoto.photoUrl = details.userPhoto;
            checkinOwner.showText = true;
            //socialRow.visible = true;
        } else {
            checkinOwner.userPhoto.photoSize = checkinOwner.width;
            checkinOwner.userPhoto.photoUrl = details.userPhotoLarge;
            checkinOwner.showText = false;
            //socialRow.visible = false;
        }
    }

    ListModel {
        id: boardModel
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { }
    }

    Flickable{
        id: flickableArea
        anchors.top: pagetop
        width: parent.width
        contentWidth: parent.width
        height: details.height - y

        clip: true
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds
        pressDelay: 100

        Column {
            onHeightChanged: {
                flickableArea.contentHeight = height + y + spacing;
            }

            width: parent.width - 20
            y: 10
            x: 10
            spacing: 10

            EventBox {
                id: checkinOwner
                width: parent.width

                userName: details.userName
                userShout: "@ " + details.lastVenue
                createdAt: details.lastTime

                onUserClicked: {
                    switchUserPhoto();
                }
                onAreaClicked: {
                    if (lastVenueID !== "")
                        details.venue(lastVenueID);
                }

                Row {
                    id: socialRow
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 10
                    anchors.right: parent.right
                    spacing: 10

                    Image {
                        width: 48
                        height: 48
                        smooth: true
                        source: "../pics/phone.png"

                        MouseArea {
                            anchors. fill: parent
                            onClicked: {
                                Qt.openUrlExternally("tel:" + userContactPhone);
                            }
                        }
                        visible: userContactPhone !== ""
                    }
                    Image {
                        width: 48
                        height: 48
                        smooth: true
                        source: "../pics/email.png"

                        MouseArea {
                            anchors. fill: parent
                            onClicked: {
                                Qt.openUrlExternally("mailto:" + userContactEmail + "?subject=Ping from Foursquare");
                            }
                        }
                        visible: userContactEmail !== ""
                    }
                    Image {
                        width: 48
                        height: 48
                        smooth: true
                        source: "../pics/twitter.png"

                        MouseArea {
                            anchors. fill: parent
                            onClicked: {
                                Qt.openUrlExternally("https://twitter.com/" + userContactTwitter);
                            }
                        }
                        visible: userContactTwitter !== ""
                    }
                    Image {
                        width: 48
                        height: 48
                        smooth: true
                        source: "../pics/facebook.png"

                        MouseArea {
                            anchors. fill: parent
                            onClicked: {
                                Qt.openUrlExternally("https://facebook.com/" + userContactFacebook);
                            }
                        }
                        visible: userContactFacebook !== ""
                    }
                }
            }

            ButtonGreen {
                anchors.horizontalCenter: parent.horizontalCenter
                label: "Add Friend"
                width: parent.width - 130
                onClicked: {
                    details.addFriend(userID);
                }
                visible: userRelationship == ""
            }

            Row {
                width: parent.width
                spacing: 50
                ButtonBlue {
                    label: "Approve Friend"
                    width: parent.width * 0.6
                    onClicked: {
                        details.approveFriend(userID);
                    }
                }
                ButtonGray {
                    label: "Deny"
                    width: parent.width * 0.3
                    onClicked: {
                        details.denyFriend(userID);
                    }
                }
                visible: userRelationship == "pendingMe"
            }

            ButtonGray {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 130
                label: "Remove Friend"
                onClicked: {
                    details.removeFriend(userID);
                }
                visible: (userRelationship == "friend" || userRelationship == "pendingThem")
            }

            //scores title
            Item {
                width: parent.width
                height: children[0].height
                Text {
                    id: lblScoresText
                    text: "<b>SCORES</b> (LAST 7 DAYS)"
                    font.pixelSize: mytheme.font.sizeHelp
                    color: mytheme.colors.textColorOptions
                }
                Text {
                    text: "BEST SCORE"
                    anchors.right: parent.right
                    font.pixelSize: mytheme.font.sizeHelp
                    font.bold: true
                    color: mytheme.colors.textColorOptions
                }
            }
            //scores value
            Item {
                width: parent.width
                height: children[0].height

                ProgressBar2 {
                    width: parent.width * 0.85
                    value: scoreRecent
                    minimumValue: 0
                    maximumValue: scoreMax
                    showPercent: true
                }
                Text {
                    text: scoreMax
                    anchors.right: parent.right
                    color: mytheme.colors.textColorOptions
                    font.bold: true
                    font.pixelSize: mytheme.font.sizeHelp
                }
            }

            Item {
                width: parent.width
                height: 230

                Rectangle {
                    id: badgesCount
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    anchors.right: checkinsCount.left
                    anchors.rightMargin: 10

                    width: (parent.width - 40) / 3
                    height: 100
                    color: mytheme.colors.backgroundSand
                    smooth: true
                    radius: 5

                    CacheImage {
                        y: 10                        
                        width: 64
                        height: 64
                        sourceUncached: "https://playfoursquare.s3.amazonaws.com/badge/114/newbie.png"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: parent.height - height - 2
                        color: mytheme.colors.textColorProfile
                        font.pixelSize: 20
                        text: details.userBadgesCount + " " + "Badges"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            details.badges(userID);
                        }
                    }
                }

                Rectangle {
                    id: checkinsCount
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: (parent.width - 40) / 3
                    height: 100
                    color: mytheme.colors.backgroundSand
                    smooth: true
                    radius: 5

                    CacheImage {
                        y: 10
                        width: 64
                        height: 64
                        sourceUncached: "https://playfoursquare.s3.amazonaws.com/badge/114/bender.png"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: parent.height - height - 2
                        color: mytheme.colors.textColorProfile
                        font.pixelSize: 20
                        text: details.userCheckinsCount + " " + "Checkins"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            details.checkins(userID);
                        }
                    }
                }

                Rectangle {
                    id: mayorCount
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    anchors.left: checkinsCount.right
                    anchors.leftMargin: 10
                    width: (parent.width - 40) / 3
                    height: 100
                    color: mytheme.colors.backgroundSand
                    smooth: true
                    radius: 5

                    CacheImage {
                        y: 10
                        width: 64
                        height: 64
                        sourceUncached: "https://playfoursquare.s3.amazonaws.com/badge/114/supermayor.png"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: parent.height - height - 2
                        color: mytheme.colors.textColorProfile
                        font.pixelSize: 20
                        text: details.userMayorshipsCount + " " + "Mayorships"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            details.mayorships(userID);
                        }
                    }
                }

                Rectangle {
                    id: friendsCount
                    anchors.top: checkinsCount.bottom
                    anchors.topMargin: 10
                    anchors.right: checkinsCount.left
                    anchors.rightMargin: 10
                    width: (parent.width - 40) / 3
                    height: 100
                    color: mytheme.colors.backgroundSand
                    smooth: true
                    radius: 5

                    CacheImage {
                        y: 10
                        width: 64
                        height: 64
                        sourceUncached: "https://playfoursquare.s3.amazonaws.com/badge/114/entourage.png"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: parent.height - height - 2
                        color: mytheme.colors.textColorProfile
                        font.pixelSize: 20
                        text: details.userFriendsCount + " " + "Friends"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            details.friends(userID);
                        }
                    }
                }

                Rectangle {
                    id: photosCount
                    anchors.top: checkinsCount.bottom
                    anchors.topMargin: 10
                    anchors.horizontalCenter: checkinsCount.horizontalCenter
                    width: (parent.width - 40) / 3
                    height: 100
                    color: mytheme.colors.backgroundSand
                    smooth: true
                    radius: 5

                    CacheImage {
                        y: 10
                        width: 64
                        height: 64
                        sourceUncached: "https://playfoursquare.s3.amazonaws.com/badge/114/photogenic.png"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: parent.height - height - 2
                        color: mytheme.colors.textColorProfile
                        font.pixelSize: 20
                        text: details.userPhotosCount + " " + "Photos"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            details.photos(userID);
                        }
                    }
                }

                Rectangle {
                    id: tipsCount
                    anchors.top: checkinsCount.bottom
                    anchors.topMargin: 10
                    anchors.left: checkinsCount.right
                    anchors.leftMargin: 10
                    width: (parent.width - 40) / 3
                    height: 100
                    color: mytheme.colors.backgroundSand
                    smooth: true
                    radius: 5

                    CacheImage {
                        y: 10
                        width: 64
                        height: 64
                        sourceUncached: "https://playfoursquare.s3.amazonaws.com/badge/114/bookworm.png"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: parent.height - height - 2
                        color: mytheme.colors.textColorProfile
                        font.pixelSize: 20
                        text: details.userTipsCount + " " + "Tips"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            details.tips(userID);
                        }
                    }
                }
            }

            LineGreen {
                height: 30
                width: details.width
                anchors.horizontalCenter: parent.horizontalCenter
                text: "YOU ARE #" + userLeadersboardRank
                visible: userRelationship == "self" && userLeadersboardRank > 0
            }

            Repeater {
                id: miniLeadersboard
                model: boardModel
                width: parent.width
                delegate: leaderBoardDelegate
                clip: true
                visible: userRelationship == "self" && userLeadersboardRank > 0
            }

        }
    }
    ScrollDecorator{ flickableItem: flickableArea }

    Component {
        id: leaderBoardDelegate

        EventBox {
            activeWhole: true
            width: miniLeadersboard.width

            userName: model.user
            //userShout:
            createdAt: model.shout

            Component.onCompleted: {
                userPhoto.photoUrl = model.photo
            }

            onAreaClicked: {
                details.openLeaderboard();
            }
        }
    }
}

import "components"
import Qt 4.7
import QtMobility.location 1.1
import "js/script.js" as Script
import "js/storage.js" as Storage

Rectangle {
    id:window
    width: 480
    height: 800
    color: theme.backGroundColor

    Component.onCompleted: {
        splashHider.start();
        signalTimer.start();
        Storage.getKeyValue("accesstoken", valueLoaded);
    }

    Timer {
        id: splashHider
        interval: 2000
        repeat: false
        onTriggered: {
            splashDialog.visible = false;
        }
    }

    Timer {
        id: signalTimer
        interval: 1111
        repeat: true
        onTriggered: {
            if(positionSource.position.latitudeValid==false) {
                signalIcon.visible = !signalIcon.visible;
            }
        }
    }

    PositionSource {
        id: positionSource
        updateInterval: 1000
        active: true
        onPositionChanged: {
            if(positionSource.position.latitudeValid) {
                signalIcon.visible = false;
            } else {
                signalIcon.visible = true;
            }
        }
    }

    function valueLoaded(key, value) {
        if(key=="accesstoken") {
            if(value.length>0) {
                Script.setAccessToken(value);
                Script.loadFriendsCheckins();
            } else {
                login.visible = true;
                login.reset();
            }
        }
    }

    function hideAll() {
        checkinDetails.state = "hidden";
        friendsCheckinsList.state = "hidden";
        placesList.state = "hidden";
        placeDialog.state = "hidden";
        mainmenu.state = "hidden"
        userDetails.state = "hidden";
        leaderBoard.state = "hidden";
    }

    function isSmallScreen() {
        if(window.width<400 || window.height<400) {
            return true;
        } else {
            return false;
        }
    }

    ListModel {
        id: checkinModel
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

    ListModel {
        id: friendsCheckinsModel
    }

    ListModel {
        id: placesModel
    }

    ListModel {
        id: boardModel
    }

    ListModel {
        id: tipsModel
    }

    Theme {
        id: theme
    }

    Item {
        width: parent.width
        y: toolbar.height
        height: menubar.visible ? parent.height - toolbar.height - menubar.height : parent.height - toolbar.height

        FriendsCheckinsList {
            id: friendsCheckinsList
            state: "shown"
            width: parent.width
            height: parent.height
            recentPressed: true
            nearbyPressed: false
            onRecent: {
                friendsCheckinsList.recentPressed = true;
                friendsCheckinsList.nearbyPressed = false;
                Script.loadFriendsCheckins();
            }
            onNearby: {
                friendsCheckinsList.recentPressed = false;
                friendsCheckinsList.nearbyPressed = true;
                Script.loadNearbyFriendsCheckins();
            }
            onClicked: {
                var checkin = friendsCheckinsModel.get(index);
                Script.loadCheckin(checkin)
                checkinModel.clear();
                checkinModel.append(checkin);
                hideAll();
                checkinDetails.state = "shown";
            }
        }

        CheckinDetails {
            id: checkinDetails
            width: parent.width
            height: parent.height
            state: "hidden"

            onVenue: {
                var checkin = checkinModel.get(0);
                Script.loadVenue(checkin.venueID);
                hideAll();
                placeDialog.state = "shown";

            }
            onUser: {
                Script.loadUser(user);
                hideAll();
                userDetails.state = "shown";
            }
        }

        PlacesList {
            id: placesList
            width: parent.width
            height: parent.height
            state:  "hidden"

            onClicked: {
                var venue = placesModel.get(index);
                Script.loadVenue( venue.id );
                hideAll();
                placeDialog.state = "shown";
            }
            onSearch: {
                Script.loadPlaces(query);
            }
        }

        PlaceDetails {
            id: placeDialog
            width: parent.width
            height: parent.height
            state: "hidden"
            onCheckin: {
                checkinDialog.reset();
                checkinDialog.venueID = placeDialog.venueID;
                checkinDialog.comment = "";
                checkinDialog.venueName = placeDialog.venueName;
                checkinDialog.state = "shown";
            }
            onShowAddTip: {
                console.log("Show add tip");
                tipDialog.reset();
                tipDialog.venueID = placeDialog.venueID;
                tipDialog.venueName = placeDialog.venueName;
                tipDialog.action = 0;
                tipDialog.state = "shown";
            }
            onMarkToDo: {
                tipDialog.reset();
                tipDialog.venueID = placeDialog.venueID;
                tipDialog.venueName = placeDialog.venueName;
                tipDialog.action = 1;
                tipDialog.state = "shown";
            }
        }

        CheckinDialog {
            id: checkinDialog
            width: parent.width
            state: "hidden"

            onCancel: { checkinDialog.state = "hidden"; }
            onCheckin: {
                console.log("Checkin to " + venueID +
                            " with comment " + comment +
                            " fb " + facebook +
                            " tw " + twitter);
                var realComment = comment;
                if(realComment.indexOf("Add comment")>-1) {
                    realComment = "";
                }
                Script.addCheckin(venueID, realComment, friends, facebook, twitter);
                checkinDialog.state = "hidden";
            }
        }

        LeaderBoard {
            id: leaderBoard
            width: parent.width
            height: parent.height
            state: "hidden"

            onUser: {
                Script.loadUser(user);
                hideAll();
                userDetails.state = "shown";
            }
        }

        ShoutDialog {
            id: shoutDialog
            width: parent.width
            state: "hidden"

            onCancel: { shoutDialog.state = "hidden"; }
            onShout: {
                /*console.log("Shout! " +
                            " with comment " + comment +
                            " fb " + facebook +
                            " tw " + twitter);*/
                var realComment = comment;
                if(realComment.indexOf("Write here")>-1) {
                    realComment = "";
                }
                Script.addCheckin(null, realComment, true, facebook, twitter);
                shoutDialog.state = "hidden";
            }
        }

        TipDialog {
            id: tipDialog
            width: parent.width
            state: "hidden"
            onCancel: {tipDialog.state = "hidden";}
            onAddTip: {
                if(tipDialog.action==0) {
                    //console.log("Tip: " + comment + " on " + tipDialog.venueID);
                    Script.addTip(tipDialog.venueID, comment);
                } else {
                    //console.log("mark: " + comment + " on " + tipDialog.venueID);
                    Script.markVenueToDo(tipDialog.venueID, comment);
                }
                tipDialog.state = "hidden";
            }
        }

        UserDetails {
            id: userDetails
            width: parent.width
            height: parent.height
            state: "hidden"
            onOpenLeaderBoard: {
                Script.loadLeaderBoard();
                hideAll();
                leaderBoard.state = "shown";
            }
        }

        NotificationDialog {
            id: notification
            width: parent.width
            state: "hidden"
            onClose: notification.state = "hidden";
        }

        Rectangle {
            id: signalIcon
            radius: 6
            color: "#d66"
            width: 32
            height: 32
            x: parent.width - 40
            y: parent.height - 40
            Image {
                anchors.centerIn: parent
                source: "pics/sat_dish.png"
            }
        }

    }

    MainMenu {
        id:mainmenu
        y: toolbar.height
        state: "hidden"
        anchors.horizontalCenter: parent.horizontalCenter
        onOpenFriendsCheckins: {
            Script.loadFriendsCheckins();
            hideAll();
            friendsCheckinsList.state = "shown";
        }
        onOpenPlaces: {
            Script.loadPlaces("");
            hideAll();
            placesList.state = "shown";
        }
        onOpenExplore: {
            Script.loadToDo();
            hideAll();
            placesList.state = "shown";
        }
        onOpenProfile: {
            Script.loadUser("self");
            hideAll();
            userDetails.state = "shown";
        }
        onOpenLeaderBoard: {
            Script.loadLeaderBoard();
            hideAll();
            leaderBoard.state = "shown";
        }
    }

    Rectangle {
        id: toolbar
        height: 54
        width:parent.width
        gradient: Gradient{
            GradientStop{position: 0; color: "#888"; }
            GradientStop{position: 0.1; color: "#ccc"; }
            GradientStop{position: 0.9; color: "#aaa"; }
        }

        Button {
            pic: "logo.png"
            visible: menubar.visible==false
            anchors.centerIn: parent
            width: 160
            height: 48
            onClicked: {
                if(mainmenu.state!="shown") {
                    mainmenu.state = "shown";
                } else {
                    mainmenu.state = "hidden";
                }
            }
        }

        Image {
            source: "pics/logo.png"
            anchors.centerIn: parent
            visible: menubar.visible
        }

        Button {
            id: minimizeButton
            pic: "minimize.png"
            x: 4
            anchors.verticalCenter: parent.verticalCenter
            width: 48
            height: 48
            onClicked: {
                windowHelper.minimize();
            }
            visible: isSmallScreen()==false
        }

        Button {
            x: minimizeButton.visible ? 56 : 4
            anchors.verticalCenter: parent.verticalCenter
            width: 90
            height: 48
            label: "Shout"
            onClicked: {
                shoutDialog.state = "shown";
            }
        }

        Button {
            pic: "delete.png"
            x: parent.width - width - 4
            anchors.verticalCenter: parent.verticalCenter
            width: 48
            height: 48
            onClicked: Qt.quit();
        }

        Image {
            id: shadow
            source:  "pics/top-shadow.png"
            width: parent.width
            y: parent.height - 1
        }

    }

    Rectangle {
        id: menubar
        visible: window.width<window.height
        height: 70
        width: parent.width
        y: parent.height - height
        color: "#ccc"
        gradient: Gradient {
            GradientStop{position: 0.2; color: "#4f4f4f"; }
            GradientStop{position: 0.49; color: "#494949"; }
            GradientStop{position: 0.5; color: "#4f4f4f"; }
            GradientStop{position: 0.8; color: "#404040"; }
        }

        Row {
            //width: 400
            height: 78
            y: 5
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: isSmallScreen() ? 5 : 15

            ToolbarButton {
                id: friendsCheckinsButton
                image: "users.png" // "112-group@2x.png"
                label: "Friends"
                selected: friendsCheckinsList.state == "shown"
                onClicked: {
                    Script.loadFriendsCheckins();
                    hideAll();
                    friendsCheckinsList.state = "shown";
                }
            }


            ToolbarButton {
                id: placesButton
                image: "pin_map.png" //  "07-map-marker@2x.png"
                label: "Places"
                selected: placesList.state == "shown"
                onClicked: {
                    Script.loadPlaces("");
                    hideAll();
                    placesList.state = "shown";
                }
            }

            ToolbarButton {
                image: "checkbox_checked.png" // "117-todo@2x.png"
                label: "To-Do"
                onClicked: {
                    Script.loadToDo();
                    hideAll();
                    placesList.state = "shown";
                }
            }

            ToolbarButton {
                image: "contact_card.png" // "111-user@2x.png"
                label: "Myself"
                onClicked: {
                    Script.loadUser("self");
                    hideAll();
                    userDetails.state = "shown";
                }
            }

        }

    }

    Image {
        id: bottomShadow
        visible: menubar.visible
        source:  "pics/bottom-shadow.png"
        width: parent.width
        y: menubar.y - height
    }

    LoginDialog {
        id: login
        anchors.fill: parent
        visible: false
        onFinished: {
            console.log("current URL: " + url);
            if(url.indexOf("access_token=")>0) {
                login.visible = false;
                var codeStart = url.indexOf("access_token=");
                var code = url.substring(codeStart + 13);
                Script.setAccessToken(code);
                Storage.setKeyValue("accesstoken", code);
                console.log("Access token: " + code);
                //done.label = code;
                //done.state = "shown";
            }
        }

        onLoadFailed: {
            done.label = "Error loading page"
            done.state = "shown"
        }
    }



    DoneIndicator {
        id: done
        label: "Done"

        onStateChanged: {
            if(done.label.indexOf(" 400 ")>0) {
                login.visible = true;
                login.reset();
            }
        }
    }

    WaitingIndicator {
        id: waiting
    }

    SplashDialog {
        id: splashDialog
        anchors.centerIn: parent
    }


}

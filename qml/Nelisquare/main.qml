import Qt 4.7
import QtMobility.location 1.1
import "components"
import "js/script.js" as Script
import "js/storage.js" as Storage
import "js/window.js" as Window
import "js/utils.js" as Utils

Rectangle {
    property bool isPortrait: false

    property string orientationType: "Auto"
    property string iconset: "Classic"
    property string mapprovider: "Google Maps"

    id:window
    width: 480
    height: 800
    color: theme.backGroundColor

    function onVisibililityChange(state) {
        positionSource.active = state;
    }
    function onPictureUploaded(response) {
        Script.parseAddPhoto(response);
    }

    function iconsetPath() {
        return iconset + "/";
    }

    function settingLoaded(key, value) {
        if(key=="accesstoken") {
            if(value.length>0) {
                Script.setAccessToken(value);
                showFriendsCheckins();
            } else {
                login.visible = true;
                login.reset();
            }
        } else if (key == "settings.orientation") {
            if (value == "") value = "Auto";
            window.orientationType = value;
            windowHelper.setOrientation(value);
        } else if (key == "settings.iconset") {
            if (value == "") value = "Classic";
            window.iconset = value;
        } else if (key == "settings.mapprovider") {
            if (value == "") value = "Google Maps";
            window.mapprovider = value;
        }
    }

    function settingChanged(key, value) {
        Storage.setKeyValue(key, value);
        settingLoaded(key, value);
    }

    Component.onCompleted: {
        splashHider.start();
        signalTimer.start();
        Storage.getKeyValue("accesstoken", settingLoaded);
        isPortrait = (window.width<window.height)

        Storage.getKeyValue("settings.orientation", settingLoaded);
        Storage.getKeyValue("settings.iconset",settingLoaded);
        Storage.getKeyValue("settings.mapprovider",settingLoaded);
    }

    onHeightChanged: {
        isPortrait = (window.width<window.height)
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

    function updateNotificationCount(value) {
        notificationsCount.text = value
    }

    function hideAll() {
        checkinDetails.state = "hidden";
        friendsCheckinsList.state = "hidden";
        venuesList.state = "hidden";
        venueDetails.state = "hidden";
        mainmenu.state = "hidden"
        userDetails.state = "hidden";
        leaderBoard.state = "hidden";
        photoDetails.state = "hidden";
        photoAddDialog.state = "hidden";
        notificationsList.state = "hidden";
        settingsDialog.state = "hidden";
    }

    function isSmallScreen() {
        if(window.width<400 || window.height<400) {
            return true;
        } else {
            return false;
        }
    }

    function showLeaderBoard() {
        Window.pushWindow(function() {
                Script.loadLeaderBoard();
                hideAll();
                leaderBoard.state = "shown";
                });
    }

    function showFriendsCheckins() {
        Script.loadFriendsCheckins();
        Window.pushWindow(function() {
            hideAll();
            friendsCheckinsList.state = "shown";
            });
    }

    function showVenueList(query) {
        Window.pushWindow(function() {
                if (query == "todolist") {
                    Script.loadToDo();
                } else {
                    Script.loadPlaces(query);
                }
                hideAll();
                venuesList.state = "shown";
            });
    }

    function showVenueDetails(venueID) {
        Script.loadVenue(venueID);
        Window.pushWindow(function() {                
                hideAll();
                venueDetails.state = "shown";
            });
    }

    function showUserDetails(user) {
        Window.pushWindow(function() {
                Script.loadUser(user);
                hideAll();
                userDetails.state = "shown";
            });
    }

    function showCheckinDetails(checkin) {
        Window.pushWindow(function() {
                Script.loadCheckin(checkin);
                hideAll();
                checkinDetails.state = "shown";
            });
    }

    function showPhotoDetails(photo) {
        Window.pushWindow(function() {
                Script.loadPhoto(photo);
                hideAll();
                photoDetails.state = "shown";
            });
    }

    function showAddPhotoDialog(checkin) {
        Window.pushWindow(function() {
                //hideAll();
                photoAddDialog.checkinID = checkin;
                photoAddDialog.state = "shown";
            });
    }

    function showNotificationsList() {
        Window.pushWindow(function() {
                hideAll();
                Script.loadNotifications();
                notificationsList.state = "shown";
            });
    }

    function showSettingsDialog() {
        Window.pushWindow(function() {
                hideAll();
                settingsDialog.state = "shown";
            });
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

    Theme {
        id: theme
    }

    Item {
        id: viewPort
        y: toolbar.height
        height: isPortrait ? parent.height - toolbar.height - menubar.height : parent.height - toolbar.height
        width: isPortrait ? parent.width : parent.width - menubar.width

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
                showCheckinDetails(checkin.id);
            }
        }

        CheckinDetails {
            id: checkinDetails
            width: parent.width
            height: parent.height
            state: "hidden"

            onVenue: {
                showVenueDetails(checkinDetails.owner.venueID);
            }
            onUser: {
                showUserDetails(user);
            }
            onPhoto: {
                showPhotoDetails(photo);
            }
            onShowAddComment: {
                commentDialog.reset();
                commentDialog.checkinID = checkinDetails.checkinID;
                commentDialog.state = "shown";
            }
            onDeleteComment: {
                Script.deleteComment(checkinDetails.checkinID,commentID);
            }
            onShowAddPhoto: {
                showAddPhotoDialog(checkin);
            }
        }

        VenuesList {
            id: venuesList
            width: parent.width
            height: parent.height
            state:  "hidden"

            onClicked: {
                var venue = placesModel.get(index);
                showVenueDetails(venue.id);
            }
            onSearch: {
                Script.loadPlaces(query);
            }
        }

        VenueDetails {
            id: venueDetails
            width: parent.width
            height: parent.height
            state: "hidden"
            onCheckin: {
                checkinDialog.reset();
                checkinDialog.venueID = venueDetails.venueID;
                checkinDialog.comment = "";
                checkinDialog.venueName = venueDetails.venueName;
                checkinDialog.state = "shown";
            }
            onShowAddTip: {
                tipDialog.reset();
                tipDialog.venueID = venueDetails.venueID;
                tipDialog.venueName = venueDetails.venueName;
                tipDialog.action = 0;
                tipDialog.state = "shown";
            }
            onMarkToDo: {
                tipDialog.reset();
                tipDialog.venueID = venueDetails.venueID;
                tipDialog.venueName = venueDetails.venueName;
                tipDialog.action = 1;
                tipDialog.state = "shown";
            }
            onUser: {
                showUserDetails(user);
            }
            onPhoto: {
                showPhotoDetails(photo);
            }
        }

        CheckinDialog {
            id: checkinDialog
            width: parent.width
            state: "hidden"

            onCancel: { checkinDialog.state = "hidden"; }
            onCheckin: {
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
                showUserDetails(user);
            }
        }

        UserDetails {
            id: userDetails
            width: parent.width
            height: parent.height
            state: "hidden"
            onAddFriend: {
                Script.addFriend(user);
                userRelationship = "updated";
                //showUserDetails(user);
            }
            onRemoveFriend: {
                Script.removeFriend(user);
                userRelationship = "updated";
                //showUserDetails(user);
            }
            onApproveFriend: {
                Script.approveFriend(user);
                userRelationship = "updated";
                //showUserDetails(user);
            }
            onUser: {
                showUserDetails(user);
            }
            onOpenLeaderBoard: {
                showLeaderBoard();
            }
        }

        PhotoDetails {
            id: photoDetails
            width: parent.width
            height: parent.height
            state: "hidden"
            onUser: {
                showUserDetails(user);
            }
        }

        PhotoAddDialog {
            id: photoAddDialog
            width: parent.width
            height: parent.height
            state: "hidden"
            onPath: {
                Script.addPhoto(checkin,photo);
                photoAddDialog.state = "hidden";
            }
        }

        NotificationsList {
            id: notificationsList
            onUser: {
                showUserDetails(user);
            }
            onCheckin: {
                showCheckinDetails(checkin);
            }
            onVenue: {
                showVenueDetails(venue);
            }
            onMarkNotificationsRead: {
                Script.markNotificationsRead(time);
            }
        }

        NotificationDialog {
            id: notificationDialog
            width: parent.width
            state: "hidden"
            onClose: {
                if (objectID != "") {
                    objectType = "";
                    objectID = "";
                    if(objectType=="checkin") {
                        showCheckinDetails(objectID);
                    }
                }
                notificationDialog.state = "hidden";

            }
        }

        SettingsDialog {
            id: settingsDialog
            onAuthDeleted: {
                settingChanged("accesstoken","");
            }
            onOrientationChanged: {
                settingChanged("settings.orientation",type);
            }
            onIconsetChanged: {
                settingChanged("settings.iconset",type);
            }
            onMapProviderChanged: {
                settingChanged("settings.mapprovider",type);
            }
        }

        ShoutDialog {
            id: shoutDialog
            width: parent.width
            state: "hidden"

            onCancel: { shoutDialog.state = "hidden"; }
            onShout: {
                var realComment = comment;
                if(realComment.indexOf("Write here")>-1) {
                    realComment = "";
                }
                Script.addCheckin(null, realComment, true, facebook, twitter);
                shoutDialog.state = "hidden";
            }
        }

        CommentDialog {
            id: commentDialog
            width: parent.width
            state: "hidden"

            onCancel: { commentDialog.state = "hidden"; }
            onShout: {
                //console.log("COMMENT FOR: " + checkinID + " VALUE: " + comment);
                Script.addComment(checkinID,comment);
                commentDialog.state = "hidden";
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
        id: mainmenu
        y: toolbar.height
        state: "hidden"
        anchors.horizontalCenter: parent.horizontalCenter
        onOpenFriendsCheckins: {
            showFriendsCheckins();
        }
        onOpenPlaces: {
            showVenueList("");
        }
        onOpenExplore: {
            showVenueList("todolist")
        }
        onOpenProfile: {
            showUserDetails("self");
        }
        onOpenLeaderBoard: {
            showLeaderBoard();
        }
        onOpenSettings: {
            showSettingsDialog();
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
            visible: settingsDialog.state == "hidden"
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
            id: notificationsButton
            pic: notificationsCount.visible?"email.png":"email_opened.png"
            x: buttonClose.x - width - 25
            anchors.verticalCenter: parent.verticalCenter
            width: 64
            height: 48
            visible: isSmallScreen()==false

            Text {
                id: notificationsCount
                anchors.centerIn: parent
                text: ""
                visible: text > 0
                color: "red"
            }
            onClicked: {
                showNotificationsList();
            }
        }

        Button {
            id: buttonClose
            pic: "delete.png"
            x: parent.width - width - 4
            width: 48
            anchors.verticalCenter: parent.verticalCenter
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

        Flow {
            id: menubarToolbar
            width: menubar.width
            height: menubar.height
            spacing: isSmallScreen() ? 5 : 15

            ToolbarButton {
                id: backwardsButton
                image: "undo.png"
                label: "Back"
                shown: Script.windowStash.length>0
                onClicked: {
                    Window.popWindow();
                }
            }

            ToolbarButton {
                id: friendsCheckinsButton
                image: "feed.png"
                label: "Feed"
                selected: friendsCheckinsList.state == "shown"
                onClicked: {
                    Window.clearWindows();
                    showFriendsCheckins();
                }
            }


            ToolbarButton {
                id: placesButton
                image: "places.png"
                label: "Places"
                selected: venuesList.state == "shown"
                onClicked: {
                    showVenueList("");
                }
            }

            ToolbarButton {
                image: "todo_list.png"
                label: "To-Do"
                onClicked: {
                    showVenueList("todolist");
                }
            }

            ToolbarButton {
                image: "info.png"
                label: "Myself"
                onClicked: {
                    showUserDetails("self");
                }
            }

        }

        state: isPortrait ? "bottom" : "right"

        states: [
            State {
                name: "bottom"
                PropertyChanges {
                    target: menubar
                    height: 70
                    width: parent.width
                    y: parent.height - menubar.height
                    x: 0
                }
                PropertyChanges {
                    target: menubarToolbar
                    y: 5
                    x: (menubar.width - backwardsButton.width*5 - 4*menubarToolbar.spacing)/2
                }
            },
            State {
                name: "right"
                PropertyChanges {
                    target: menubar
                    width: 90
                    height: parent.height - toolbar.height
                    x: parent.width - width
                    y: toolbar.height
                }
                PropertyChanges {
                    target: menubarToolbar
                    y: (menubar.height - backwardsButton.height*5 - 4*menubarToolbar.spacing)/2
                    x: 5
                }
            }
        ]
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
            if(url.indexOf("access_token=")>0) {
                var codeStart = url.indexOf("access_token=");
                var code = url.substring(codeStart + 13);
                Script.setAccessToken(code);
                Storage.setKeyValue("accesstoken", code);
                login.visible = false;
                showFriendsCheckins();
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

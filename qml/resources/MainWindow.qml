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

    anchors.fill: parent
    color: theme.backGroundColor

    function iconsetPath() {
        return iconset + "/";
    }

    function onPictureUploaded(response) {
        Script.onPictureUploaded(response);
    }

    function settingLoaded(key, value) {
        if(key=="accesstoken") {
            if(value.length>0) {
                Script.setAccessToken(value);
                window.showFriendsCheckins();
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
        window.settingLoaded(key, value);
    }

    Component.onCompleted: {
        splashHider.start();
        signalTimer.start();
        Storage.getKeyValue("accesstoken", window.settingLoaded);
        window.isPortrait = (window.width<window.height)

        Storage.getKeyValue("settings.orientation", window.settingLoaded);
        Storage.getKeyValue("settings.iconset", window.settingLoaded);
        Storage.getKeyValue("settings.mapprovider", window.settingLoaded);
    }

    onHeightChanged: {
        window.isPortrait = (window.width<window.height)
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
        active: mainWindowStack.gpsActive
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
        window.focus = true;
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
        photoShareDialog.state = "hidden";
        shoutDialog.state = "hidden";
        commentDialog.state = "hidden";
        checkinDialog.state = "hidden";
        tipDialog.state = "hidden";
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
                window.hideAll();
                leaderBoard.state = "shown";
                });
    }

    function showFriendsCheckins() {
        Script.loadFriendsCheckins();
        Window.pushWindow(function() {
            window.hideAll();
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
                window.hideAll();
                venuesList.state = "shown";
            });
    }

    function showVenueDetails(venueID) {
        Script.loadVenue(venueID);
        Window.pushWindow(function() {
                window.hideAll();
                venueDetails.state = "shown";
            });
    }

    function showUserDetails(user) {
        Window.pushWindow(function() {
                Script.loadUser(user);
                window.hideAll();
                userDetails.state = "shown";
            });
    }

    function showCheckinDetails(checkin) {
        Window.pushWindow(function() {
                Script.loadCheckin(checkin);
                window.hideAll();
                checkinDetails.state = "shown";
            });
    }

    function showPhotoDetails(photo) {
        Window.pushWindow(function() {
                Script.loadPhoto(photo);
                window.hideAll();
                photoDetails.state = "shown";
            });
    }

    function showAddPhotoDialog(checkinID,venueID) {
        Window.pushWindow(function() {
                photoAddDialog.checkinID = checkinID;
                photoAddDialog.venueID = venueID;
                photoAddDialog.state = "shown";
            });
    }

    function showNotificationsList() {
        Window.pushWindow(function() {
                window.hideAll();
                Script.loadNotifications();
                notificationsList.state = "shown";
            });
    }

    function showSettingsDialog() {
        Window.pushWindow(function() {
                window.hideAll();
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

    ThemeStyle {
        id: theme
    }

    Item {
        id: viewPort
        y: toolbar.height
        height: window.isPortrait ? parent.height - toolbar.height - menubar.height : parent.height - toolbar.height
        width: window.isPortrait ? parent.width : parent.width - menubar.width

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
                window.showCheckinDetails(checkin.id);
            }
        }

        CheckinDetails {
            id: checkinDetails
            width: parent.width
            height: parent.height
            state: "hidden"

            onVenue: {
                window.showVenueDetails(checkinDetails.owner.venueID);
            }
            onUser: {
                window.showUserDetails(user);
            }
            onPhoto: {
                window.showPhotoDetails(photo);
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
                window.showAddPhotoDialog(checkinDetails.checkinID,"");
            }
        }

        VenuesList {
            id: venuesList
            width: parent.width
            height: parent.height
            state:  "hidden"

            onClicked: {
                var venue = placesModel.get(index);
                window.showVenueDetails(venue.id);
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
                window.showUserDetails(user);
            }
            onPhoto: {
                window.showPhotoDetails(photo);
            }
            onShowAddPhoto: {
                window.showAddPhotoDialog("",venueDetails.venueID);
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
                window.showUserDetails(user);
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
                //window.showUserDetails(user);
            }
            onRemoveFriend: {
                Script.removeFriend(user);
                userRelationship = "updated";
                //window.showUserDetails(user);
            }
            onApproveFriend: {
                Script.approveFriend(user);
                userRelationship = "updated";
                //window.showUserDetails(user);
            }
            onUser: {
                window.showUserDetails(user);
            }
            onOpenLeaderBoard: {
                window.showLeaderBoard();
            }
        }

        PhotoDetails {
            id: photoDetails
            width: parent.width
            height: parent.height
            state: "hidden"
            onUser: {
                window.showUserDetails(user);
            }
        }

        PhotoAddDialog {
            id: photoAddDialog
            width: parent.width
            height: parent.height
            state: "hidden"
            onUploadPhoto: {
                photoShareDialog.photoUrl = photo;
                photoShareDialog.state = "shown";
            }
        }

        NotificationsList {
            id: notificationsList
            onUser: {
                window.showUserDetails(user);
            }
            onCheckin: {
                window.showCheckinDetails(checkin);
            }
            onVenue: {
                window.showVenueDetails(venue);
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
                        window.showCheckinDetails(objectID);
                    }
                }
                notificationDialog.state = "hidden";

            }
        }

        SettingsDialog {
            id: settingsDialog
            onAuthDeleted: {
                window.settingChanged("accesstoken","");
            }
            onOrientationChanged: {
                window.settingChanged("settings.orientation",type);
            }
            onIconsetChanged: {
                window.settingChanged("settings.iconset",type);
            }
            onMapProviderChanged: {
                window.settingChanged("settings.mapprovider",type);
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

        PhotoShareDialog{
            id: photoShareDialog
            width: parent.width
            state: "hidden"
            onCancel:{
                photoShareDialog.state="hidden";
            }
            onUploadPhoto: {
                photoShareDialog.state="hidden";
                Script.addPhoto(photoAddDialog.checkinID,
                                photoAddDialog.venueID,
                                photoShareDialog.photoUrl,
                                makepublic,facebook,twitter);
                photoAddDialog.state="hidden";
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
            window.showFriendsCheckins();
        }
        onOpenPlaces: {
            window.showVenueList("");
        }
        onOpenExplore: {
            window.showVenueList("todolist")
        }
        onOpenProfile: {
            window.showUserDetails("self");
        }
        onOpenLeaderBoard: {
            window.showLeaderBoard();
        }
        onOpenSettings: {
            window.showSettingsDialog();
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

        ButtonEx {
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

        ButtonEx {
            id: minimizeButton
            pic: "minimize.png"
            x: 4
            anchors.verticalCenter: parent.verticalCenter
            width: 48
            height: 48
            onClicked: {
                windowHelper.minimize();
            }
            visible: window.isSmallScreen()==false
        }

        ButtonEx {
            x: minimizeButton.visible ? 56 : 4
            anchors.verticalCenter: parent.verticalCenter
            width: 90
            height: 48
            label: "Shout"
            onClicked: {
                shoutDialog.reset();
                shoutDialog.state = "shown";
            }
        }

        ButtonEx {
            id: notificationsButton
            pic: notificationsCount.visible?"email.png":"email_opened.png"
            x: buttonClose.x - width - 25
            anchors.verticalCenter: parent.verticalCenter
            width: 64
            height: 48
            visible: window.isSmallScreen()==false

            Text {
                id: notificationsCount
                anchors.centerIn: parent
                font.pixelSize: 24
                text: ""
                visible: text > 0
                color: "red"
            }
            onClicked: {
                window.showNotificationsList();
            }
        }

        ButtonEx {
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
            spacing: window.isSmallScreen() ? 5 : 15

            ToolbarButton {
                id: backwardsButton
                image: "undo.png"
                label: "Back"
                shown: Window.windowStash.length>0
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
                    window.showFriendsCheckins();
                }
            }


            ToolbarButton {
                id: placesButton
                image: "places.png"
                label: "Places"
                selected: venuesList.state == "shown"
                onClicked: {
                    window.showVenueList("");
                }
            }

            ToolbarButton {
                image: "todo_list.png"
                label: "To-Do"
                onClicked: {
                    window.showVenueList("todolist");
                }
            }

            ToolbarButton {
                image: "info.png"
                label: "Myself"
                onClicked: {
                    window.showUserDetails("self");
                }
            }

        }

        state: window.isPortrait ? "bottom" : "right"

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
                window.showFriendsCheckins();
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

import Qt 4.7
import QtMobility.location 1.1
import Effects 1.0
import "components"
import "js/script.js" as Script
import "js/storage.js" as Storage
import "js/window.js" as Window
import "js/utils.js" as Utils

Rectangle {
    property bool isPortrait: false
    property bool blurred: false

    property string toolbarFile: ""

    property string orientationType: "auto"
    property string iconset: "original"
    property string mapprovider: "googlemaps"

    id: window

    anchors.fill:  parent

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
                splashDialog.nextState = "hidden";
                Script.setAccessToken(value);
                window.showFriendsFeed();
            } else {
                splashDialog.nextState = "login";
                splashDialog.login();
            }
        } else if (key == "settings.orientation") {
            if (value == "") value = "auto";
            window.orientationType = value;
            windowHelper.setOrientation(value);
        } else if (key == "settings.iconset") {
            if (value == "") value = "original";
            window.iconset = value;
        } else if (key == "settings.mapprovider") {
            if (value == "") value = "googlemaps";
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
        interval: 3000 //dbg
        repeat: false
        onTriggered: {
            splashDialog.state = splashDialog.nextState;
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
        toolbar.notificationsCount.text = value
    }

    function hideAll() {
        window.focus = true;
        checkinDetails.state = "hidden";
        friendsFeed.state = "hidden";
        venuesList.state = "hidden";
        venueDetails.state = "hidden";
        mainmenu.state = "hidden"
        userDetails.state = "hidden";
        leaderBoard.state = "hidden";
        photoDetails.state = "hidden";
        photoAdd.state = "hidden";
        notificationsList.state = "hidden";
        settings.state = "hidden";
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

    function showFriendsFeed() {
        Script.loadFriendsFeed();
        Window.pushWindow(function() {
            window.hideAll();
            friendsFeed.state = "shown";
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

    function showVenuePage(venueID) {
        Script.loadVenue(venueID);
        Window.pushWindow(function() {
                window.hideAll();
                venueDetails.state = "shown";
            });
    }

    function showUserPage(user) {
        Window.pushWindow(function() {
                Script.loadUser(user);
                window.hideAll();
                userDetails.state = "shown";
            });
    }

    function showCheckinPage(checkin) {
        Window.pushWindow(function() {
                Script.loadCheckin(checkin);
                window.hideAll();
                checkinDetails.state = "shown";
            });
    }

    function showPhotoPage(photo) {
        Window.pushWindow(function() {
                Script.loadPhoto(photo);
                window.hideAll();
                photoDetails.state = "shown";
            });
    }

    function showAddPhotoDialog(checkinID,venueID) {
        Window.pushWindow(function() {
                photoAdd.checkinID = checkinID;
                photoAdd.venueID = venueID;
                photoAdd.state = "shown";
            });
    }

    function showNotifications() {
        Window.pushWindow(function() {
                window.hideAll();
                Script.loadNotifications();
                notificationsList.state = "shown";
            });
    }

    function showSettingsPage() {
        Window.pushWindow(function() {
                window.hideAll();
                settings.state = "shown";
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
        height: window.isPortrait ? parent.height - menubar.height - toolbar.height : parent.height - toolbar.height
        width: window.isPortrait ? parent.width : parent.width - menubar.width

        /*effect: Blur {
            blurRadius: blurred ? 2.0 : 0.0
        }*/

        FriendsFeedPage {
            id: friendsFeed
            state: "shown"
            width: parent.width
            height: parent.height
            recentPressed: true
            nearbyPressed: false
            onRecent: {
                friendsFeed.recentPressed = true;
                friendsFeed.nearbyPressed = false;
                Script.loadFriendsFeed();
            }
            onNearby: {
                friendsFeed.recentPressed = false;
                friendsFeed.nearbyPressed = true;
                Script.loadFriendsFeedNearby();
            }
            onClicked: {
                var checkin = friendsCheckinsModel.get(index);
                window.showCheckinPage(checkin.id);
            }
        }

        CheckinPage {
            id: checkinDetails
            width: parent.width
            height: parent.height
            state: "hidden"

            onVenue: {
                window.showVenuePage(checkinDetails.owner.venueID);
            }
            onUser: {
                window.showUserPage(user);
            }
            onPhoto: {
                window.showPhotoPage(photo);
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

        VenuesListPage {
            id: venuesList
            width: parent.width
            height: parent.height
            state:  "hidden"

            onClicked: {
                var venue = placesModel.get(index);
                window.showVenuePage(venue.id);
            }
            onSearch: {
                Script.loadPlaces(query);
            }
        }

        VenuePage {
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
                window.showUserPage(user);
            }
            onPhoto: {
                window.showPhotoPage(photo);
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

        LeaderBoardPage {
            id: leaderBoard
            width: parent.width
            height: parent.height
            state: "hidden"

            onUser: {
                window.showUserPage(user);
            }
        }

        UserPage {
            id: userDetails
            width: parent.width
            height: parent.height
            state: "hidden"
            onAddFriend: {
                Script.addFriend(user);
                userRelationship = "updated";
                //window.showUserPage(user);
            }
            onRemoveFriend: {
                Script.removeFriend(user);
                userRelationship = "updated";
                //window.showUserPage(user);
            }
            onApproveFriend: {
                Script.approveFriend(user);
                userRelationship = "updated";
                //window.showUserPage(user);
            }
            onUser: {
                window.showUserPage(user);
            }
            onOpenLeaderBoard: {
                window.showLeaderBoard();
            }
        }

        PhotoPage {
            id: photoDetails
            width: parent.width
            height: parent.height
            state: "hidden"
            onUser: {
                window.showUserPage(user);
            }
        }

        PhotoAddPage {
            id: photoAdd
            width: parent.width
            height: parent.height
            state: "hidden"
            onUploadPhoto: {
                photoShareDialog.photoUrl = photo;
                photoShareDialog.state = "shown";
            }
        }

        NotificationsPage {
            id: notificationsList
            onUser: {
                window.showUserPage(user);
            }
            onCheckin: {
                window.showCheckinPage(checkin);
            }
            onVenue: {
                window.showVenuePage(venue);
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
                        window.showCheckinPage(objectID);
                    }
                }
                notificationDialog.state = "hidden";

            }
        }

        SettingsPage {
            id: settings
            onAuthDeleted: {
                splashDialog.state = "shown";
                splashHider.start();
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
            visible: false
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
                Script.addPhoto(photoAdd.checkinID,
                                photoAdd.venueID,
                                photoShareDialog.photoUrl,
                                makepublic,facebook,twitter);
                photoAdd.state="hidden";
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

    Toolbar {
        id: toolbar
    }

    MainMenu {
        id: mainmenu
        state: "hidden"
        anchors.horizontalCenter: parent.horizontalCenter
        onOpenFriendsFeed: {
            window.showFriendsFeed();
        }
        onOpenPlaces: {
            window.showVenueList("");
        }
        onOpenExplore: {
            window.showVenueList("todolist")
        }
        onOpenProfile: {
            window.showUserPage("self");
        }
        onOpenLeaderBoard: {
            window.showLeaderBoard();
        }
        onOpenSettings: {
            window.showSettingsPage();
        }
    }

    Rectangle {
        id: menubar
        height: 70
        width: parent.width
        y: parent.height - height
        color: "#404040"
        /*gradient: Gradient {
            GradientStop{position: 0.2; color: "#4f4f4f"; }
            GradientStop{position: 0.49; color: "#494949"; }
            GradientStop{position: 0.5; color: "#4f4f4f"; }
            GradientStop{position: 0.8; color: "#404040"; }
        }*/

        Flow {
            id: menubarToolbar
            //width: menubar.width
            anchors.horizontalCenter: parent.horizontalCenter
            height: menubar.height
            spacing: window.isSmallScreen() ? 5 : 15

            ToolbarTextButton {
                id: backwardsButton
                label: "BACK"
                shown: Window.windowStash.length>0
                onClicked: {
                    Window.popWindow();
                }
            }

            ToolbarTextButton {
                label: "FEED"
                selected: friendsFeed.state == "shown"
                onClicked: {
                    Window.clearWindows();
                    window.showFriendsFeed();
                }
            }


            ToolbarTextButton {
                label: "PLACES"
                selected: venuesList.state == "shown"
                onClicked: {
                    window.showVenueList("");
                }
            }

            ToolbarTextButton {
                label: "LISTS"
                onClicked: {
                    window.showVenueList("todolist");
                }
            }

            ToolbarTextButton {
                label: "MYSELF"
                onClicked: {
                    window.showUserPage("self");
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
                    x: 5//(menubar.width - backwardsButton.width*5 - 4*menubarToolbar.spacing)/2
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
                    y: 5//(menubar.height - backwardsButton.height*5 - 4*menubarToolbar.spacing)/2
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

    LoginDialogPage {
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
                window.showFriendsFeed();
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

        onLogin: {
            login.reset();
            login.visible = true;
        }
    }
}

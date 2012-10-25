import Qt 4.7
import QtMobility.location 1.1
//import Effects 1.0
import "components"
import "./build.info.js" as BuildInfo
import "js/script.js" as Script
import "js/storage.js" as Storage
import "js/windowmanager.js" as WM
import "js/utils.js" as Utils

Rectangle {
    property bool isPortrait: true
    property bool blurred: false

    property string orientationType: "auto"
    property string mapprovider: "googlemaps"
    property string checkupdates: "none"

    property string topWindowType: ""

    id: window

    anchors.fill:  parent

    color: theme.backGroundColor

    onCheckupdatesChanged: {
        if (checkupdates!="none") {
            Script.getUpdateInfo(checkupdates,onUpdateAvailable);
        }
    }

    function onUpdateAvailable(build, version, changelog, url) {
        var update = false;
        if (checkupdates == "developer") {
            if (build > BuildInfo.build) {
                update = true;
            }
        } else if (checkupdates == "stable") {
            if (version != BuildInfo.version || build != BuildInfo.build) {
                update = true;
            }
        }

        if (update){
            updateDialog.build = build;
            updateDialog.version = version;
            updateDialog.url = url;
            updateDialog.changelog = changelog;
            updateDialog.state = "shown";
        }
    }

    function onPictureUploaded(response, page) {
        Script.parseAddPhoto(response, page);
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
        } else if (key == "settings.mapprovider") {
            if (value == "") value = "googlemaps";
            window.mapprovider = value;
        } else if (key == "settings.checkupdates") {
            if (value == "") value = "stable";
            window.checkupdates = value;
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
        window.isPortrait = window.height > (window.width*2/3);//window.width<(window.height/2);

        Storage.getKeyValue("settings.orientation", window.settingLoaded);
        Storage.getKeyValue("settings.mapprovider", window.settingLoaded);
        Storage.getKeyValue("settings.checkupdates", window.settingLoaded);
    }

    onHeightChanged: {
        window.isPortrait = window.height > (window.width*2/3);//window.width<(window.height/2);
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
        interval: 2000
        repeat: true
        onTriggered: {
            if(!positionSource.position.latitudeValid) {
                signalIcon.visible = !signalIcon.visible;
            }
            WM.destroyWindows();
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

    function showFriendsFeed() {
        WM.buildPage(
            viewPort,
            "FriendsFeed",
            {
                "update": function(page) {
                              Script.loadFriendsFeed(page);
                          }
            },
            function(page) {
                page.recent.connect(function() {
                    Script.loadFriendsFeed(page);
                });
                page.nearby.connect(function() {
                    Script.loadFriendsFeedNearby(page);
                });
                page.clicked.connect(function(id) {
                    window.showCheckinPage(id);
                });
                page.state = "shown"
            });
    }

    function showCheckinPage(checkinID) {
        WM.buildPage(
            viewPort,
            "Checkin",
            {
                "id": checkinID,
                "update": function(page) {
                      Script.loadCheckin(page, checkinID);
                  }
            },
            function(page){
                page.venue.connect(function(venue){
                    window.showVenuePage(venue);
                });
                page.like.connect(function(checkin, state) {
                    Script.likeCheckin(page,checkin,state);
                });
                page.user.connect(function(user){
                    window.showUserPage(user);
                });
                page.photo.connect(function(photo){
                    window.showPhotoPage(photo);
                });
                page.showAddComment.connect(function(checkin){
                    commentDialog.reset();
                    commentDialog.checkinID = checkin;
                    commentDialog.state = "shown";
                });
                page.deleteComment.connect(function(checkin, comment){
                    Script.deleteComment(page,checkin,comment);
                });
                page.showAddPhoto.connect(function(checkin){
                    window.showPhotoAddPage({
                        "type": "checkin",
                        "id": checkin,
                        "owner": page
                    });
                });
                page.state = "shown";
            });
    }

    function showUserPage(userid) {
        WM.buildPage(
            viewPort,
            "User",
            {
                "id": userid,
                "update": function(page) {
                      Script.loadUser(page,userid);
                  }
            },
            function(page){
                page.addFriend.connect(function(user){
                    Script.addFriend(user);
                    page.userRelationship = "updated";
                });
                page.removeFriend.connect(function(user){
                    Script.removeFriend(user);
                    page.userRelationship = "updated";
                });
                page.approveFriend.connect(function(user){
                    Script.approveFriend(user);
                    page.userRelationship = "updated";
                });
                page.user.connect(function(user){
                    window.showUserPage(user);
                });
                page.openLeaderboard.connect(function(){
                    window.showLeaderboard();
                });
                page.badges.connect(function(user){
                    window.showUserBadges(user);
                });
                page.mayorships.connect(function(user){
                    window.showUserMayorships(user);
                });
                page.checkins.connect(function(user){
                    window.showUserCheckins(user);
                });
                page.state = "shown";
            });
    }

    function showSettingsPage() {
        WM.buildPage(
            viewPort,
            "Settings",
            {
                "update": function(page) {
                    page.cacheSize = cache.info();
                }
            },
            function(page) {
                page.authDeleted.connect(function(){
                    splashDialog.state = "shown";
                    splashHider.start();
                    window.settingChanged("accesstoken","");
                });
                page.orientationChanged.connect(function(type) {
                    window.settingChanged("settings.orientation",type);
                });
                page.checkUpdatesChanged.connect(function(type) {
                    window.settingChanged("settings.checkupdates",type);
                });
                page.mapProviderChanged.connect(function(type) {
                    window.settingChanged("settings.mapprovider",type);
                });
                page.state = "shown";
        });
    }

    function showLeaderboard() {
        WM.buildPage(
            viewPort,
            "LeaderBoard",
            {
                "update":function(page){
                         Script.loadLeaderBoard(page);
                     }
            },
            function(page) {
                page.user.connect(function(user) {
                    window.showUserPage(user);
                });
                page.state = "shown";
        });
    }

    function showVenueList(query) {
        WM.buildPage(
            viewPort,
            "VenuesList",
            {
                "id": query,
                "update":function(page){
                     if (query == "todolist") {
                        Script.loadToDo(page);
                    } else {
                        Script.loadPlaces(page,query);
                    }
                 }
            },
            function(page) {
                page.clicked.connect(function(venueid) {
                    window.showVenuePage(venueid);
                });
                page.search.connect(function(query) {
                    Script.loadPlaces(page, query);
                });
                page.state = "shown";
            });
    }

    function showVenuePage(venue) {
        WM.buildPage(
            viewPort,
            "Venue",
            {
                "id": venue,
                "update":function(page){
                    Script.loadVenue(page, venue);
                 }
            },
            function(page) {
                page.checkin.connect(function(venueID, venueName) {
                    checkinDialog.reset();
                    checkinDialog.venueID = venueID;
                    checkinDialog.venueName = venueName;
                    checkinDialog.state = "shown";
                });
                page.showAddTip.connect(function(venueID, venueName) {
                    tipDialog.reset();
                    tipDialog.venueID = venueID;
                    tipDialog.venueName = venueName;
                    tipDialog.action = 0;
                    tipDialog.state = "shown";
                });
                page.markToDo.connect(function(venueID, venueName) {
                    tipDialog.reset();
                    tipDialog.venueID = venueID;
                    tipDialog.venueName = venueName;
                    tipDialog.action = 1;
                    tipDialog.state = "shown";
                });
                page.user.connect(function(user) {
                    window.showUserPage(user);
                });
                page.photo.connect(function() {
                    window.showVenuePhotos(venue);
                });
                page.showAddPhoto.connect(function(venueID) {
                    window.showPhotoAddPage({
                        "type": "venue",
                        "id": venueID,
                        "owner": page
                    });
                });
                page.like.connect(function(venueID,state) {
                    Script.likeVenue(venueID,state);
                });
                page.state = "shown";
            });
    }

    function showVenuePhotos(venue) {
        WM.buildPage(
            viewPort,
            "VenuePhotos",
            {
                "id": venue,
                "update": function(page) {
                    Script.loadVenuePhotos(page,venue);
                }
            },
            function(page){
                page.photo.connect(function(photo){
                    window.showPhotoPage(photo);
                });
                page.state = "shown";
            });
    }

    function showUserBadges(user) {
        WM.buildPage(
            viewPort,
            "Badges",
            {
                "id": user,
                "update":function(page){
                    Script.loadBadges(page,user);
                 }
            },
            function(page){

                page.badge.connect(function(params) {
                    window.showBadgeInfo(params);
                });
                page.state = "shown";
            });
    }

    function showBadgeInfo(params) {
        WM.buildPage(
            viewPort,
            "BadgeInfo",
            {
                "update": function(page){}
            },
            function(page){
                page.venue.connect(function(venueID) {
                    window.showVenuePage(venueID);
                });
                page.name = params.name;
                page.image = params.image;
                page.info = params.info;
                page.venueName = params.venueName;
                page.venueID = params.venueID;
                page.time = params.time;

                page.state = "shown";
            });
    }

    function showUserCheckins(user) {
        WM.buildPage(
            viewPort,
            "CheckinHistory",
            {
                "id": user,
                "update": function(page){
                        Script.loadCheckinHistory(page,user);
                    }
            },
            function(page){

                page.checkin.connect(function(id) {
                    window.showCheckinPage(id)
                });
                page.state = "shown";
            });
    }

    function showUserMayorships(user) {
        WM.buildPage(
            viewPort,
            "Mayorships",
            {
                "id":user,
                "update":function(page){
                             Script.loadMayorships(page,user);
                         }
            },
            function(page){
                page.venue.connect(function(id) {
                    window.showVenuePage(id);
                });
                page.state = "shown";
            });
    }


    function showPhotoPage(photo) {
        WM.buildPage(
            viewPort,
            "Photo",
            {
                "id":photo,
                "update":function(page) {
                            Script.loadPhoto(page,photo);
                         }
            },
            function(page) {
                page.user.connect(function(user) {
                    window.showUserPage(user);
                });
                page.state = "shown";
            });
    }

    function showNotifications() {
        WM.buildPage(
            viewPort,
            "Notifications",
            {
                "update":function(page){
                        Script.loadNotifications(page);
                    }
            },
            function(page) {
                page.user.connect(function(user) {
                    window.showUserPage(user);
                });
                page.checkin.connect(function(checkin) {
                    window.showCheckinPage(checkin);
                });
                page.venue.connect(function(venue) {
                    window.showVenuePage(venue);
                });
                page.markNotificationsRead(function(time) {
                    Script.markNotificationsRead(page,time);
                });
                page.state = "shown";
            });
    }

    function showPhotoAddPage(options) {
        WM.buildPage(
            viewPort,
            "PhotoAdd",
            {
                "update": function(page){}
            },
            function(page) {
                page.uploadPhoto.connect(function(photo){
                    photoShareDialog.options = options;
                    photoShareDialog.owner = page;
                    photoShareDialog.photoUrl = photo;
                    photoShareDialog.state = "shown";
                });
                page.state = "shown";
            });
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

        CheckinDialog {
            id: checkinDialog
            z: 1
            width: parent.width
            state: "hidden"

            onCancel: { checkinDialog.state = "hidden"; }
            onCheckin: {
                var realComment = comment;
                if(realComment == theme.textDefaultComment) {
                    realComment = "";
                }
                Script.addCheckin(venueID, realComment, friends, facebook, twitter);
                checkinDialog.state = "hidden";
            }
        }

        NotificationDialog {
            id: notificationDialog
            z: 1
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

        CommentDialog {
            id: commentDialog
            z: 1
            width: parent.width
            state: "hidden"

            onCancel: { commentDialog.state = "hidden"; }
            onShout: {
                //console.log("COMMENT FOR: " + checkinID + " VALUE: " + comment);
                Script.addComment(WM.topWindow().page, checkinID,comment);
                commentDialog.state = "hidden";
            }
        }

        TipDialog {
            id: tipDialog
            z: 1
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

        PhotoShareDialog {
            id: photoShareDialog
            z: 1
            width: parent.width
            state: "hidden"
            onCancel:{
                photoShareDialog.state="hidden";
            }
            onUploadPhoto: {
                photoShareDialog.state="hidden";
                Script.addPhoto(params);
                owner.state="hidden";
            }
        }

        UpdateDialog {
            id: updateDialog
            z: 10
        }

        Rectangle {
            id: signalIcon
            z: 1
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

    Rectangle {
        id: menubar
        height: 70
        width: parent.width
        y: parent.height - height
        color: "#404040"

        Flow {
            id: menubarToolbar
            //width: menubar.width
            anchors.horizontalCenter: parent.horizontalCenter
            height: menubar.height
            spacing: 15

            ToolbarTextButton {
                id: backwardsButton
                label: "BACK"
                colorActive: theme.textColorButtonMenu
                colorInactive: theme.textColorButtonMenuInactive
                shown: WM.windowStash.length>1
                onClicked: {
                    WM.popWindow();
                }
            }

            ToolbarTextButton {
                label: "FEED"
                selected: topWindowType == "FriendsFeed"
                colorActive: theme.textColorButtonMenu
                colorInactive: theme.textColorButtonMenuInactive
                onClicked: {
                    WM.clearWindows();
                    window.showFriendsFeed();
                }
            }

            ToolbarTextButton {
                label: "PLACES"
                selected: topWindowType == "VenuesList" && WM.topWindow().params.id != "todolist"
                colorActive: theme.textColorButtonMenu
                colorInactive: theme.textColorButtonMenuInactive
                onClicked: {
                    window.showVenueList("");
                }
            }

            ToolbarTextButton {
                label: "LISTS"
                selected: topWindowType == "VenuesList" && WM.topWindow().params.id == "todolist"
                colorActive: theme.textColorButtonMenu
                colorInactive: theme.textColorButtonMenuInactive
                onClicked: {
                    window.showVenueList("todolist");
                }
            }

            ToolbarTextButton {
                label: "ME"
                selected: topWindowType == "User" && WM.topWindow().params.id == "self"
                colorActive: theme.textColorButtonMenu
                colorInactive: theme.textColorButtonMenuInactive
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
                    width: undefined
                }
            },
            State {
                name: "right"
                PropertyChanges {
                    target: menubar
                    width: 100
                    height: parent.height - toolbar.height
                    x: parent.width - width
                    y: toolbar.height
                }
                PropertyChanges {
                    target: menubarToolbar
                    y: 5//(menubar.height - backwardsButton.height*5 - 4*menubarToolbar.spacing)/2
                    x: 5
                    width: menubar.width
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

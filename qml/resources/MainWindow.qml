import Qt 4.7
import QtMobility.location 1.1
//import Effects 1.0
import "components"
import "themes"
import "./build.info.js" as BuildInfo
import "js/script.js" as Script
import "js/storage.js" as Storage
import "js/windowmanager.js" as WM
import "js/utils.js" as Utils

Rectangle {
    id: window

    property bool isPortrait: true
    property bool blurred: false

    property bool windowActive: false

    property string orientationType: "auto"
    property string mapprovider: "google"
    property string checkupdates: "none"

    property string imageLoadType: "all"
    property int gpsUplockTime: 0 //in seconds
    property int feedAutoUpdate: 0 //in seconds

    property int commentUpdateRate: 300 //currently hardcoded to be 5 mins

    property string topWindowType: ""

    property bool molome_present: false
    property bool molome_installed: false

    property alias positionSource: positionSource

    anchors.fill:  parent

    color: theme.colors.backgroundMain

    onCheckupdatesChanged: {
        if (checkupdates!="none") {
            Script.getUpdateInfo(checkupdates,onUpdateAvailable);
        }
    }

    onWindowActiveChanged: {
        if (!windowActive) {
            if (positionSource.position.latitudeValid) {
                timerGPSUnlock.start();
            } else {
                positionSource.active = windowActive;
            }
        } else {
            timerGPSUnlock.stop();
            positionSource.active = windowActive;
        }
    }

    function onUpdateAvailable(build, version, changelog, url) {
        var update = false;
        if (checkupdates == "developer") {
            if (build > BuildInfo.build) {
                update = true;
            }
        } else if (checkupdates == "alpha") {
            if (build > BuildInfo.build) {
                update = true;
            }
        } else if (checkupdates == "stable") {
            if (version !== BuildInfo.version || build !== BuildInfo.build) {
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

    function onMolomePhoto(state, photoUrl) {
        //console.log("MOLO PHOTO: state:" + state + " path:" + photoUrl);
        waiting.hide();
        if (state && topWindowType == "PhotoAdd") {
            photoShareDialog.photoUrl = photoUrl;
            photoShareDialog.state = "shown";
        }
    }

    function onPictureUploaded(response, page) {
        Script.parseAddPhoto(response, page);
    }

    function settingLoaded(key, value) {
        if(key==="accesstoken") {
            if(value.length>0) {
                splashDialog.nextState = "hidden";
                Script.setAccessToken(value);
                window.showFriendsFeed();
            } else {
                splashDialog.nextState = "login";
                splashDialog.login();
            }
        } else if (key === "settings.orientation") {
            if (value === "") value = "auto";
            window.orientationType = value;
            windowHelper.setOrientation(value);
        } else if (key === "settings.mapprovider") {
            if (value === "") value = "google";
            window.mapprovider = value;
        } else if (key === "settings.checkupdates") {
            if (value === "") value = "stable";
            window.checkupdates = value;
        } else if (key === "settings.molome") {
            //TODO: make install/uninstall (first see) notification enable
            //console.log("molome settings loaded");
            molome.updateinfo();
        } else if (key === "settings.imageload") {
            if (value === "") value = "all";
            window.imageLoadType = value;
            cache.loadtype(value);
        } else if (key === "settings.gpsunlock") {
            if (value === "") value = 0;
            window.gpsUplockTime = value;
        } else if (key === "settings.feedupdate") {
            if (value === "") value = 0;
            if (value === 60) value = 120;
            window.feedAutoUpdate = value;
        } else if (key === "settings.theme") {
            if (value === "") value = "light";
            theme.loadTheme(value);
        } else {
            console.log("Unknown setting: " + key + "=" + value);
        }
    }

    function settingChanged(key, value) {
        Storage.setKeyValue(key, value);
        window.settingLoaded(key, value);
    }

    Component.onCompleted: {
        splashHider.start();
        if (theme.platform === "maemo") {
            signalTimer.start();
        }

        Storage.getKeyValue("accesstoken", window.settingLoaded);
        window.isPortrait = window.height > (window.width*2/3);//window.width<(window.height/2);

        Storage.getKeyValue("settings.orientation", window.settingLoaded);
        Storage.getKeyValue("settings.mapprovider", window.settingLoaded);
        Storage.getKeyValue("settings.checkupdates", window.settingLoaded);
        Storage.getKeyValue("settings.molome", window.settingLoaded);

        Storage.getKeyValue("settings.imageload", window.settingLoaded);
        Storage.getKeyValue("settings.gpsunlock", window.settingLoaded);
        Storage.getKeyValue("settings.feedupdate", window.settingLoaded);
        Storage.getKeyValue("settings.theme", window.settingLoaded);
    }

    onHeightChanged: {
        window.isPortrait = window.height > (window.width*2/3);//window.width<(window.height/2);
    }

    Timer {
        id: splashHider
        interval: 1000
        repeat: false
        onTriggered: {
            splashDialog.state = splashDialog.nextState;
            molome.updateinfo();
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
        }
    }

    Timer {
        id: timerGPSUnlock
        interval: window.gpsUplockTime * 1000;
        repeat: false
        onTriggered: {
            positionSource.active = window.windowActive;
        }
    }

    PositionSource {
        id: positionSource
        updateInterval: 5000
        active: false
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
        if (topWindowType === "FriendsFeed" ) {
            if (window.feedAutoUpdate === 0) {
                WM.topWindow().page.lastUpdateTime = "0";
            } else {
                WM.topWindow().page.showWait = true;
            }
        }
        WM.buildPage(
            viewPort,
            "FriendsFeed",
            {
                "update": function(page) {
                              page.timerFeedUpdate.restart();
                              Script.loadFriendsFeed(page);
                          }
            },
            function(page) {
                page.update.connect(function(lastupdate) {
                    Script.loadFriendsFeed(page)
                });
                page.recent.connect(function() {
                    page.lastUpdateTime = "0";
                    Script.loadFriendsFeed(page);
                });
                page.nearby.connect(function() {
                    page.lastUpdateTime = "0";
                    Script.loadFriendsFeedNearby(page);
                });
                page.clicked.connect(function(id) {
                    window.showCheckinPage(id);
                });
                page.checkinInfo.connect(function(id){
                    Script.loadCheckinInfo(page,id);
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
                    Script.addFriend(page,user);
                    page.userRelationship = "updated";
                });
                page.removeFriend.connect(function(user){
                    Script.removeFriend(page,user);
                    page.userRelationship = "updated";
                });
                page.approveFriend.connect(function(user){
                    Script.approveFriend(page,user);
                    page.userRelationship = "updated";
                });
                page.denyFriend.connect(function(user){
                    Script.denyFriend(page,user);
                    page.userRelationship = "updated";
                });
                page.user.connect(function(user){
                    window.showUserPage(user);
                });
                page.venue.connect(function(venue){
                    window.showVenuePage(venue);
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
                page.friends.connect(function(user) {
                    window.showUserFriends(user);
                });
                page.photos.connect(function(user) {
                    window.showUserPhotos(user);
                });
                page.tips.connect(function(user) {
                    window.showTipsList("user",user);
                });
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
                page.settingsChanged.connect(function(type,value) {
                    window.settingChanged("settings."+type,value);
                });
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
        });
    }

    function showVenueEdit(venue) {
        WM.buildPage(
            viewPort,
            "VenueEdit",
            {
                "id":"",
                "update": function(page) {
                    Script.prepareVenueEdit(page,venue);
                }
            },
            function(page) {
                page.update.connect(function(params){
                    Script.updateVenueInfo(page,params);
                });
                page.updateCompleted.connect(function(venue){
                    window.showVenuePage(venue);
                });
            });
    }

    function showVenueList(query) {
        WM.buildPage(
            viewPort,
            "VenuesList",
            {
                "id": query,
                "update":function(page){
                     if (query === "todolist") {
                        Script.loadToDo(page);
                    } else {
                        Script.loadPlaces(page,query);
                    }
                 }
            },
            function(page) {
                page.checkin.connect(function(venueID, venueName) {
                    checkinDialog.reset();
                    checkinDialog.venueID = venueID;
                    checkinDialog.venueName = venueName;
                    checkinDialog.state = "shown";
                });
                page.clicked.connect(function(venueid) {
                    window.showVenuePage(venueid);
                });
                page.search.connect(function(query) {
                    Script.loadPlaces(page, query);
                });
                page.addVenue.connect(function(){
                    window.showVenueEdit();
                });
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
                    tipDialog.ownerPage = page;
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
                page.tip.connect(function(tip){
                    window.showTipPage(tip);
                });
                page.tips.connect(function(){
                    window.showTipsList("venues", venue);
                });
                page.photo.connect(function() {
                    window.showVenuePhotos(venue);
                });
                page.showMap.connect(function() {
                    window.showVenueMap(page);
                });
                page.showAddPhoto.connect(function(venueID) {
                    window.showPhotoAddPage({
                        "type": "venue",
                        "id": venueID,
                        "owner": page
                    });
                });
                page.like.connect(function(venueID,state) {
                    Script.likeVenue(page,venueID,state);
                });
            });
    }

    function showVenueMap(venuepage) {
        waiting.show();
        WM.buildPage(
            viewPort,
            "VenueMap",
            {
                "update":function(page){
                             page.updateMap();
                         }
            },
            function(page) {
                page.venueMapLat = venuepage.venueMapLat;
                page.venueMapLng = venuepage.venueMapLng;
                page.venueName = venuepage.venueName;
                page.venueTypeUrl = venuepage.venueTypeUrl;
                page.venueAddress = venuepage.venueAddress;
            });
        waiting.hide();
    }

    function showVenuePhotos(venue) {
        WM.buildPage(
            viewPort,
            "PhotosGallery",
            {
                "id": venue,
                "update": function(page) {
                    page.update();
                }
            },
            function(page){
                page.caption = "VENUE PHOTOS";
                page.options.append({"offset":0,"completed":false});
                page.options.append({"offset":0,"completed":false});
                page.photo.connect(function(photo){
                    window.showPhotoPage(photo,page);
                });
                page.change.connect(function(photo) {
                    Script.loadPhoto(WM.topWindow().page,photo);
                });
                page.update.connect(function(){
                    Script.loadVenuePhotos(page,venue);
                });
            });
    }

    function showUserPhotos(user) {
        WM.buildPage(
            viewPort,
            "PhotosGallery",
            {
                "id": user,
                "update": function(page) {
                    page.update();
                }
            },
            function(page){
                page.caption = "USER PHOTOS";
                page.options.append({"offset":0,"completed":false});
                page.photo.connect(function(photo){
                    window.showPhotoPage(photo,page);
                });
                page.change.connect(function(photo) {
                    Script.loadPhoto(WM.topWindow().page,photo);
                });
                page.update.connect(function(){
                    Script.loadUserPhotos(page,user);
                });
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
            });
    }

    function showUserFriends(user) {
        WM.buildPage(
            viewPort,
            "UsersList",
            {
                "id": user,
                "update":function(page){
                     Script.loadUserFriends(page,user);
                 }
            },
            function(page){
                page.user.connect(function(params){
                    window.showUserPage(params);
                });
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
            });
    }

    function showUserCheckins(user) {
        WM.buildPage(
            viewPort,
            "CheckinHistory",
            {
                "id": user,
                "update": function(page){
                        page.update();
                    }
            },
            function(page){
                page.checkin.connect(function(id) {
                    window.showCheckinPage(id)
                });
                page.update.connect(function(){
                    Script.loadCheckinHistory(page,user);
                })
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
            });
    }


    function showPhotoPage(photo, gallery) {
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
                if (gallery !== undefined) {
                    page.nextPhoto.connect(function() {
                        gallery.loadNextPhoto();
                    });
                    page.prevPhoto.connect(function() {
                        gallery.loadPrevPhoto();
                    });
                }
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
                page.badge.connect(function(badge) {
                    window.showBadgeInfo(Script.makeBadgeObject(badge))
                });
                page.tip.connect(function(tip){
                     window.showTipPage(tip);
                });
                page.markRead.connect(function(time) {
                    Script.markNotificationsRead(page,time);
                });
            });
    }

    function showPhotoAddPage(options) {
        WM.buildPage(
            viewPort,
            "PhotoAdd",
            {
                "update": function(page){
                      photoShareDialog.options = options;
                      photoShareDialog.owner = page;
                  }
            },
            function(page) {
                page.uploadPhoto.connect(function(photo){
                    photoShareDialog.photoUrl = photo;
                    photoShareDialog.state = "shown";
                });
            });
    }

    function showTipPage(tip) {
        WM.buildPage(
            viewPort,
            "TipPage",
            {
                "id":tip,
                "update": function(page){
                    Script.loadTipInfo(page,tip);
                }
            },
            function(page){
                page.like.connect(function(state){
                    Script.likeTip(page, tip, state)
                });
                page.user.connect(function(user){
                    window.showUserPage(user)
                });
                page.venue.connect(function(venue){
                    window.showVenuePage(venue);
                });
                page.photo.connect(function(photo){
                    window.showPhotoPage(photo);
                });
                page.save.connect(function(){
                    Script.showError("Lists not implemented yet!");
                });
                page.markDone.connect(function(){
                    Script.showError("Lists not implemented yet!");
                });
            });
    }

    function showTipsList(type, objectid){
        WM.buildPage(
            viewPort,
            "TipsList",
            {
                "id": objectid,
                "update": function(page) {
                      page.update();
                  },
            },
            function(page) {
                page.baseType = type;
                page.tip.connect(function(tip) {
                    window.showTipPage(tip);
                });
                page.update.connect(function(){
                    Script.loadTipsList(page, objectid);
                });
            });
    }

    ThemeLoader {
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
        WaitingIndicator {
            id: waiting
            z: 10
        }

        CheckinDialog {
            id: checkinDialog
            z: 20
            width: parent.width
            state: "hidden"

            onCancel: { checkinDialog.state = "hidden"; }
            onCheckin: {
                var realComment = comment;
                if(realComment === theme.textDefaultComment) {
                    realComment = "";
                }
                Script.addCheckin(venueID, realComment, friends, facebook, twitter);
                checkinDialog.state = "hidden";
            }
        }

        NotificationDialog {
            id: notificationDialog
            z: 20
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
            z: 20
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
            z: 20
            width: parent.width
            state: "hidden"
            onCancel: {tipDialog.state = "hidden";}
            onAddTip: {
                if(tipDialog.action==0) {
                    //console.log("Tip: " + comment + " on " + tipDialog.venueID);
                    Script.addTip(tipDialog.ownerPage, tipDialog.venueID, comment);
                } else {
                    //console.log("mark: " + comment + " on " + tipDialog.venueID);
                    Script.markVenueToDo(tipDialog.venueID, comment);
                }
                tipDialog.state = "hidden";
            }
        }

        PhotoShareDialog {
            id: photoShareDialog
            z: 20
            width: parent.width
            state: "hidden"
            onCancel:{
                photoShareDialog.state="hidden";
            }
            onUploadPhoto: {
                photoShareDialog.state="hidden";
                Script.addPhoto(params);
                WM.popWindow();
            }
        }

        UpdateDialog {
            id: updateDialog
            z: 30
        }

        Item {
            id: signalIcon
            z: 1
            width: 32
            height: 32
            x: parent.width - 40
            y: parent.height - 40
            Image {
                width: 32
                height: 32
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
        color: theme.colors.backgroundMenubar

        MouseArea {
            anchors.fill: parent
        }

        Flow {
            id: menubarToolbar
            //width: menubar.width
            anchors.horizontalCenter: parent.horizontalCenter
            height: menubar.height
            spacing: 15

            ToolbarTextButton {
                id: backwardsButton
                label: "BACK"
                colorActive: theme.colors.textButtonTextMenu
                colorInactive: theme.colors.textButtonTextMenuInactive
                shown: WM.windowStash.length>1
                onClicked: {
                    WM.popWindow();
                }
            }

            ToolbarTextButton {
                label: "FEED"
                selected: topWindowType == "FriendsFeed"
                colorActive: theme.colors.textButtonTextMenu
                colorInactive: theme.colors.textButtonTextMenuInactive
                onClicked: {
                    WM.clearWindows();
                    window.showFriendsFeed();
                }
            }

            ToolbarTextButton {
                label: "PLACES"
                selected: topWindowType == "VenuesList" && WM.topWindow().params.id !== "todolist"
                colorActive: theme.colors.textButtonTextMenu
                colorInactive: theme.colors.textButtonTextMenuInactive
                onClicked: {
                    window.showVenueList("");
                }
            }

            ToolbarTextButton {
                label: "LISTS"
                selected: topWindowType == "VenuesList" && WM.topWindow().params.id === "todolist"
                colorActive: theme.colors.textButtonTextMenu
                colorInactive: theme.colors.textButtonTextMenuInactive
                onClicked: {
                    window.showVenueList("todolist");
                }
            }

            ToolbarTextButton {
                label: "ME"
                selected: topWindowType === "User" && WM.topWindow().params.id === "self"
                colorActive: theme.colors.textButtonTextMenu
                colorInactive: theme.colors.textButtonTextMenuInactive
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
                window.showFriendsFeed();
            }
        }

        onLoadFailed: {

        }
    }

    SplashDialog {
        id: splashDialog

        onLogin: {
            login.reset();
            login.visible = true;
        }
    }
}

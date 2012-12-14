import Qt 4.7
import com.nokia.meego 1.0

import "../components"

import "../js/api-feed.js" as FeedAPI
import "../js/utils.js" as Utils

PageWrapper {
    id: friendsFeed
    signal update()
    signal loadHistory()
    signal user(string userid)
    signal checkin(string checkinid)

    signal shout()
    signal nearby()
    signal recent()

    property bool recentPressed: true
    property bool nearbyPressed: false

    property string lastUpdateTime: "0"
    property string leadingMarker: ""
    property string trailingMarker: ""
    property bool moreData: false

    property int loaded: 0

    property int batchSize: 20

    property bool updating: false

    property alias friendsCheckinsModel: friendsCheckinsModel
    property alias timerFeedUpdate: timerFeedUpdate

    width: parent.width
    height: parent.height
    color: mytheme.colors.backgroundMain

    tools: ToolBarLayout {
        id: commonTools
        visible: true

        ToolIcon {
            platformIconId: "toolbar-refresh"
            onClicked: {
                window.showFriendsFeed();
                friendsCheckinsView.positionViewAtIndex(0,ListView.Center);
            }
        }

        ToolIcon {
            iconSource: "../icons/icon-m-toolbar-venues"+(theme.inverted?"-white":"")+".png"
            onClicked: {
                if (window.pageStack.currentPage.parent.url == Qt.resolvedUrl("../pages/VenuesList.qml")) {
                    window.pageStack.replace(Qt.resolvedUrl("../pages/VenuesList.qml"),{},true);
                } else {
                    window.pageStack.push(Qt.resolvedUrl("../pages/VenuesList.qml"));
                }
            }
        }

        ToolIcon {
            iconSource: "../icons/icon-m-toolbar-list"+(theme.inverted?"-white":"")+".png"
            onClicked: {
                FeedAPI.showError("Lists not implemented yet!");
            }
        }

        ToolIcon {
            iconSource: "../icons/icon-m-toolbar-contact"+(theme.inverted?"-white":"")+".png"
            onClicked: {
                 window.pageStack.push(Qt.resolvedUrl("../pages/User.qml"),{"userID":"self"});
            }
        }
    }

    function reset() {
        moreData = false;
        loaded = 0;
        friendsCheckinsModel.clear();

        lastUpdateTime = "0";
        leadingMarker = "";
        trailingMarker = "";
    }

    function addItem(item, position) {
        if (position === undefined) {
            friendsCheckinsModel.append(item);
        } else {
            friendsCheckinsModel.insert(position,item);
        }

        if (configuration.feedAutoUpdate!== "0"
                && configuration.feedIntegration !=="0") {
            platformUtils.addFeedItem(item);
        }
    }

    function updateItem(position, update) {
        friendsCheckinsModel.set(position, update);
        if (configuration.feedIntegration !=="0") {
            var item = JSON.parse(JSON.stringify(friendsCheckinsModel.get(position)))
            platformUtils.updateFeedItem(item);
        }
    }

    function removeItem(position) {
        if (configuration.feedIntegration !=="0") {
            var item = JSON.parse(JSON.stringify(friendsCheckinsModel.get(position)));
            platformUtils.removeFeedItem(item);
        }
        friendsCheckinsModel.remove(position);
    }

    function load() {
        var page = friendsFeed;
        page.update.connect(function(lastupdate) {
            if (configuration.feedAutoUpdate === 0) {
                page.reset();
            }
            FeedAPI.loadFriendsFeed(page)
        });
        page.loadHistory.connect(function(){
            console.log("FEED: loading history");
            FeedAPI.loadFriendsFeed(page,true);
        });
        page.recent.connect(function() {
            page.reset();
            FeedAPI.loadFriendsFeed(page);
        });
        page.nearby.connect(function() {
            page.reset();
            FeedAPI.loadFriendsFeed(page);
        });
        page.checkin.connect(function(id) {
            pageStack.push(Qt.resolvedUrl("Checkin.qml"),{"checkinID":id});
        });
        page.user.connect(function(id){
            pageStack.push(Qt.resolvedUrl("User.qml"),{"userID":id});
        });
        timerFeedUpdate.restart(); //Start autoupdate
        update();
    }

    Timer {
        id: timerFeedUpdate
        interval: configuration.feedAutoUpdate * 1000
        repeat: true
        onTriggered: {
            friendsFeed.update()
            //console.log("update triggered");
        }
    }

    ListModel {
        id: friendsCheckinsModel
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { }
    }

    ListView {
        id: friendsCheckinsView
        model: friendsCheckinsModel
        width: parent.width
        height: parent.height - y
        delegate: friendsFeedDelegate
        //highlightFollowsCurrentItem: true
        //clip: true
        cacheBuffer: 400
        spacing: 10

        header: Column{
            width: parent.width
            Rectangle {
                width: parent.width
                height: 90
                color: mytheme.colors.toolbarDarkColor

                ButtonBlue {
                    label: "RECENT"
                    y: 20
                    x: 10
                    width:  parent.width/2-15
                    height: 50
                    pressed: friendsFeed.recentPressed
                    onClicked: {
                        if(friendsFeed.recentPressed==false) {
                            friendsFeed.recentPressed = true;
                            friendsFeed.nearbyPressed = false;
                            friendsFeed.recent();
                        }                        
                    }
                }
                ButtonBlue {
                    label: "NEARBY"
                    y: 20
                    x: parent.width/2+5
                    width: parent.width/2-15
                    height: 50
                    pressed: friendsFeed.nearbyPressed
                    onClicked: {
                        if(friendsFeed.nearbyPressed==false) {
                            friendsFeed.recentPressed = false;
                            friendsFeed.nearbyPressed = true;
                            friendsFeed.nearby();
                        }
                    }
                }
            }

            LineGreen {
                height: 30
                text: "FRIENDS ACTIVITY"
            }
        }
    }

    Component {
        id: friendsFeedDelegate

        EventBox {
            id: eventbox
            activeWhole: true

            userName: model.user
            userShout: model.shout
            userMayor: model.mayor
            venueName: model.venueName
            venuePhoto: model.venuePhoto
            createdAt: model.createdAt
            commentsCount: model.commentsCount
            photosCount: model.photosCount
            likesCount: model.likesCount

            Component.onCompleted: {
                userPhoto.photoUrl = model.photo

                //console.log("LOADED: " + loaded + " index:"+ (index+1));
                if (loaded === (index + 1)){
                    if (moreData) {
                        loadHistory();
                    }
                }
            }

            onAreaClicked: {
                if (model.id) {
                    friendsFeed.checkin( model.id );
                } else {
                    friendsFeed.user( model.userID );
                }
            }
        }
    }
}

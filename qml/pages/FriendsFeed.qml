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
    property bool isUpdating: false

    property int loaded: 0

    property int batchSize: 20

    property alias friendsCheckinsModel: friendsCheckinsModel
    property alias timerFeedUpdate: timerFeedUpdate

    headerText: "FRIENDS FEED"

    width: parent.width
    height: parent.height
    color: mytheme.colors.backgroundMain

    function show_error(msg) {
        isUpdating = false;
        show_error_base(msg);
    }

    function reset() {
        moreData = false;
        isUpdating = false;
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
            stack.push(Qt.resolvedUrl("Checkin.qml"),{"checkinID":id});
        });
        page.user.connect(function(id){
            stack.push(Qt.resolvedUrl("User.qml"),{"userID":id});
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
        anchors.top: pagetop
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

                ButtonRow {
                    anchors.centerIn: parent

                    Button {
                        text: "RECENT"
                        height: 50
                        checkable: true
                        checked: friendsFeed.recentPressed
                        onClicked: {
                            if(friendsFeed.recentPressed==false) {
                                friendsFeed.recentPressed = true;
                                friendsFeed.nearbyPressed = false;
                                friendsFeed.recent();
                            }
                        }
                        //platformStyle: ButtonStyle {}
                    }
                    Button {
                        text: "NEARBY"
                        height: 50
                        checkable: true
                        checked: friendsFeed.nearbyPressed
                        onClicked: {
                            if(friendsFeed.nearbyPressed==false) {
                                friendsFeed.recentPressed = false;
                                friendsFeed.nearbyPressed = true;
                                friendsFeed.nearby();
                            }
                        }
                        //platformStyle: ButtonStyle {}
                    }
                }
            }
        }

        footer: Column{
            width: parent.width
            ToolButton {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Load More"
                visible: moreData
                onClicked: {
                    moreData = false;
                    loadHistory();
                }
            }
            Item {
                width: parent.width
                height: 20
            }
        }
    }

    ScrollDecorator{ flickableItem: friendsCheckinsView }

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
                /*if (loaded === (index + 1)){
                    if (moreData) {
                        loadHistory();
                    }
                }*/
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

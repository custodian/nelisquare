import Qt 4.7
import com.nokia.meego 1.0

import "../components"

import "../js/api.js" as Api

PageWrapper {
    id: friendsFeed
    signal update()
    signal loadHistory()
    signal user(string userid)
    signal checkin(string checkinid)
    signal venue(string tipid)

    signal shout()
    signal nearby()
    signal recent()

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

    /*headerText: nearbyPressed ? "NEARBY FRIENDS FEED" : "RECENT FRIENDS FEED"
    headerSelectionTitle: "Feed type"
    headerSelectionItems: ListModel {
        ListElement {name:"Recent activity"}
        ListElement {name:"Nearby activity"}
    }*/
    headerText: "FRIENDS FEED"

    width: parent.width
    height: parent.height
    color: mytheme.colors.backgroundMain

    onHeaderSelectedItem: {
        nearbyPressed = index;
        update();
    }

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
        loaded += 1;
        if (position === undefined) {
            friendsCheckinsModel.append(item);
        } else {
            friendsCheckinsModel.insert(position,item);
        }

        if (configuration.feedAutoUpdate!== "0"
                && configuration.feedIntegration !=="0") {

            //TODO: //BUG: need to make an callback to addFeedItem with filled photoCache item
            /*function ObjCallbacker() {
                this.text = "testObject";
                this.cacheCallback = function cacheCallback(status,url) {
                         console.log("in callback by cache");
                         if (!status) return;
                         item.photoCached = url;
                         console.log("adding object");
                         platformUtils.addFeedItem(item);
                     };
            }
            var callbacker = new ObjCallbacker();
            cache.get(item.photo, callbacker);*/
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
            Api.feed.loadFriendsFeed(page)
        });
        page.loadHistory.connect(function(){
            console.log("FEED: loading history");
            Api.feed.loadFriendsFeed(page,true);
        });
        page.recent.connect(function() {
            page.reset();
            Api.feed.loadFriendsFeed(page);
        });
        page.nearby.connect(function() {
            page.reset();
            Api.feed.loadFriendsFeed(page);
        });
        page.checkin.connect(function(id) {
            stack.push(Qt.resolvedUrl("Checkin.qml"),{"checkinID":id});
        });
        page.user.connect(function(id){
            stack.push(Qt.resolvedUrl("User.qml"),{"userID":id});
        });
        page.venue.connect(function(id) {
            stack.push(Qt.resolvedUrl("Venue.qml"), {"venueID":id});
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

    ListViewEx {
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

        onRefreshEvent: {
            update();
        }

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
                        checked: !friendsFeed.nearbyPressed
                        onClicked: {
                            if(nearbyPressed) {
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
                            if(!nearbyPressed) {
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

        Loader {
            width: friendsCheckinsView.width
            function getComponentByType(type) {
                if (type === "checkin")
                    return friendsFeedDelegateEvent
                else if (type === "friend")
                    return friendsFeedDelegateFriend
                else if (type === "tip")
                    return friendsFeedDelegateTip
                else if (type === "savelist")
                    return friendsFeedDelegateSaveList
                else
                    return testComponent
            }
            property variant content: model //DBG: .content
            sourceComponent: getComponentByType(model.type)
        }
    }

    Component {
        id: testComponent

        Text {
            color: mytheme.colors.textColorOptions
            font.pixelSize: mytheme.font.sizeSigns
            text: content.type + " event"
        }
    }

    Component {
        id: friendsFeedDelegateFriend

        EventBox {
            id: eventbox
            activeWhole: true

            userName: content.user
            createdAt: content.createdAt

            Component.onCompleted: {
                userPhoto.photoUrl = "https://ss0.4sqi.net/img/icon-friendrequests-1c69ce8a7660d4c9bdd0a4395c72753c.png";
            }

            onAreaClicked: {
                friendsFeed.user( content.id );
            }
        }
    }

    Component {
        id: friendsFeedDelegateTip

        EventBox {
            //id: eventbox
            activeWhole: true

            userName: content.userName
            userShout: content.shout
            venueName: content.venueName
            venuePhoto: content.venuePhoto
            createdAt: content.createdAt
            likesCount: content.likesCount

            Component.onCompleted: {
                userPhoto.photoUrl = content.photo
            }

            onAreaClicked: {
                friendsFeed.venue( content.id );
            }
        }
    }

    Component {
        id: friendsFeedDelegateSaveList

        EventBox {
            //id: eventbox
            activeWhole: true

            userName: content.user
            venueName: content.listName
            userShout: content.shout
            venuePhoto: content.venuePhoto
            createdAt: content.createdAt
            likesCount: content.likesCount

            Component.onCompleted: {
                userPhoto.photoUrl = content.photo
            }

            onAreaClicked: {
                //friendsFeed.list( content.id );
                show_error("Sorry, no lists support yet :(");
            }
        }
    }

    Component {
        id: friendsFeedDelegateEvent

        EventBox {
            //id: eventbox
            activeWhole: true

            userName: content.user
            userShout: content.shout
            userMayor: content.mayor
            venueName: content.venueName
            venuePhoto: content.venuePhoto
            createdAt: content.createdAt
            commentsCount: content.commentsCount
            photosCount: content.photosCount
            likesCount: content.likesCount
            comments: content.comments

            Component.onCompleted: {
                userPhoto.photoUrl = content.photo
            }

            onAreaClicked: {
                friendsFeed.checkin( content.id );
            }
        }
    }
}

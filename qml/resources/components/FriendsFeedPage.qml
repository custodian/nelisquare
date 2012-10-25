import Qt 4.7

Rectangle {
    id: friendsFeed
    signal clicked(string checkinid)
    signal shout()
    signal nearby()
    signal recent()

    property bool recentPressed: true
    property bool nearbyPressed: false

    property alias friendsCheckinsModel: friendsCheckinsModel

    width: parent.width
    height: parent.height
    color: theme.backgroundMain
    state: "hidden"

    ListModel {
        id: friendsCheckinsModel
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { }
    }

    ListView {
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
                color: theme.toolbarDarkColor

                BlueButton {
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
                BlueButton {
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

            GreenLine {
                height: 30
                text: "FRIENDS ACTIVITY"
            }
        }
    }

    Component {
        id: friendsFeedDelegate

        EventBox {
            activeWhole: true

            userName: model.user
            userShout: model.shout
            userMayor: model.mayor
            venueName: model.venueName
            venuePhoto: model.venuePhoto
            createdAt: model.createdAt
            commentsCount: model.commentsCount

            Component.onCompleted: {
                userPhoto.photoUrl = model.photo
            }

            onAreaClicked: {
                friendsFeed.clicked( model.id );
            }
        }
    }

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: friendsFeed
                x: parent.width
            }
        },
        State {
            name: "hiddenLeft"
            PropertyChanges {
                target: friendsFeed
                x: -parent.width
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: friendsFeed
                x: 0
            }
        }
    ]

    transitions: [
        Transition {
            from: "shown"
            SequentialAnimation {
                PropertyAnimation {
                    target: friendsFeed
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }                
                PropertyAction {
                    target: friendsFeed
                    properties: "visible"
                    value: false
                }
            }
        },
        Transition {
            to: "shown"
            SequentialAnimation {
                PropertyAction {
                    target: friendsFeed
                    properties: "visible"
                    value: true
                }
                PropertyAnimation {
                    target: friendsFeed
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}

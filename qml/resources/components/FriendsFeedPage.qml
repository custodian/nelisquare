import Qt 4.7

Rectangle {
    id: friendsFeed
    signal clicked(int index)
    signal shout()
    signal nearby()
    signal recent()
    property bool recentPressed: true
    property bool nearbyPressed: false
    width: parent.width
    color: "#eee"
    state: "hidden"

    MouseArea {
        anchors.fill: parent
        onClicked: { }
    }

    ListView {
        model: friendsCheckinsModel
        width: parent.width
        height: parent.height - y
        delegate: friendsFeedDelegate
        highlightFollowsCurrentItem: true
        clip: true

        header: Column{
            width: parent.width
            Rectangle {
                width: parent.width
                height: 100
                color: theme.toolbarDarkColor

                BlueButton {
                    label: "RECENT"
                    y: 30
                    x: 10
                    width:  parent.width/2-15
                    height: 50
                    pressed: friendsFeed.recentPressed
                    onClicked: {
                        if(friendsFeed.recentPressed==false) {
                            friendsFeed.recent();
                        }
                    }
                }
                BlueButton {
                    label: "NEARBY"
                    y: 30
                    x: parent.width/2+5
                    width: parent.width/2-15
                    height: 50
                    pressed: friendsFeed.nearbyPressed
                    onClicked: {
                        if(friendsFeed.nearbyPressed==false) {
                            friendsFeed.nearby();
                        }
                    }
                }
            }
            Rectangle {
                width: parent.width
                height: 10
                /*color: "#A8CB17"

                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#A8CB17"
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#888"
                    y: 9
                }*/
                gradient: theme.gradientGreen
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
            likes: model.likes

            Component.onCompleted: {
                userPhoto.photoUrl = model.photo
            }

            onAreaClicked: {
                friendsFeed.clicked( index );
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

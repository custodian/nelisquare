import Qt 4.7

Rectangle {
    id: friendsCheckinsList
    signal clicked(int index)
    signal shout()
    signal nearby()
    signal recent()
    property bool recentPressed: true
    property bool nearbyPressed: false
    width: parent.width
    color: "#eee"

    MouseArea {
        anchors.fill: parent
        onClicked: { }
    }

    ListView {
        y: 110
        model: friendsCheckinsModel
        width: parent.width
        height: parent.height - y
        delegate: friendsCheckinsListDelegate
        highlightFollowsCurrentItem: true
    }

    Rectangle {
        width: parent.width
        height: 100
        color: theme.toolbarLightColor

        Rectangle {
            width: parent.width-20
            y: 20
            x: 10
            color: theme.toolbarDarkColor
            border.color: "#2774aA"
            border.width: 1
            height: 70
            radius: 5
            smooth: true

            BlueButton {
                label: "Recent"
                y: 10
                x: 10
                width:  parent.width/2-15
                height: 50
                pressed: friendsCheckinsList.recentPressed
                onClicked: {
                    if(friendsCheckinsList.recentPressed==false) {
                        friendsCheckinsList.recent();
                    }
                }
            }
            BlueButton {
                label: "Nearby"
                y: 10
                x: parent.width/2+5
                width: parent.width/2-15
                height: 50
                pressed: friendsCheckinsList.nearbyPressed
                onClicked: {
                    if(friendsCheckinsList.nearbyPressed==false) {
                        friendsCheckinsList.nearby();
                    }
                }
            }
        }

    }

    Rectangle {
        width: parent.width
        height: 10
        color: "#A8CB17"
        y: 100

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
        }
    }

    Image {
        id: shadow
        source: "../pics/top-shadow.png"
        width: parent.width
        y: 110
    }

    Component {
        id: friendsCheckinsListDelegate

        EventBox {
            activeWhole: true

            userName: model.user
            userShout: model.shout
            venueName: model.venueName
            venuePhoto: model.venuePhoto
            createdAt: model.createdAt
            comments: model.comments

            Component.onCompleted: {
                userPhoto.photoUrl = model.photo
            }

            onAreaClicked: {
                friendsCheckinsList.clicked( index );
            }
        }
    }

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: friendsCheckinsList
                x: parent.width
            }
        },
        State {
            name: "hiddenLeft"
            PropertyChanges {
                target: friendsCheckinsList
                x: -parent.width
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: friendsCheckinsList
                x: 0
            }
        }
    ]

    transitions: [
        Transition {
            SequentialAnimation {
                PropertyAnimation {
                    target: friendsCheckinsList
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}

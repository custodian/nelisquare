import Qt 4.7

Rectangle {
    signal openLeaderboard()
    signal user(string user)

    signal addFriend(string user)
    signal removeFriend(string user)
    signal approveFriend(string user)

    signal badges(string user)
    signal checkins(string user)
    signal mayorships(string user)


    id: details
    width: parent.width
    height: parent.height
    color: theme.backgroundMain
    state: "hidden"

    property string userID: ""
    property string userName: ""
    property string userPhoto: ""
    property int userBadgesCount: 0
    property int userMayorshipsCount: 0
    property int userCheckinsCount: 0
    property int userFriendsCount: 0
    property string userRelationship: ""

    property int userLeadersboardRank: 0

    property int scoreRecent: 0
    property int scoreMax: 0

    property string lastVenue: ""
    property string lastTime: ""

    property alias friendsBox: friendsBox
    property alias boardModel: boardModel

    ListModel {
        id: boardModel
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { }
    }

    Flickable{

        id: flickableArea
        width: parent.width
        contentWidth: parent.width
        height: details.height - y

        clip: true
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds
        pressDelay: 100

        Column {
            onHeightChanged: {
                flickableArea.contentHeight = height + y + spacing;
            }

            width: parent.width - 20
            y: 10
            x: 10
            spacing: 10

            Item {
                width: parent.width
                height: 64

                ProfilePhoto {
                    id: profileImage
                    //photoSize: 150
                    photoUrl: details.userPhoto
                }

                Text {
                    text: details.userName
                    x: 74//164
                    font.pixelSize: 22
                    font.bold: true
                    color: "#111"
                }
                Text {
                    x: 74//164
                    y: 32
                    text: details.lastTime + " @ " + details.lastVenue
                    font.pixelSize: 20
                    color: "#888"
                }
            }

            GreenButton {
                anchors.horizontalCenter: parent.horizontalCenter
                label: "Add Friend"
                width: parent.width - 130
                onClicked: {
                    details.addFriend(userID);
                }
                visible: userRelationship == ""
            }

            BlueButton {
                anchors.horizontalCenter: parent.horizontalCenter
                label: "Approve Friend"
                width: parent.width - 130
                onClicked: {
                    details.approveFriend(userID);
                }
                visible: userRelationship == "pendingMe"
            }

            ButtonEx {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 130
                label: "Remove Friend"
                onClicked: {
                    details.removeFriend(userID);
                }
                visible: (userRelationship == "friend" || userRelationship == "pendingThem")
            }

            //scores title
            Item {
                width: parent.width
                height: children[0].height
                Text {
                    id: lblScoresText
                    text: "<b>SCORES</b> (LAST 7 DAYS)"
                    font.pixelSize: theme.font.sizeHelp
                }
                Text {
                    text: "BEST SCORE"
                    anchors.right: parent.right
                    font.pixelSize: theme.font.sizeHelp
                    font.bold: true
                }
            }
            //scores value
            Item {
                width: parent.width
                height: children[0].height
                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    height: 32
                    width: parent.width * 0.85
                    color: theme.scoreBackgroundColor
                }
                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    height: 32
                    width: parent.width * 0.85 * scoreRecent / scoreMax
                    color: theme.scoreForegroundColor
                    onWidthChanged: {
                        if (width > 50) {
                            scoreRecentText.anchors.left = undefined;
                            scoreRecentText.anchors.right = right;
                        } else {
                            scoreRecentText.anchors.right = undefined;
                            scoreRecentText.anchors.left = right;
                        }
                    }
                    Text {
                        id: scoreRecentText
                        text: "  " + scoreRecent + "  "
                        font.pixelSize: theme.font.sizeHelp
                        anchors.verticalCenter: parent.verticalCenter
                        color: theme.textColorSign
                        visible: scoreRecent>0

                    }
                }
                Text {
                    text: scoreMax
                    anchors.right: parent.right
                    color: theme.scoreForegroundColor
                    font.bold: true
                    font.pixelSize: theme.font.sizeHelp
                }
            }
            Rectangle {
                width: parent.width
                height: 1
                color: "#ccc"
            }

            PhotosBox {
                id: friendsBox
                showButtons: false
                photoSize: 64
                caption: ""

                onItemSelected: {
                    details.user(object)
                }
            }

            Item {
                width: parent.width
                height: 120

                Rectangle {
                    id: badgesCount
                    x: 10
                    y: 10
                    width: (parent.width - 20) / 3 - 10
                    height: 100
                    color: theme.backgroundSand
                    smooth: true
                    radius: 5

                    Image {
                        y: 10
                        width: 64
                        height: 64
                        source: cache.get("https://playfoursquare.s3.amazonaws.com/badge/114/newbie.png")
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: parent.height - height - 2
                        color: theme.textColorOptions
                        font.pixelSize: 20
                        text: details.userBadgesCount + " " + "Badges"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            details.badges(userID);
                        }
                    }
                }

                Rectangle {
                    id: checkinsCount
                    x: badgesCount.x + badgesCount.width + 10
                    y: 10
                    width: (parent.width - 20) / 3 - 10
                    height: 100
                    color: theme.backgroundSand
                    smooth: true
                    radius: 5

                    Image {
                        y: 10
                        width: 64
                        height: 64
                        source: cache.get("https://playfoursquare.s3.amazonaws.com/badge/114/bender.png")
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: parent.height - height - 2
                        color: theme.textColorOptions
                        font.pixelSize: 20
                        text: details.userCheckinsCount + " " + "Checkins"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (userRelationship == "self") {
                                details.checkins(userID);
                            }
                        }
                    }
                }

                Rectangle {
                    id: mayorCount
                    x: checkinsCount.x + checkinsCount.width + 10
                    y: 10
                    width: (parent.width - 20) / 3 - 10
                    height: 100
                    color: theme.backgroundSand
                    smooth: true
                    radius: 5

                    Image {
                        y: 10
                        width: 64
                        height: 64
                        source: cache.get("https://playfoursquare.s3.amazonaws.com/badge/114/supermayor.png")
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: parent.height - height - 2
                        color: theme.textColorOptions
                        font.pixelSize: 20
                        text: details.userMayorshipsCount + " " + "Mayorships"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            details.mayorships(userID);
                        }
                    }
                }
            }

            GreenLine {
                height: 40
                text: "YOU ARE #" + userLeadersboardRank

                visible: userRelationship == "self"
            }

            Repeater {
                id: miniLeadersboard
                model: boardModel
                width: parent.width
                delegate: leaderBoardDelegate
                clip: true
                visible: userRelationship == "self"
            }

        }
    }

    Component {
        id: leaderBoardDelegate

        EventBox {
            activeWhole: true
            width: miniLeadersboard.width

            userName: model.user
            //userShout:
            createdAt: model.shout

            Component.onCompleted: {
                userPhoto.photoUrl = model.photo
            }

            onAreaClicked: {
                details.openLeaderboard();
            }
        }
    }

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: details
                x: parent.width
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: details
                x: 0
            }
        }
    ]

    transitions: [
        Transition {
            from: "shown"
            SequentialAnimation {
                PropertyAnimation {
                    target: details
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
                PropertyAction {
                    target: details
                    properties: "visible"
                    value: false
                }
            }
        },
        Transition {
            to: "shown"
            SequentialAnimation {
                PropertyAction {
                    target: details
                    properties: "visible"
                    value: true
                }
                PropertyAnimation {
                    target: details
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}

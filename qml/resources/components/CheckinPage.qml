import Qt 4.7

Rectangle {
    signal like(string checkin, bool state)
    signal venue()
    signal user(string user)
    signal photo(string photo)
    signal showAddComment()
    signal deleteComment(string commentID)
    signal showAddPhoto()
    y: 10
    id: checkin

    width: parent.width
    height: parent.height
    color: "#eee"
    state: "hidden"

    property string checkinID: ""

    property alias scoreTotal: scoreTotal.text
    property alias owner: checkinOwner

    property alias likeBox: likeBox

    property alias scoresModel: scoresModel
    property alias badgesModel: badgesModel
    property alias commentsModel: commentsModel
    property alias photosBox: photosBox
    ListModel {
        id: scoresModel
    }

    ListModel {
        id: badgesModel
    }

    ListModel {
        id: commentsModel
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
        }
    }

    Flickable {
        id: flickableArea
        width: parent.width
        contentWidth: parent.width
        height: checkin.height - y

        clip: true
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds
        pressDelay: 100

        Rectangle {
            id: scoreBackground
            y: scoreHolder.y - columnView.spacing
            width: parent.width
            height: scoreHolder.height + 2 * columnView.spacing
            gradient: theme.gradientDarkBlue
        }

        Column {
            onHeightChanged: {
                flickableArea.contentHeight = height + scoreBackground.height - scoreBackground.y;
            }

            id: columnView
            x: 10
            width: parent.width - 20
            spacing: 10

            EventBox {
                id: checkinOwner
                width: parent.width
                showRemoveButton: false
                showSeparator: false

                onUserClicked: {
                    checkin.user(checkin.owner.userID);
                }
                onAreaClicked: {
                    checkin.venue();
                }
            }

            Column {
                id: scoreHolder
                width: parent.width

                Row {
                    id: scoreCaption
                    x: 10
                    width: parent.width - 20
                    spacing: 10
                    Text {
                        width: parent.width * 0.90
                        text: "TOTAL POINTS"
                        color: theme.textColorSign
                        font.pixelSize: theme.font.sizeDefault
                    }
                    Text {
                        id: scoreTotal
                        color: theme.textColorSign
                        font.pixelSize: theme.font.sizeDefault
                    }
                }

                Repeater {
                    id: scoreRepeater
                    width: parent.width
                    model: scoresModel
                    delegate: scoreDelegate
                    visible: scoresModel.count>0
                }
            }

            LikeBox {
                id: likeBox

                onLike: {
                    checkin.like(checkin.checkinID,state);
                }
            }

            GreenLine {
                text: "Earned badges"
                height: 30
                size: theme.font.sizeDefault
                visible: badgesModel.count>0
            }

            Repeater {
                id: badgeRepeater
                width: parent.width
                model: badgesModel
                delegate: badgeDelegate
                visible: badgesModel.count>0
            }

            Rectangle {
                width: parent.width
                height: 1
                color: "#ccc"
                visible: badgesModel.count>0
            }

            PhotosBox {
                id: photosBox
                onItemSelected: {
                    checkin.photo(object);
                }
            }

            GreenLine {
                text: "Comments"
                height: 30
                size: theme.font.sizeDefault
                visible: commentsModel.count>0
            }

            Repeater {
                id: commentRepeater
                width: parent.width
                model: commentsModel
                delegate: commentDelegate
                visible: commentsModel.count>0
            }

            Row {
                width:parent.width
                spacing: 10

                BlueButton {
                    id: btnAddPhoto
                    label: "Add photo"
                    width: 150

                    onClicked: {
                        checkin.showAddPhoto()
                    }
                    visible: checkin.owner.eventOwner == "self"
                }

                BlueButton{
                    label: "Add comment"
                    width: parent.width - (btnAddPhoto.visible?btnAddPhoto.width:0) - parent.spacing
                    onClicked: {
                        checkin.showAddComment();
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: "#ccc"
            }
        }
    }

    Component {
        id: commentDelegate

        EventBox {
            width: commentRepeater.width
            userName: model.user
            userShout: model.shout
            createdAt: model.createdAt
            eventOwner: model.owner

            Component.onCompleted: {
                userPhoto.photoUrl = model.photo
            }

            onUserClicked: {
                checkin.user(model.userID);
            }
            onDeleteEvent: {
                checkin.deleteComment(model.commentID);
            }
        }

    }

    Component {
        id: scoreDelegate

        Row {
            x: 10
            width: scoreRepeater.width - 20
            spacing: 10
            Image {
                source: cache.get(scoreImage)
                smooth: true
                width: 24
                height: 24
            }
            Text {
                width: parent.width * 0.8
                wrapMode: Text.Wrap
                text: scoreMessage
                color: theme.textColorSign
                font.pixelSize: theme.font.sizeSigns
            }
            Text {
                wrapMode: Text.NoWrap
                text: "+"+scorePoints
                color: theme.textColorSign
                font.pixelSize: theme.font.sizeSigns
            }
        }
    }

    Component {
        id: badgeDelegate

        Row {
            width: badgeRepeater.width
            Column {
                width: badgeRepeater.width - 105
                Text {
                    width: badgeRepeater.width * 0.95
                    text: badgeTitle
                    font.pixelSize: 24
                }
                Text {
                    width: parent.width * 0.8
                    wrapMode: Text.Wrap
                    text: badgeMessage
                    color: "#111"
                    font.pixelSize: 18
                }
            }
            Image {
                source: badgeImage
                smooth: true
                width: 100
                height: 100
            }
        }
    }

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: checkin
                x: parent.width
            }
        },
        State {
            name: "hiddenLeft"
            PropertyChanges {
                target: checkin
                x: -parent.width
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: checkin
                x: 0
            }
        }
    ]

    transitions: [
        Transition {
            from: "shown"
            SequentialAnimation {
                PropertyAnimation {
                    target: checkin
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
                PropertyAction {
                    target: checkin
                    properties: "visible"
                    value: false
                }
            }
        },
        Transition {
            to: "shown"
            SequentialAnimation {
                PropertyAction {
                    target: checkin
                    properties: "visible"
                    value: true
                }
                PropertyAnimation {
                    target: checkin
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}

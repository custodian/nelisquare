import Qt 4.7
import "../components"

Rectangle {
    signal like(bool state)
    signal user(string user)
    signal venue(string venueID)
    signal photo(string photoID)
    signal save()
    signal markDone()

    id: tipPage
    width: parent.width
    height: parent.height
    color: theme.colors.backgroundMain
    state: "hidden"

    property alias ownerVenue: ownerVenue
    property alias ownerUser: ownerUser
    property alias likeBox: likeBox
    property alias tipPhoto: tipPhoto
    property string tipPhotoID: ""

    Flickable{
        id: flickableArea
        width: parent.width
        height: parent.height
        contentWidth: parent.width

        clip: true
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds
        pressDelay: 100

        Column {
            x: 10
            y: 20
            width: parent.width - 20
            spacing: 20

            onHeightChanged: {
                flickableArea.contentHeight = y + height + spacing;
            }

            EventBox {
                id: ownerVenue
                activeWhole: true

                onAreaClicked: {
                    tipPage.venue(venueID);
                }
            }

            EventBox {
                id: ownerUser
                activeWhole: true

                onAreaClicked: {
                    tipPage.user(userID);
                }
            }

            LikeBox {
                id: likeBox
                onLike: {
                    tipPage.like(state);
                }
            }

            ProfilePhoto{
                id: tipPhoto
                photoWidth: parent.width
                photoHeight: 300
                visible: tipPhotoID!=""

                onClicked: {
                    tipPage.photo(tipPhotoID);
                }
            }

            Row {
                width: parent.width
                spacing: 10

                ButtonBlue {
                    label: "Save tip"
                    width: (parent.width - 10)/2
                    onClicked: {
                        tipPage.save();
                    }
                }

                ButtonBlue {
                    label: "Mark as done"
                    width: (parent.width - 10)/2
                    onClicked: {
                        tipPage.markDone();
                    }
                }
            }

        }
    }

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: tipPage
                x: parent.width
            }
        },
        State {
            name: "hiddenLeft"
            PropertyChanges {
                target: tipPage
                x: -parent.width
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: tipPage
                x: 0
            }
        }
    ]

    transitions: [
        Transition {
            from: "shown"
            SequentialAnimation {
                PropertyAnimation {
                    target: tipPage
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
                PropertyAction {
                    target: tipPage
                    properties: "visible"
                    value: false
                }
            }
        },
        Transition {
            to: "shown"
            SequentialAnimation {
                PropertyAction {
                    target: tipPage
                    properties: "visible"
                    value: true
                }
                PropertyAnimation {
                    target: tipPage
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}

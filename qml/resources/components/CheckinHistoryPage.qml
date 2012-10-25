import Qt 4.7

Rectangle {
    id: checkinHistory
    signal checkin(string id)
    property alias checkinHistoryModel: checkinHistoryModel
    width: parent.width
    height: parent.height
    color: theme.backgroundMain
    state: "hidden"

    ListModel {
        id: checkinHistoryModel
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { }
    }

    ListView {
        model: checkinHistoryModel
        width: parent.width
        height: parent.height - y
        delegate: checkinHistoryDelegate
        //highlightFollowsCurrentItem: true
        clip: true
        cacheBuffer: 400

        header: GreenLine{
            height: 30
            text: "CHECKIN HISTORY"
        }
    }

    Component {
        id: checkinHistoryDelegate

        EventBox {
            activeWhole: true

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
                checkinHistory.checkin( model.id );
            }
        }
    }

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: checkinHistory
                x: parent.width
            }
        },
        State {
            name: "hiddenLeft"
            PropertyChanges {
                target: checkinHistory
                x: -parent.width
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: checkinHistory
                x: 0
            }
        }
    ]

    transitions: [
        Transition {
            from: "shown"
            SequentialAnimation {
                PropertyAnimation {
                    target: checkinHistory
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }                
                PropertyAction {
                    target: checkinHistory
                    properties: "visible"
                    value: false
                }
            }
        },
        Transition {
            to: "shown"
            SequentialAnimation {
                PropertyAction {
                    target: checkinHistory
                    properties: "visible"
                    value: true
                }
                PropertyAnimation {
                    target: checkinHistory
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}

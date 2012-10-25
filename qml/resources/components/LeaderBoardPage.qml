import Qt 4.7

Rectangle {
    id: leaderBoard
    signal user( string user )
    property string rank: ""

    property alias boardModel: boardModel

    width: parent.width
    height: parent.height

    color: theme.backgroundMain
    state: "hidden"

    MouseArea {
        anchors.fill: parent
        onClicked: { }
    }

    ListModel {
        id: boardModel
    }

    ListView {
        y: 40
        model: boardModel
        width: parent.width
        height: parent.height - y
        delegate: leaderBoardDelegate
        //highlightFollowsCurrentItem: true
        clip: true

        spacing: 5
    }

    GreenLine {
        height: 40
        text: "YOU ARE #" + leaderBoard.rank
    }

    Image {
        id: shadow
        source: "../pics/top-shadow.png"
        width: parent.width
        y: 40
    }

    Component {
        id: leaderBoardDelegate

        EventBox {
            activeWhole: true
            width: leaderBoard.width

            userName: "#" + model.rank + ". " + model.name
            //userShout:
            createdAt: "<b>"+model.recent+" "+"points" + "</b> " + model.checkinsCount + " " + "checkins"

            Component.onCompleted: {
                userPhoto.photoUrl = model.photo
            }

            onAreaClicked: {
                window.showUserPage(model.user);
            }
        }
    }

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: leaderBoard
                x: parent.width
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: leaderBoard
                x: 0
            }
        }
    ]

    transitions: [
        Transition {
            from: "shown"
            SequentialAnimation {
                PropertyAnimation {
                    target: leaderBoard
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
                PropertyAction {
                    target: leaderBoard
                    properties: "visible"
                    value: false
                }
            }
        },
        Transition {
            to: "shown"
            SequentialAnimation {
                PropertyAction {
                    target: leaderBoard
                    properties: "visible"
                    value: true
                }
                PropertyAnimation {
                    target: leaderBoard
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}

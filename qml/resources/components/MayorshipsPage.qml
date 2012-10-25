import Qt 4.7

Rectangle {
    id: mayorships
    signal venue(string id)
    property alias mayorshipsModel: mayorshipsModel

    width: parent.width
    height: parent.height

    color: "#eee"
    state: "hidden"

    ListModel{
        id: mayorshipsModel
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { }
    }

    GreenLine {
        height: 30
        text: "MAYORSHIPS"
    }

    ListView {
        model: mayorshipsModel
        y: 30
        width: parent.width
        height: parent.height - y
        delegate: mayorshipsDelegate
        //highlightFollowsCurrentItem: true
        clip: true
    }

    Component {
        id: mayorshipsDelegate

        EventBox {
            activeWhole: true

            venueName: model.name
            createdAt: model.address
            commentsCount: model.hereNow

            Component.onCompleted: {
                userPhoto.photoUrl = model.icon
            }

            onAreaClicked: {
                mayorships.venue( model.id );
            }
        }
    }

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: mayorships
                x: parent.width
            }
        },
        State {
            name: "hiddenLeft"
            PropertyChanges {
                target: mayorships
                x: -parent.width
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: mayorships
                x: 0
            }
        }
    ]

    transitions: [
        Transition {
            from: "shown"
            SequentialAnimation {
                PropertyAnimation {
                    target: mayorships
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
                PropertyAction {
                    target: mayorships
                    properties: "visible"
                    value: false
                }
            }
        },
        Transition {
            to: "shown"
            SequentialAnimation {
                PropertyAction {
                    target: mayorships
                    properties: "visible"
                    value: true
                }
                PropertyAnimation {
                    target: mayorships
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}

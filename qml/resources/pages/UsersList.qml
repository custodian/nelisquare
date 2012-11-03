import Qt 4.7
import "../components"

Rectangle {
    id: usersList
    signal user(string id)
    property alias usersModel: usersModel

    width: parent.width
    height: parent.height

    color: theme.colors.backgroundMain
    state: "hidden"

    ListModel{
        id: usersModel
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { }
    }

    LineGreen {
        height: 30
        text: "USER FRIENDS"
    }

    ListView {
        model: usersModel
        y: 30
        width: parent.width
        height: parent.height - y
        delegate: usersDelegate
        clip: true
    }

    Component {
        id: usersDelegate

        EventBox {
            activeWhole: true

            venueName: model.name
            createdAt: model.city

            Component.onCompleted: {
                userPhoto.photoUrl = model.photo
            }

            onAreaClicked: {
                usersList.user( model.id );
            }
        }
    }

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: usersList
                x: parent.width
            }
        },
        State {
            name: "hiddenLeft"
            PropertyChanges {
                target: usersList
                x: -parent.width
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: usersList
                x: 0
            }
        }
    ]

    transitions: [
        Transition {
            from: "shown"
            SequentialAnimation {
                PropertyAnimation {
                    target: usersList
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
                PropertyAction {
                    target: usersList
                    properties: "visible"
                    value: false
                }
            }
        },
        Transition {
            to: "shown"
            SequentialAnimation {
                PropertyAction {
                    target: usersList
                    properties: "visible"
                    value: true
                }
                PropertyAnimation {
                    target: usersList
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}

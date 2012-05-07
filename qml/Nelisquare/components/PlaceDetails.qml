import Qt 4.7

Rectangle {
    id: place
    signal checkin()
    signal markToDo()
    signal showAddTip()
    width: parent.width
    color: "#eee"

    property string venueID: ""
    property string venueName: ""
    property string venueAddress: ""
    property string venueCity: ""
    property string venueMajor: ""
    property string venueMajorPhoto: ""
    property string venueHereNow: ""
    property string venueCheckinsCount: ""
    property string venueUsersCount: ""

    MouseArea {
        anchors.fill: parent
        onClicked: { }
    }

    Rectangle {
        width: parent.width
        height: 10
        color: "#A8CB17"
        y: 160

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

    Column {
        width: parent.width - 20
        x: 10
        y: 174
        spacing: 10

        Text {
            text: place.venueMajor.length>0 ? place.venueMajor : "Venue doesn't have mayor yet!"
            font.pixelSize: 22
            font.bold: true
            color: "#111"
        }
        Text {
            text: place.venueMajor.length>0 ? "is the mayor." : "It could be you!"
            font.pixelSize: 20
            color: "#888"
        }
        Rectangle {
            width: parent.width
            height: 1
            color: "#ccc"
        }
        Repeater {
            id: tipRepeater
            width: parent.width
            model: tipsModel
            delegate: tipDelegate
            visible: tipsModel.count>0
        }
        Rectangle {
            width: parent.width
            height: 1
            color: "#ccc"
            visible: tipsModel.count>0
        }
        Row {
            width: parent.width
            height: 50
            spacing: 10
            BlueButton {
                label: "Add tip"
                width: parent.width / 2 - 5
                onClicked: {
                    place.showAddTip();
                }
            }
            BlueButton {
                label: "Mark to-do"
                width: parent.width / 2 - 5
                onClicked: {
                    place.markToDo();
                }
            }
        }
    }

    Component {
        id: tipDelegate

        Column {
            width: tipRepeater.width
            Text {
                width: parent.width
                wrapMode: Text.Wrap
                text: tipText
                color: "#111"
                font.pixelSize: 18
            }
            Text {
                width: parent.width
                wrapMode: Text.Wrap
                text: tipAge
                color: "#aaa"
                font.pixelSize: 18
            }
        }

    }

    Rectangle {
        id: profileImage
        x: parent.width - 68
        y: 174
        visible: place.venueMajor.length>0
        width: 64
        height: 64
        color: "#fff"
        border.color: "#ccc"
        border.width: 1

        Image {
            x: 4
            y: 4
            source: place.venueMajorPhoto
            smooth: true
            width: 57
            height: 57
        }
    }

    Rectangle {
        width: parent.width
        height: 160
        color: theme.toolbarLightColor

        Text {
            id: venueNameText
            text: place.venueName
            font.pixelSize: 24
            font.bold: true
            color: "#fff"
            x: 10
            y: 10
        }

        Text {
            id: venueAddressText
            text: place.venueAddress
            font.pixelSize: 20
            color: "#fff"
            x: 10
            y: venueNameText.y + venueNameText.height
        }

        GreenButton {
            label: "CHECK IN HERE"
            width: parent.width - 20
            x: 10
            y: venueAddressText.y + venueAddressText.height + 8

            onClicked: {
                place.checkin();
            }
        }

    }

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: place
                x: parent.width
            }
        },
        State {
            name: "hiddenLeft"
            PropertyChanges {
                target: place
                x: -parent.width
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: place
                x: 0
            }
        }
    ]

    transitions: [
        Transition {
            SequentialAnimation {
                PropertyAnimation {
                    target: place
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}

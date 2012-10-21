import Qt 4.7

Rectangle {
    signal badge(string name, string image, string info, string venueName, string venueID, string time)

    property alias badgeModel: badgeModel

    id: badgesPage
    width: parent.width
    height: parent.height
    state: "hidden"

    ListModel {
        id: badgeModel
    }

    GridView {
        id: badgeGrid
        anchors.fill: parent
        clip: true

        cellWidth: parent.width/3
        cellHeight: cellWidth

        model: badgeModel
        delegate: badgeDelegate
    }

    Component {
        id: badgeDelegate

        Item {
            width: badgeGrid.cellWidth

            Image {
                id: badgeImage
                width: 114
                height: 114
                source: cache.get(model.image)
                anchors.horizontalCenter: parent.horizontalCenter

                MouseArea {
                    anchors.fill: badgeImage
                    onClicked: {
                        badgesPage.badge(
                                    model.name,
                                    model.imageLarge,
                                    model.info,
                                    model.venueName,
                                    model.venueID,
                                    model.time);
                    }
                }

            }
            Image {
                anchors.centerIn: parent
                source: "../pics/loader.gif"
                visible: (badgeImage.status != Image.Ready)
            }
            Text {
                text: model.name;
                y: badgeImage.y + badgeImage.height
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: theme.font.sizeSigns
            }
        }
    }

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: badgesPage
                x: parent.width
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: badgesPage
                x: 0
            }
        }
    ]

    transitions: [
        Transition {
            from: "shown"
            SequentialAnimation {
                PropertyAnimation {
                    target: badgesPage
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
                PropertyAction {
                    target: badgesPage
                    properties: "visible"
                    value: false
                }
            }
        },
        Transition {
            to: "shown"
            SequentialAnimation {
                PropertyAction {
                    target: badgesPage
                    properties: "visible"
                    value: true
                }
                PropertyAnimation {
                    target: badgesPage
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}

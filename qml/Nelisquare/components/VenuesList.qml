import Qt 4.7

Rectangle {
    id: venuesList
    signal clicked(int index)
    signal search(string query)
    width: parent.width
    color: "#eee"

    MouseArea {
        anchors.fill: parent
        onClicked: { }
    }

    ListView {
        model: placesModel
        width: parent.width
        height: parent.height - 80
        y: 110
        delegate: venuesListDelegate
        highlightFollowsCurrentItem: true
    }

    Rectangle {
        width: parent.width
        height: 30
        color: "#ccc"
        y: 80

        Text {
            color: "#333"
            text: "Places nearby"
            font.pixelSize: 20
            anchors.verticalCenter: parent.verticalCenter
            x: 4
        }
    }

    Rectangle {
        width: parent.width
        height: 1
        color: "#eee"
        y: 80
    }

    Rectangle {
        width: parent.width
        height: 1
        color: "#888"
        y: 109
    }

    Rectangle {
        width: parent.width
        height: 80
        color: theme.toolbarLightColor


        Rectangle {
            id: tweetTextContainer
            height: 40
            width: parent.width - 150
            x: 10
            y: 20
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#ccc" }
                GradientStop { position: 0.1; color: "#fafafa" }
                GradientStop { position: 1.0; color: "#fff" }
            }
            radius: 5
            border.width: 1
            border.color: "#aaa"
            smooth: true

            TextInput {
                id: searchText
                //wrapMode: TextEdit.NoWrap
                text: "Search"
                //textFormat: TextEdit.PlainText
                width: parent.width - 10
                height: parent.height - 10
                x: 5
                y: 5
                color: "#111"
                font.pixelSize: 24

                onAccepted: {
                    var query = searchText.text;
                    if(query=="Search") {
                        query = "";
                    }
                    venuesList.search(query);
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if(searchText.text=="Search") {
                            searchText.text = "";
                            searchText.focus = true;
                        }
                        searchText.forceActiveFocus();
                        searchText.openSoftwareInputPanel();
                    }
                }
            }
        }

        BlueButton {
            x: parent.width - width - 10
            y: 20
            height: 40
            label: "Search"
            width: 120

            onClicked: {
                // Search
                var query = searchText.text;
                if(query=="Search") {
                    query = "";
                }
                venuesList.search(query);
            }
        }


    }

    Component {
        id: venuesListDelegate

        Item {
            id: placesItem
            width: parent.width
            height: titleContainer.height + 2

            Rectangle {
                id: titleContainer
                color: mouseArea.pressed ? "#ddd" : "#eee"
                y: 1
                width: parent.width
                height: statusTextArea.height + 8 < 64 ? 64 : statusTextArea.height + 8

                Image {
                    x: 8
                    y: 4
                    id: buildingImage
                    source: icon
                    width: 32
                    height: 32
                }

                Column {
                    id: statusTextArea
                    spacing: 4
                    x: buildingImage.width + 16
                    y: 4
                    width: parent.width - x - 16

                        Text {
                            id: messageText
                            color: "#333"
                            font.pixelSize: 24
                            width: parent.width
                            text: name
                            font.bold: true
                            wrapMode: Text.Wrap
                        }

                        Text {
                            id: todoText
                            color: "#666"
                            font.pixelSize: 16
                            width: parent.width
                            text: todoComment
                            visible: todoComment.length>0
                            wrapMode: Text.Wrap
                        }

                        Text {
                            id: distanceText
                            color: "#666"
                            font.pixelSize: 16
                            width: parent.width
                            text: distance + " meters"
                            wrapMode: Text.Wrap
                        }
                }
            }

            Rectangle {
                width:  parent.width
                x: 4
                y: placesItem.height - 1
                height: 1
                color: "#ddd"
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                onClicked: {
                    venuesList.clicked( index );
                }
            }

        }
    }

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: venuesList
                x: parent.width
            }
        },
        State {
            name: "hiddenLeft"
            PropertyChanges {
                target: venuesList
                x: -parent.width
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: venuesList
                x: 0
            }
        }
    ]

    transitions: [
        Transition {
            SequentialAnimation {
                PropertyAnimation {
                    target: venuesList
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}

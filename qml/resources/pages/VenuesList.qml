import Qt 4.7
import "../components"

Rectangle {
    id: venuesList
    signal checkin(string venueid, string venuename)
    signal clicked(string venueid)
    signal search(string query)
    signal addVenue()

    property alias placesModel: placesModel

    width: parent.width
    height: parent.height
    color: theme.colors.backgroundMain
    state: "hidden"

    function hideKeyboard() {
        searchText.closeSoftwareInputPanel();
        window.focus = true;
    }

    ListModel {
        id: placesModel
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { }
    }

    Rectangle {
        width: parent.width
        height: 80
        color: theme.colors.backgroundBlueDark

        Rectangle {
            id: textContainer
            height: 40
            width: parent.width - 150
            x: 10
            y: 20
            gradient: theme.gradientTextBox
            border.width: 1
            border.color: theme.colors.textboxBorderColor
            smooth: true

            TextInput {
                id: searchText
                text: theme.textSearchVenue
                width: parent.width - 10
                height: parent.height - 10
                x: 5
                y: 5
                color: theme.colors.textColor
                font.pixelSize: 24

                onAccepted: {
                    var query = searchText.text;
                    if(query===theme.textSearchVenue) {
                        query = "";
                    }
                    venuesList.search(query);
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        searchText.focus = true;
                        if(searchText.text===theme.textSearchVenue) {
                            searchText.text = "";
                        }
                        if (searchText.text != "") {
                            searchText.cursorPosition = searchText.positionAt(mouseX,mouseY);
                        }
                    }
                }
            }
        }

        ButtonBlue {
            x: parent.width - width - 10
            y: 20
            height: 40
            label: "SEARCH"
            width: 120

            onClicked: {
                // Search
                var query = searchText.text;
                if(query===theme.textSearchVenue) {
                    query = "";
                }
                hideKeyboard();
                venuesList.search(query);
            }
        }
    }

    ListView {
        id: placesView
        y: 80
        width: parent.width
        height: parent.height - y
        model: placesModel
        delegate: venuesListDelegate
        //highlightFollowsCurrentItem: true
        clip: true
        cacheBuffer: 400
        spacing: 5
        header:
            LineGreen {
                height: 30
                text: "PLACES NEAR YOU"
            }

        footer: Column {
            width: placesView.width
            Item {
                width: placesView.width
                height: 10
            }
            ButtonBlue {
                width: placesView.width * 0.7
                anchors.horizontalCenter: parent.horizontalCenter
                label: "ADD NEW VENUE"
                onClicked: {
                    venuesList.addVenue();
                }
            }
            Item {
                width: placesView.width
                height: 30
            }
        }
    }

    Component {
        id: venuesListDelegate

        EventBox {
            activeWhole: true

            userShout: (model.todoComment)? model.todoComment : model.address
            //userMayor: model.mayor
            venueName: model.name
            venuePhoto: model.photo !== undefined ? model.photo : ""
            createdAt: model.distance + " meters"
            peoplesCount: model.peoplesCount

            Component.onCompleted: {
                userPhoto.photoUrl = model.icon
            }

            onAreaClicked: {
                venuesList.clicked( model.id );
            }

            onAreaPressAndHold: {
                venuesList.checkin( model.id, model.name);
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
            from: "shown"
            SequentialAnimation {
                PropertyAnimation {
                    target: venuesList
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
                PropertyAction {
                    target: venuesList
                    properties: "visible"
                    value: false
                }
            }
        },
        Transition {
            to: "shown"
            SequentialAnimation {
                PropertyAction {
                    target: venuesList
                    properties: "visible"
                    value: true
                }
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

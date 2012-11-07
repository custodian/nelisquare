import Qt 4.7
import "../components"

Rectangle {
    id: venueEdit
    signal update(variant venue)
    signal updateCompleted(string venue)

    property alias venueCategories: venueCategories

    width: parent.width
    height: parent.height

    color: theme.colors.backgroundMain
    state: "hidden"

    ListModel{
        id: venueCategories
    }

    function hideKeyboard() {
        textName.closeSoftwareInputPanel();
        venueEdit.focus = true;
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            hideKeyboard();
        }
    }

    LineGreen {
        id: editVenueLabel
        height: 40
        text: "ENTER DETAILS FOR VENUE"
    }

    Flickable{

        id: flickableArea
        anchors.top: editVenueLabel.bottom
        width: parent.width
        contentWidth: parent.width
        height: venueEdit.height - y

        clip: true
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds
        pressDelay: 100

        Column {
            onHeightChanged: {
                flickableArea.contentHeight = height + y;
            }

            y: 10
            width: parent.width - 20
            spacing: 10

            Item {
                width: parent.width
                height: 10
            }

            Text {
                id: textNameLabel
                text: "NAME"
                color: theme.colors.textColorOptions
                font.pixelSize: theme.font.sizeToolbar
                font.family: "Nokia Pure" //theme.font.name
                font.bold: true

                Rectangle {
                    anchors.left: textNameLabel.right
                    anchors.leftMargin: 20
                    anchors.verticalCenter: textNameLabel.verticalCenter
                    height: 40

                    width: parent.width - 150
                    gradient: theme.gradientTextBox
                    border.width: 1
                    border.color: theme.colors.textboxBorderColor
                    smooth: true

                    TextInput {
                        id: textName


                        text: theme.textEnterVenueName
                        width: venueEdit.width - textNameLabel.width - 20
                        //height: parent.height - 10
                        color: theme.colors.textColor
                        font.pixelSize: 24

                        onAccepted: {
                            var query = textName.text;
                            if(query===theme.textEnterVenueName) {
                                query = "";
                            }
                            hideKeyboard();
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                textName.focus = true;
                                if(textName.text===theme.textEnterVenueName) {
                                    textName.text = "";
                                }
                                if (textName.text != "") {
                                    textName.cursorPosition = textName.positionAt(mouseX,mouseY);
                                }
                            }
                        }
                    }
                }
            }

            LineGreen{
                height: 30
                text: "VENUE LOCATION"
            }

            LineGreen{
                height: 30
                text: "VENUE CATEGORY"
            }
            //Category icon and type
            EventBox {

            }

            LineGreen{
                height: 30
                text: "VENUE DESCRIPTION"
            }

            ButtonGreen {
                width: parent.width * 0.7
                label: "CREATE VENUE"
            }

            Item {
                width: parent.width
                height: 50
            }
        }
    }


    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: venueEdit
                x: parent.width
            }
        },
        State {
            name: "hiddenLeft"
            PropertyChanges {
                target: venueEdit
                x: -parent.width
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: venueEdit
                x: 0
            }
        }
    ]

    transitions: [
        Transition {
            from: "shown"
            SequentialAnimation {
                PropertyAnimation {
                    target: venueEdit
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
                PropertyAction {
                    target: venueEdit
                    properties: "visible"
                    value: false
                }
            }
        },
        Transition {
            to: "shown"
            SequentialAnimation {
                PropertyAction {
                    target: venueEdit
                    properties: "visible"
                    value: true
                }
                PropertyAnimation {
                    target: venueEdit
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}

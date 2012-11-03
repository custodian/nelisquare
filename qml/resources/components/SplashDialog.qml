import Qt 4.7

Item {
    id: splashPage
    signal login()

    property string nextState: "hidden"

    width: parent.width
    height: parent.height
    state: "hidden"//"shown"

    Rectangle {
        anchors.fill: parent
        color: theme.colors.backgroundSplash
    }

    Image {
        anchors.centerIn: parent
        source: "../pics/splash.png"
    }

    Text {
        id: textRelease
        text: theme.textSplash
        anchors.centerIn: parent
        color: theme.colors.textColorSign
        font.pixelSize: theme.font.sizeDefault
        font.family: theme.font.name
    }

    Item {
        id: loginBox
        width: parent.width
        anchors.centerIn: parent
        Column{
            width: parent.width
            spacing: 20
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Please, login with Foursquare!"
                color: theme.colors.textColorSign
                font.pixelSize: theme.font.sizeDefault
            }
            ButtonGreen {
                anchors.horizontalCenter: parent.horizontalCenter
                id: loginButton
                label: "Login"
                width: parent.width - 130
                onClicked: {
                    splashPage.state = "hidden"
                }
            }

            Item {
                width: parent.width
                height: 50
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Foursquare privacy policy"
                color: theme.colors.textColorSign
                font.underline: true
                font.pixelSize: theme.font.sizeDefault
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        Qt.openUrlExternally("https://foursquare.com/legal/terms")
                    }
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Nelisquare privacy policy"
                color: theme.colors.textColorSign
                font.underline: true
                font.pixelSize: theme.font.sizeDefault
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        Qt.openUrlExternally("http://thecust.net/nelisquare/privacy.txt")
                    }
                }
            }
        }

        visible: false
    }

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: splashPage
                x: -parent.width
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: textRelease
                visible: true
            }
            PropertyChanges {
                target: loginBox
                visible: false
            }
            PropertyChanges {
                target: splashPage
                x: 0
            }
        },
        State {
            name: "login"
            PropertyChanges {
                target: textRelease
                visible: false
            }
            PropertyChanges {
                target: loginBox
                visible: true
            }
        }
    ]

    transitions: [
        Transition {
            to: "hidden"
            SequentialAnimation {
                PropertyAnimation {
                    target: splashPage
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
                PropertyAction {
                    target: splashPage
                    properties: "visible"
                    value: false
                }
            }
        },
        Transition {
            to: "shown"
            SequentialAnimation {
                PropertyAction {
                    target: splashPage
                    properties: "visible"
                    value: true
                }
                PropertyAnimation {
                    target: splashPage
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}

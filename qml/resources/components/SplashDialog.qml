import Qt 4.7

Item {
    id: splashPage
    signal login()

    property string nextState: "hidden"

    width: parent.width
    height: parent.height
    state: "shown"

    Rectangle {
        anchors.fill: parent
        color: "#00aedb"
    }

    Image {
        anchors.centerIn: parent
        source: "../pics/splash.png"
    }

    Text {
        id: textRelease
        text: theme.textSplash
        anchors.centerIn: parent
        color: theme.textColorSign
        font.pixelSize: theme.font.sizeDefault
        font.family: theme.font.name
    }

    Item {
        id: loginBox
        width: parent.width
        anchors.centerIn: parent
        Column{
            width: parent.width
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Please, login!"
                color: theme.textColorSign
                font.pixelSize: theme.font.sizeDefault
            }
            GreenButton {
                anchors.horizontalCenter: parent.horizontalCenter
                id: loginButton
                label: "Login"
                width: parent.width - 130
                onClicked: {
                    splashPage.state = "hidden"
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

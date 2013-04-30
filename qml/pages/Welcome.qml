import Qt 4.7
import "../components"

//Item {
PageWrapper {
    id: welcomePage
    signal login()

    //width: window.width
    //height: window.height

    property bool newuser: false

    function load() {
        welcomePage.login.connect(function(){
            //loginArea.visible = true;
            //create login Component
            stack.push(Qt.resolvedUrl("Login24sq.qml"));
        });
    }

    Rectangle {
        anchors.fill: parent
        color: mytheme.colors.backgroundSplash
    }

    Image {
        anchors.centerIn: parent
        source: "../pics/splash.png"
    }

    Text {
        text: mytheme.textSplash
        anchors.centerIn: parent
        color: mytheme.colors.textColorSign
        font.pixelSize: mytheme.font.sizeDefault
        font.family: mytheme.font.name
        visible: !newuser
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
                color: mytheme.colors.textColorSign
                font.pixelSize: mytheme.font.sizeDefault
            }
            ButtonGreen {
                anchors.horizontalCenter: parent.horizontalCenter
                id: loginButton
                label: "Login"
                width: parent.width - 130
                onClicked: {
                    welcomePage.login();
                }
            }

            Item {
                width: parent.width
                height: 50
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Foursquare privacy policy"
                color: mytheme.colors.textColorSign
                font.underline: true
                font.pixelSize: mytheme.font.sizeDefault
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
                color: mytheme.colors.textColorSign
                font.underline: true
                font.pixelSize: mytheme.font.sizeDefault
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        Qt.openUrlExternally("http://thecust.net/nelisquare/privacy.txt")
                    }
                }
            }
        }

        visible: newuser
    }
}

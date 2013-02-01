import Qt 4.7
import QtQuick 1.1
import com.nokia.meego 1.0

Rectangle   {
    id: pageWrapper

    width: parent.width
    height: parent.height
    color: mytheme.colors.backgroundMain

    property Item tools: ToolBarLayout{
        ToolIcon{
            id: backButton
            platformIconId: "toolbar-back" + (enabled ? "" : "-dimmed")
            onClicked: pageStack.pop()
        }
    }

    property alias dummyMenu: dummyMenu

    WaitingIndicator {
        id: waiting
        z: 10
    }

    function waiting_show() {
        waiting.show();
    }

    function waiting_hide() {
        waiting.hide();
    }

    function show_error(msg) {
        waiting_hide();
        console.log("Error: "+ msg);
        notificationDialog.message += msg + "<br/>"
        notificationDialog.state = "shown";
        notificationDialog.hider.restart();
    }

    Menu {
        id: dummyMenu
        visualParent: mainWindowPage
        MenuLayout {
            /*MenuItem { text: qsTr("Menu is not ready yet.")
                onClicked: {
                }
            }*/
            MenuItem {
                text: qsTr("Settings")
                onClicked: {
                    pageStack.replace(Qt.resolvedUrl("../pages/Settings.qml"));
                }
            }
            MenuItem {
                text: qsTr("Exit")
                onClicked: {
                    windowHelper.disableSwype(false);
                    Qt.quit();
                }
            }
        }
    }

}

/*
    tools: ToolBarLayout{
        ToolIcon {
            platformIconId: "toolbar-home"
            onClicked: {
                window.showFriendsFeed();
            }
        }
    }
*/

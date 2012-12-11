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

    Menu {
        id: dummyMenu
        visualParent: mainWindowStack
        MenuLayout {
            MenuItem { text: qsTr("Menu is not ready yet.")
                onClicked: {
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

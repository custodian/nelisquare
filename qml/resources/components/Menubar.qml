import Qt 4.7
import "."

import "../js/api.js" as Api

Rectangle {
    id: menubar
    height: 70
    color: theme.colors.backgroundMenubar

    MouseArea {
        anchors.fill: parent
    }

    Flow {
        id: menubarToolbar
        //width: menubar.width
        anchors.horizontalCenter: parent.horizontalCenter
        height: menubar.height
        spacing: 15

        ToolbarTextButton {
            id: backwardsButton
            label: "BACK"
            colorActive: theme.colors.textButtonTextMenu
            colorInactive: theme.colors.textButtonTextMenuInactive
            shown: pageStack.depth > 1
            onClicked: {
                pageStack.pop();
            }
        }

        ToolbarTextButton {
            label: "FEED"
            selected: (pageStack.currentPage!=null && pageStack.currentPage.parent.url == Qt.resolvedUrl("../pages/FriendsFeed.qml"))
            colorActive: theme.colors.textButtonTextMenu
            colorInactive: theme.colors.textButtonTextMenuInactive
            onClicked: {
                window.showFriendsFeed();
            }
        }

        ToolbarTextButton {
            label: "PLACES"
            selected: (pageStack.currentPage!=null && pageStack.currentPage.parent.url == Qt.resolvedUrl("../pages/VenuesList.qml"))
            colorActive: theme.colors.textButtonTextMenu
            colorInactive: theme.colors.textButtonTextMenuInactive
            onClicked: {
                pageStack.push(Qt.resolvedUrl("../pages/VenuesList.qml"));
            }
        }

        ToolbarTextButton {
            label: "LISTS"
            selected: false//"VenuesList"
            colorActive: theme.colors.textButtonTextMenu
            colorInactive: theme.colors.textButtonTextMenuInactive
            onClicked: {
                Api.showError("Lists not implemented yet!");
            }
        }

        ToolbarTextButton {
            label: "ME"
            selected: (pageStack.currentPage!=null && pageStack.currentPage.parent.url == Qt.resolvedUrl("../pages/User.qml"))
            colorActive: theme.colors.textButtonTextMenu
            colorInactive: theme.colors.textButtonTextMenuInactive
            onClicked: {
                pageStack.push(Qt.resolvedUrl("../pages/User.qml"),{"userID":"self"});
            }
        }

    }

    state: window.isPortrait ? "bottom" : "right"
    onStateChanged:  {
        console.log("state:" + state);
    }

    states: [
        State {
            name: "bottom"
            PropertyChanges {
                target: menubar
                height: 70
                width: parent.width
                y: parent.height - menubar.height
                x: 0
            }
            PropertyChanges {
                target: menubarToolbar
                y: 5
                x: 5//(menubar.width - backwardsButton.width*5 - 4*menubarToolbar.spacing)/2
                width: undefined
            }
        },
        State {
            name: "right"
            PropertyChanges {
                target: menubar
                width: 100
                height: menubar.parent.height - toolbar.height
                x: menubar.parent.width - width
                y: toolbar.height
            }
            PropertyChanges {
                target: menubarToolbar
                y: 5//(menubar.height - backwardsButton.height*5 - 4*menubarToolbar.spacing)/2
                x: 5
                width: menubar.width
            }
        }
    ]
}

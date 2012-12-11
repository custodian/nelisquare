import Qt 4.7
import "."

import "../js/api.js" as Api

Rectangle {
    id: menubar
    height: 70
    color: mytheme.colors.backgroundMenubar

    MouseArea {
        anchors.fill: parent
    }

    Flow {
        id: menubarToolbar
        //width: menubar.width
        anchors.horizontalCenter: parent.horizontalCenter
        height: menubar.height
        spacing: 15

        TextButton {
            id: backwardsButton
            label: "BACK"
            colorActive: mytheme.colors.textButtonTextMenu
            colorInactive: mytheme.colors.textButtonTextMenuInactive
            shown: pageStack.depth > 1
            onClicked: {
                pageStack.pop();
            }
        }

        TextButton {
            label: "FEED"
            selected: (pageStack.currentPage!=null && pageStack.currentPage.parent.url == Qt.resolvedUrl("../pages/FriendsFeed.qml"))
            colorActive: mytheme.colors.textButtonTextMenu
            colorInactive: mytheme.colors.textButtonTextMenuInactive
            onClicked: {
                window.showFriendsFeed();
            }
        }

        TextButton {
            label: "PLACES"
            selected: (pageStack.currentPage!=null && pageStack.currentPage.parent.url == Qt.resolvedUrl("../pages/VenuesList.qml"))
            colorActive: mytheme.colors.textButtonTextMenu
            colorInactive: mytheme.colors.textButtonTextMenuInactive
            onClicked: {
                if (pageStack.currentPage.parent.url == Qt.resolvedUrl("../pages/VenuesList.qml")) {
                    pageStack.replace(Qt.resolvedUrl("../pages/VenuesList.qml"),{},true);
                } else {
                    pageStack.push(Qt.resolvedUrl("../pages/VenuesList.qml"));
                }
            }
        }

        TextButton {
            label: "LISTS"
            selected: false//"VenuesList"
            colorActive: mytheme.colors.textButtonTextMenu
            colorInactive: mytheme.colors.textButtonTextMenuInactive
            onClicked: {
                Api.showError("Lists not implemented yet!");
            }
        }

        TextButton {
            label: "ME"
            selected: (pageStack.currentPage!=null && pageStack.currentPage.parent.url == Qt.resolvedUrl("../pages/User.qml"))
            colorActive: mytheme.colors.textButtonTextMenu
            colorInactive: mytheme.colors.textButtonTextMenuInactive
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
                height: menubar.parent.height - upperbar.height
                x: menubar.parent.width - width
                y: upperbar.height
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

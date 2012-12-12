import Qt 4.7
import QtQuick 1.1
import com.nokia.meego 1.0
import "."

PageStackWindow {
    id: mainWindowStack
    property bool windowActive: Qt.application.active

    showToolBar: toolbar.tools !== null
    //DBG
    //showStatusBar: false //(windowHelper.isMaemo())?
    showStatusBar: mainWindowPage.orientationLock === PageOrientation.LockPortrait
                   || mainWindowPage.orientationLock === PageOrientation.Automatic

    onWindowActiveChanged: {
        console.log("active: " + windowActive);
        window.windowActive = windowActive;
    }

    ToolBar {
        id: toolbar
    }

    initialPage: Page{
        id: mainWindowPage
        anchors.fill: parent
        //orientationLock: PageOrientation.LockPortrait
        tools: toolbar

        MainWindow {
            id: window
        }
    }

    /*Menu {
        id: myMenu
        visualParent: pageStack
        MenuLayout {
            MenuItem { text: qsTr("Refresh")
                onClicked: {
                    mainWindowStack.pageStack.currentPage.updateContent();
                }
                visible: mainWindowStack.pageStack.currentPage.updateContent !== undefined
            }
        }
    }*/

    function processUINotification(id) {
        window.processUINotification(id);
    }

    function processURI(url) {
        window.processURI(url);
    }

    function onPictureUploaded(response, page) {
        window.onPictureUploaded(response, page);
    }

    function onMolomeInfoUpdate(present,installed) {
        window.molome_present = present;
        window.molome_installed = installed;
    }

    function onMolomePhoto(state, photoUrl) {
        window.onMolomePhoto(state,photoUrl);
    }

    function onLockOrientation(value) {
        if (value === "auto") {
            mainWindowPage.orientationLock = PageOrientation.Automatic
        } else if (value === "landscape") {
            mainWindowPage.orientationLock = PageOrientation.LockLandscape
        } else if (value === "portrait") {
            mainWindowPage.orientationLock = PageOrientation.LockPortrait
        }
    }
}

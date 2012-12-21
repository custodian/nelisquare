import Qt 4.7
import QtQuick 1.1
import com.nokia.meego 1.0
import "."

PageStackWindow {
    id: mainWindowStack
    property bool windowActive: Qt.application.active

    showToolBar: toolbar.tools !== null
    showStatusBar: inPortrait

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
        tools: toolbar

        MainWindow {
            id: window
        }
    }

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

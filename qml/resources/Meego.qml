import Qt 4.7
import QtQuick 1.1
import com.nokia.meego 1.0
import "."

PageStackWindow {
    id: mainWindowStack
    property bool gpsActive: Qt.application.active

    initialPage: Page{
        id: mainWindowPage
        anchors.fill: parent
        orientationLock: PageOrientation.LockPortrait
        MainWindow {
            id: window
        }
    }
    showToolBar: false

    function onPictureUploaded(response) {
        window.onPictureUploaded(response);
    }

    function onLockOrientation(value) {
        if (value == "Auto") {
            mainWindowPage.orientationLock = PageOrientation.Automatic
        } else if (value == "Landscape") {
            mainWindowPage.orientationLock = PageOrientation.LockLandscape
        } else if (value == "Portrait") {
            mainWindowPage.orientationLock = PageOrientation.LockPortrait
        }
    }
}

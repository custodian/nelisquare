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

    Menu {
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
    }

    function onPictureUploaded(response) {
        window.onPictureUploaded(response);
    }

    function onLockOrientation(value) {
        if (value == "auto") {
            mainWindowPage.orientationLock = PageOrientation.Automatic
        } else if (value == "landscape") {
            mainWindowPage.orientationLock = PageOrientation.LockLandscape
        } else if (value == "portrait") {
            mainWindowPage.orientationLock = PageOrientation.LockPortrait
        }
    }
}

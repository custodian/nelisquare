import QtQuick 1.0
import QtWebKit 1.0
import QtMultimediaKit 1.1
import MOLOMELib 1.0
import "../UIComponents"
import "../ButtonComponents"
import "../../platforms"
import "../js/storage.js" as Storage

PageWrapper {
    id: captureScreen
    width: parent.width
    height: parent.height

    //property CameraControlNative camera
    property variant camera

    property bool isImageCaptured: false

    MouseArea {
        anchors.fill: parent
        onClicked: {

        }
    }

    orientationLock: themeManager.isPortrait ? themeManager.pageOrientationLandscape : themeManager.pageOrientationPortrait

    Rectangle {
        id: cameraContainer
        x: 0
        y: 0
        width: parent.width
        height: parent.height
        z: 1

        /*
        SimpleImage {
            id: previewImage
            x: 0
            y: 0
            width: themeManager.cameraViewfinderWidth
            height: themeManager.cameraViewfinderHeight
            visible: false
            stretch: true
        }
        */

        Image {
            id: hack
            visible: false
            Component.onCompleted: {
                if (themeManager.platform === "meego")
                {
                    hack.cache = false;
                }
            }

            //cache: false
        }

        MouseArea {
            anchors.fill: parent

            onClicked: {
                if (!camera.focusModeSupported())
                    return;
                btnCameraFocus.refreshMode()
                camera.searchAndLock();
            }
        }
    }

    Timer {
        id: timerExit
        interval: 1
        running: false
        repeat: false
        onTriggered: {
            switchToFilterSelectionScreen();
        }
    }


    Timer {
        id: timerStartCapture
        interval: 1
        running: false
        repeat: false
        onTriggered: {
            camera.captureImage();
        }
    }

    Rectangle {
        x: themeManager.cameraXOffset
        y: themeManager.cameraYOffset
        width: themeManager.screenWidth
        height: themeManager.screenHeight
        color: "#00000000"
        rotation: themeManager.isPortrait ? -90 : 0
        z: 10


        Header {
            id: header
            hasBack: true
            anchors.top: parent.top
            onBackClicked: {
                if (camera !== null && camera !== undefined)
                {
                    camera.unlock();
                    camera.destroy(0);
                    camera = null;
                }
                if (!isImageCaptured)
                    pageStack.pop();
                Qt.quit();
            }
        }

        HeaderMenu {
            id: headerMenu
            anchors.top: header.bottom

            CameraFlashButton {
                id: btnCameraFlash
                anchors.left: parent.left
                anchors.leftMargin: 10

                onClicked: {
                    refreshMode();
                }

                onFlashOnChanged: {
                    refreshMode();

                    Storage.setData("flashMode", flashOn);
                }
            }

            CameraFocusButton {
                id: btnCameraFocus
                anchors.right: parent.right
                anchors.rightMargin: 10
                visible: false

                onClicked: {
                    refreshMode();
                }

                onFocusAutoChanged: {
                    refreshMode();

                    Storage.setData("focusAuto", focusAuto);
                }
            }
        }

        Rectangle {
            id: cameraLeftBlackArea
            width: themeManager.isPortrait ? 0 : (captureScreen.width - (captureScreen.height - header.height - headerMenu.height)) >> 1
            anchors.top: headerMenu.bottom
            anchors.bottom: bottomBoxCaptureScreen.bottom
            x: 0
            color: "#D0000000"
            z: 100
            visible: !themeManager.isPortrait
        }

        Rectangle {
            id: cameraTopBlackArea
            width: parent.width
            height: 10
            anchors.top: headerMenu.bottom
            color: "#D0000000"
            z: 100

            Text {
                id: cameraStatusText
                color: "#ffffff"
                text: "Powering On"
                style: Text.Normal
                font.bold: true
                font.pixelSize: 18
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                visible: false
            }
        }

        Item {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: cameraTopBlackArea.bottom
            anchors.bottom: cameraBottomBlackArea.top
            z: 100

            FocusZoneItem {
                id: focusZone

                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                width: captureScreen.height / 3
                height: captureScreen.height / 3

                visible: false
            }
        }

        Rectangle {
            id: cameraBottomBlackArea
            width: parent.width
            height: 10
            anchors.bottom: bottomBoxCaptureScreen.top
            color: "#D0000000"
            z: 100
        }

        Rectangle {
            id: cameraRightBlackArea
            width: themeManager.isPortrait ? 0 : (captureScreen.width - (captureScreen.height - header.height - headerMenu.height)) >> 1
            anchors.top: headerMenu.bottom
            anchors.bottom: bottomBoxCaptureScreen.bottom
            x: captureScreen.width - ((captureScreen.width - (captureScreen.height - header.height - headerMenu.height)) >> 1)
            color: "#D0000000"
            z: 100
            visible: !themeManager.isPortrait
        }

        Button {
            id: bottomBoxCaptureScreen
            focusable: false
            bitmap: "../res/btn_take_photo.png"
            bitmap_pressed: "../res/btn_take_photo_pressed.png"
            asynchronous: false
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom

            onPressed: {
                camera.captureImage();
            }

            onClicked: {
                //camera.captureImage();
            }
        }

    }

    SymbianCameraCapturer {
        id: symbianCameraKeyCapturer

        focus: true

        width: 0
        height: 0

        onFocusKeyPressed: {
            if (!camera.focusModeSupported())
                return;
            btnCameraFocus.refreshMode()
            camera.searchAndLock();
        }

        onShutterKeyPressed: {
            camera.captureImage();
        }

        onFocusKeyReleased: {
            camera.unlock();
        }

        onKeyPressed: {
            if (key === Qt.Key_Select)
                bottomBoxCaptureScreen.forcePressed = true
        }

        onKeyReleased: {
            if (key === Qt.Key_Select)
            {
                bottomBoxCaptureScreen.forcePressed = false
                camera.captureImage();
            }
        }
    }

    function switchToFilterSelectionScreen() {
        var capturedFilename = camera.capturedImagePath
        if (camera !== null && camera !== undefined)
        {
            camera.unlock();
            camera.destroy(0);
            camera = null;
        }
        //pageStack.replace(Qt.resolvedUrl("FilterSelectionScreen.qml"), {filename: capturedFilename, rotatable: true}, true);
        pageStack.replace(Qt.resolvedUrl("ZoomCropScreen.qml"), {file: capturedFilename}, true);

        //Original way to pass
    }

    function onImageCaptured() {
        timerExit.start()
        //switchToFilterSelectionScreen()
    }


    onStatusChanged: {
        if (status == 2)
        {
            var component;
            if (themeManager.platform === "meego")
                component = Qt.createComponent("../UIComponents/CameraControlNative.qml");
            else
                component = Qt.createComponent("../UIComponents/CameraControl.qml");
            camera = component.createObject(cameraContainer);
            camera.parent = cameraContainer;
            camera.photoCaptured.connect(onImageCaptured);
            camera.z = 1;
            camera.start();

            if (themeManager.platform === "meego")
                btnCameraFocus.visible = false;
            else
                btnCameraFocus.visible = camera.focusModeSupported()
        }
    }

    Component.onCompleted: {
        if (themeManager.platform === "meego")
        {
            //cameraContainer.x = header.height + headerMenu.height
            cameraTopBlackArea.height = (parent.width - bottomBoxCaptureScreen.height - header.height - headerMenu.height - parent.height) / 2
        }
        else
        {
            //cameraContainer.x = header.height + headerMenu.height
            cameraTopBlackArea.height = (parent.height - bottomBoxCaptureScreen.height - header.height - headerMenu.height - parent.width) / 2
        }
        cameraBottomBlackArea.height = cameraTopBlackArea.height
    }

    Component.onDestruction: {
        if (camera !== null && camera !== undefined)
        {
            camera.unlock();
            camera.destroy(0);
            camera = null;
        }
    }
}

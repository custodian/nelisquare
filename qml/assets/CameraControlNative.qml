import QtQuick 1.0
import QtWebKit 1.0
import QtMultimediaKit 1.1
import MOLOMELib 1.0
import "../UIComponents"
import "../ButtonComponents"
import "../../util/common.js" as Common
import "../../platforms"

Camera {
    id : camera

    signal photoCaptured

    property int focusMode

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter

    width: themeManager.cameraViewfinderWidth
    height: themeManager.cameraViewfinderHeight
    captureResolution: Qt.size(2560,1920)
                       //HiQuality Qt.size(1920, 1440)
                       //Original (themeManager.isPortrait && finalImageResolution <= 768) ? Qt.size(1024, 768) : Qt.size(1280, 960)

    flashMode: Camera.FlashOff
    exposureCompensation: Camera.ExposureAuto
    whiteBalanceMode: Camera.WhiteBalanceAuto

    onCameraStateChanged: {
        console.log("Camera State = " + camera.cameraState);
        if (camera.cameraState === Camera.LoadedState) {
            cameraStatusText.text = "";
        }

        if (camera.cameraState === Camera.ActiveState) {
            //btnCameraFlash.refreshMode()
            btnCameraFocus.refreshMode()
        }
    }

    onImageSaved: {
        console.log("ImageSaved");

        captureScreen.isImageCaptured = true;

        cameraStatusText.text = "Processing";

        //camera.stop();

        var camWidth;
        var gap;
        var xGap;
        var ratio;
        if (themeManager.isPortrait)
        {
            if (themeManager.platform === "meego")
            {
                camWidth = Math.floor(captureScreen.height * 4 / 3); //console.debug("$$camWidth: "+camWidth);
                gap = Math.floor((captureScreen.width - camWidth) * 0.5); //console.debug("$$gap: "+gap);
                xGap = header.height + headerMenu.height + cameraTopBlackArea.height - gap; //console.debug("$$xGap: "+xGap);
                ratio = xGap / captureScreen.height;
            }
            else
            {
                camWidth = Math.floor(captureScreen.height * 4 / 3); //console.debug("$$camWidth: "+camWidth);
                gap = Math.floor((captureScreen.width - camWidth) * 0.5); //console.debug("$$gap: "+gap);
                xGap = /*header.height + headerMenu.height + */cameraTopBlackArea.height - gap; //console.debug("$$xGap: "+xGap);
                ratio = xGap / captureScreen.height;
            }
        }
        else
        {
            //camWidth = Math.floor(captureScreen.width); //console.debug("$$camWidth: "+camWidth);
            //gap = Math.floor((captureScreen.width - camWidth) * 0.5); //console.debug("$$gap: "+gap);
            //xGap = header.height + headerMenu.height + cameraTopBlackArea.height - gap; //console.debug("$$xGap: "+xGap);
            //ratio = xGap / captureScreen.height;
            ratio = (header.height + headerMenu.height) / captureScreen.height;
        }

        //imageProcessor.process(path, ratio, themeManager.isPortrait);
        //imageProcessor.processImage(image, ratio, themeManager.isPortrait);

        camera.photoCaptured();

        timerDeleteFile.start()
    }

    /*
    onError: {
        console.log("Error");
    }
    */

    onCaptureFailed: {
        console.log("CaptureFailed");
    }

    onImageCaptured: {
        console.log("ImageCaptured");

        //previewImage.image = image;
        //previewImage.visible = true;
        //camera.visible = false;

        captureScreen.isImageCaptured = true;

        hack.source = preview

        cameraStatusText.text = "Processing";
        /*

        //camera.stop();

        var camWidth = Math.floor(captureScreen.height * 4 / 3); //console.debug("$$camWidth: "+camWidth);
        var gap = Math.floor((captureScreen.width - camWidth) * 0.5); //console.debug("$$gap: "+gap);
        var xGap = header.height + headerMenu.height + cameraTopBlackArea.height - gap; //console.debug("$$xGap: "+xGap);
        var ratio = xGap / captureScreen.height;

        //console.debug(ratio+"$$$$");
        //imageProcessor.process(camera.capturedImagePath, ratio);
        imageProcessor.processImage(image, ratio);

        camera.photoCaptured();
        */
    }

    onLockStatusChanged: {
        //console.log("LockStatus = " + camera.lockStatus);


        if (camera.lockStatus == Camera.Unlocked)
        {
            focusZone.setColor(255, 0, 0);
        }
        else if (camera.lockStatus == Camera.Searching)
        {
            focusZone.setColor(255, 255, 0);
        }
        else if (camera.lockStatus == Camera.Locked)
        {
            camera.unlock()

            focusZone.setColor(0, 255, 0);
        }

        focusZone.visible = true;

        timerHideFocusZone.restart()
    }

    Timer {
        id: timerHideFocusZone
        repeat: false
        running: false
        interval: 2000
        onTriggered: {
            focusZone.visible = false;
        }
    }

    Timer {
        id: timerDeleteFile
        repeat: false
        running: false
        interval: 10
        onTriggered: {
            if (camera !== null)
            {
                //storageManager.deleteFile(camera.capturedImagePath);
            }
        }
    }

    function focusModeSupported() {
        return true;
    }

}

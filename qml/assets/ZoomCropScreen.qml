import QtQuick 1.0
import MOLOMELib 1.0
import "../UIComponents"
import "../ButtonComponents"
import "../js/createComponent.js" as CreateComponent
import "../../platforms"

PageWrapper {
    id: zoomCropScreen
    width: parent.width
    height: parent.height

    property real oldZoomPercent: 0
    property int initSize: themeManager.previewImageSize
    property int iSizeHalf: zoomCropScreen.initSize/2
    property int imageWidth: 0
    property int imageHeight: 0
    property int gapZoomX: 0
    property int gapZoomY: 0
    property int translateX: 0
    property int translateY: 0

    property string file: "";
    property int currentRot: 0;
    property variant rotationList: [0, -90, 180, 90];

    /* Loading Dialog */
    property variant dialog
    property variant listModel

    function updateZoomPercent(zoomPercent){
        var ratio = 1+(zoomPercent-zoomCropScreen.oldZoomPercent)/100;

        var oldContentX = previewImage.x;
        var oldContentY = previewImage.y;
        var oldWidth = previewImage.width;
        var oldHeight = previewImage.height;

        var size = initSize*zoomPercent/100 + initSize;
        if(imageWidth > imageHeight){
            previewImage.height = Math.floor(imageHeight / imageWidth * size);
            previewImage.width = Math.floor(size);
        }else{
            previewImage.width = Math.floor(imageWidth / imageHeight * size);
            previewImage.height = Math.floor(size);
        }

        gapZoomX = Math.floor(zoomPercent/100*iSizeHalf);
        gapZoomY = Math.floor(zoomPercent/100*iSizeHalf);

        var transZoomX = Math.floor((100+zoomPercent)/100*translateX);
        var transZoomY = Math.floor((100+zoomPercent)/100*translateY);
        var finalX = -gapZoomX + transZoomX;
        var finalY = -gapZoomY + transZoomY;

        var w = previewImage.width;
        var h = previewImage.height;

        if (w < initSize)
        {
            imageHandler.drag.minimumX = 0;
            imageHandler.drag.maximumX = Math.floor(initSize-w);
            imageHandler.drag.minimumY = -h + initSize;
            imageHandler.drag.maximumY = 0;
        }
        else if (h < initSize)
        {
            imageHandler.drag.minimumX = -w + initSize;
            imageHandler.drag.maximumX = 0;
            imageHandler.drag.minimumY = 0;
            imageHandler.drag.maximumY = Math.floor(initSize-h);
        }
        else
        {
            imageHandler.drag.minimumX = -w + initSize;
            imageHandler.drag.maximumX = 0;
            imageHandler.drag.minimumY = -h + initSize;
            imageHandler.drag.maximumY = 0;
        }

        if (finalX > imageHandler.drag.maximumX)
        {
            finalX = imageHandler.drag.maximumX;
            translateX = (finalX + gapZoomX)*100/(100+zoomPercent);
        }
        else if (finalX < imageHandler.drag.minimumX)
        {
            finalX = imageHandler.drag.minimumX;
            translateX = (finalX + gapZoomX)*100/(100+zoomPercent);
        }


        if (finalY > imageHandler.drag.maximumY)
        {
            finalY = imageHandler.drag.maximumY;
            translateY = (finalY + gapZoomY)*100/(100+zoomPercent);
        }
        else if (finalY < imageHandler.drag.minimumY)
        {
            finalY = imageHandler.drag.minimumY;
            translateY = (finalY + gapZoomY)*100/(100+zoomPercent);
        }

        previewImage.x = finalX;
        previewImage.y = finalY;

        zoomCropScreen.oldZoomPercent = zoomPercent;
    }


    MouseArea {
        anchors.fill: parent
        onClicked: {

        }
    }

    orientationLock: themeManager.pageOrientationPortrait


    /******************************
     * Apply Filter Preview Worker
     ******************************/

    WorkerScript {
       id: zoomCropWorker
       source: "../js/zoomCropWorker.js"

       onMessage:
       {
           zoomCropScreen.listModel.destroy(0);
           CreateComponent.destroyComponent(zoomCropScreen.dialog.getPageId(), 0);

           pageStack.pop(zoomCropScreen, true);
           pageStack.push(Qt.resolvedUrl("FilterSelectionScreen.qml"), {darkAreas: messageObject._darkAreas});
       }
    }


    /******
     * UI
     ******/
    Header {
        id: header
        hasBack: true
        hasNext: true
        anchors.top: parent.top
        z: 999
        onBackClicked: {
            var dialog = CreateComponent.createConfirmationDialog("../", zoomCropScreen, "Discard Changes?");
            dialog.z = 9999;
            dialog.clicked.connect(
                function() {
                    pageStack.replace(Qt.resolvedUrl("CaptureScreen.qml"), null, true);
                }
            );
        }
        onNextClicked: {
            var scale = /*previewImage.sourceSize.height*/ imageProcessor.getSourceHeight() / previewImage.height;
            var x = -Math.floor(previewImage.x * scale);
            var y = -Math.floor(previewImage.y * scale);
            var width = Math.floor(zoomCropScreen.initSize * scale);
            var height = Math.floor(zoomCropScreen.initSize * scale);

            var rotation = zoomCropScreen.rotationList[zoomCropScreen.currentRot];

            dialog = CreateComponent.createLoadingDialog(zoomCropScreen,"Cropping...");
            dialog.cancelBtnAvailable = false;
            listModel = Qt.createQmlObject("import QtQuick 1.0; ListModel{id:listModel}", zoomCropScreen, "");
            listModel.append({'imageProcessor':imageProcessor,
                              'x':        x,
                              'y':        y,
                              'width':    width,
                              'height':   height,
                              'rotation': rotation,
                             });
            zoomCropWorker.sendMessage(listModel);

            //imageProcessor.zoomCrop(x, y, width, height, rotation);

            //pageStack.push(Qt.resolvedUrl("FilterSelectionScreen.qml"));
        }
    }

    HeaderBar {
        id: headerCaption
        anchors.top: header.bottom
        text: qsTr("Zoom and Crop")
        z: 999

        Button {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            bitmap: "../res/btn_rotate_left.png"
            bitmap_pressed: "../res/btn_rotate_left_click.png"
            onClicked: {
                zoomCropScreen.currentRot = (zoomCropScreen.currentRot + 1) % 4;
                zoomBox.rotation = zoomCropScreen.rotationList[zoomCropScreen.currentRot];
            }
        }

        Button {
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            bitmap: "../res/btn_rotate_right.png"
            bitmap_pressed: "../res/btn_rotate_right_click.png"
            onClicked: {
                zoomCropScreen.currentRot = (zoomCropScreen.currentRot + 3) % 4;
                zoomBox.rotation = zoomCropScreen.rotationList[zoomCropScreen.currentRot];
            }
        }
    }

    onFileChanged: {
        if (file === "")
            return;

        dialog = CreateComponent.createLoadingDialog(zoomCropScreen, "Loading...");
        dialog.cancelBtnAvailable = false;
        dialog.z = 9999;

        imageProcessor.resizeBeforeZoomCrop(zoomCropScreen.file);
    }

    function resizeBeforeZoomCropCompleted()
    {
        CreateComponent.destroyComponent(dialog, 0);
        previewImage.source = filter.getSourceInitPath();// "image://imageprovider/output/init.jpg";
    }

    Image {
        id: fulfillAreaTop
        width: parent.width
        //fillMode: Image.Stretch
        anchors.top: headerCaption.bottom
        source: "../res/fulfill_bar_top.png"
        height: themeManager.isPortrait ? sourceSize.height : 0
    }

    Rectangle {
        id: zoomBox
        width: themeManager.isPortrait ? parent.width : themeManager.previewImageSize
        height: themeManager.isPortrait ? parent.width : themeManager.previewImageSize
        color: "#000000"
        anchors.top: fulfillAreaTop.bottom
        clip: true

        SimpleImage {
            id: previewImage
            stretch: true
            //fillMode: Image.Stretch

            Component.onCompleted: {
                //if (themeManager.platform === "meego")
                //    previewImage.cache = false;
            }

            MouseArea {
                id: imageHandler
                anchors.fill: parent
                drag.target: previewImage
                drag.minimumX: 0
                drag.maximumX: 600
                drag.minimumY: 0
                drag.maximumY: 600
                drag.axis: Drag.XandYAxis

                onReleased: {
                    var scale = initSize / Math.max(previewImage.width,previewImage.height);
                    translateX = (previewImage.x +gapZoomX)*scale;
                    translateY = (previewImage.y +gapZoomY)*scale;
                }
            }

            onImageLoaded: {
                /*if (status === Image.Ready)*/{
                    var size = Math.max(previewImage.sourceSizeWidth, previewImage.sourceSizeHeight);
                    console.debug("$$$$"+size);
                    var ratio = zoomCropScreen.initSize / size;

                    zoomCropScreen.imageWidth = previewImage.sourceSizeWidth;
                    zoomCropScreen.imageHeight = previewImage.sourceSizeHeight;

                    var w = Math.ceil(ratio * previewImage.sourceSizeWidth);
                    var h = Math.ceil(ratio * previewImage.sourceSizeHeight);

                    if(w < zoomCropScreen.initSize){
                        //previewImage.x = Math.floor((zoomCropScreen.initSize - w)*0.5);
                        zoomCropScreen.translateX = Math.floor((zoomCropScreen.initSize - w)*0.5);
                    }else if(h < zoomCropScreen.initSize){
                        //previewImage.y = Math.floor((zoomCropScreen.initSize - h)*0.5);
                        zoomCropScreen.translateY = Math.floor((zoomCropScreen.initSize - h)*0.5);
                    }

                    if(w > h){
                        imageHandler.drag.minimumX = 0;
                        imageHandler.drag.maximumX = 0;
                        imageHandler.drag.minimumY = 0;
                        imageHandler.drag.maximumY = Math.floor(zoomCropScreen.initSize-h);
                    }else{
                        imageHandler.drag.minimumX = 0;
                        imageHandler.drag.maximumX = Math.floor(zoomCropScreen.initSize-w);
                        imageHandler.drag.minimumY = 0;
                        imageHandler.drag.maximumY = 0;
                    }

                    var minRatio = 0;
                    if(w < zoomCropScreen.iSizeHalf){
                        minRatio = zoomCropScreen.iSizeHalf/w - 1;
                    }else if(h < zoomCropScreen.iSizeHalf){
                        minRatio = zoomCropScreen.iSizeHalf/h - 1;
                    }

                    var middleKnobRatio = 0.5;
                    var rightKnobRatio = 1.0;
                    if(w < h){
                        middleKnobRatio = zoomCropScreen.initSize/w-1;
                        rightKnobRatio = 4*zoomCropScreen.initSize/w-1; //2*  DBG
                    }else{
                        middleKnobRatio = zoomCropScreen.initSize/h-1;
                        rightKnobRatio = 4*zoomCropScreen.initSize/h-1; //2*  DBG
                    }

                    sliderBar.minValue = Math.floor(minRatio * 10000);
                    sliderBar.maxValue = Math.floor(rightKnobRatio * 10000);
                    sliderBar.initValue = Math.floor(middleKnobRatio * 10000);

                    previewImage.width = w;
                    previewImage.height = h;

                    updateZoomPercent(Math.ceil(sliderBar.initValue/100));
                }
            }
        }

    }

    Rectangle {
        id: rightArea
        anchors.top: fulfillAreaTop.bottom
        anchors.bottom: fulfillAreaBottom.top
        anchors.left: zoomBox.right
        anchors.right: parent.right
        color: "#ff9900"
    }

    Image {
        id: fulfillAreaBottom
        width: parent.width
        fillMode: Image.Stretch
        anchors.top: zoomBox.bottom
        //anchors.bottom: filterSelectionBar.top
        source: "../res/fulfill_bar_bottom.png"
        //height: themeManager.isPortrait ? height : 0
    }

    Image {
        id: filterSelectionBar
        source: "../res/select_effect_filter_side_bg_wide.png"
        height: themeManager.isPortrait ? sourceSize.height : 0
        anchors.top: fulfillAreaBottom.bottom
        anchors.bottom: parent.bottom

        ZoomSlideBar {
            id: sliderBar
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            onValueChanged: {
                zoomCropScreen.updateZoomPercent(sliderBar.value/100);
            }
        }
    }

    Component.onCompleted: {
        if (!themeManager.isPortrait)
            sliderBar.parent = rightArea
        imageProcessor.onResizeBeforeZoomCropCompleted.connect(zoomCropScreen.resizeBeforeZoomCropCompleted);
    }

    Component.onDestruction: {
        imageProcessor.onResizeBeforeZoomCropCompleted.disconnect(zoomCropScreen.resizeBeforeZoomCropCompleted);
        imageProcessor.process(file, 1, themeManager.isPortrait);
    }
}

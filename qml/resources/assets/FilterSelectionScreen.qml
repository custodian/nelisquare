import QtQuick 1.0
import QtWebKit 1.0
import QtMultimediaKit 1.1
import MOLOMELib 1.0
import "../UIComponents"
import "../ButtonComponents"
import "../js/createComponent.js" as CreateComponent
import "../../util/common.js" as Common
import "../js/filterScript.js" as FilterScript
import "../../platforms"

PageWrapper {    
    id: filterSelectionScreen

    property string selectedFilterName: ""
    property int selectedFilterId: 0

    property bool rotatable: false

    property string filename: ""
    property string filepathLarge : ""
    property variant darkAreas

    property variant dialog
    property variant listModel
    property variant colorPicked:[false, false, false, false, false, false, false, false]

    width: parent.width
    height: parent.height
    orientationLock: themeManager.pageOrientationPortrait

    Component.onCompleted: {
        filter.filterApplyPreviewCompleted.connect(filterSelectionScreen.previewCompleted);
        filter.filterApplyCompleted.connect(filterSelectionScreen.completed);
        filter.filterApplyError.connect(filterSelectionScreen.error);

        filterSelectionScreen.dialog = null;

        if (!themeManager.isPortrait)
        {
            filterSelectionBar.anchors.top = headerCaption.bottom
            filterSelectionBar.anchors.left = previewImage.right
            filterSelectionBar.anchors.right = filterSelectionScreen.right

            fulfillAreaBottom.anchors.top = previewImage.bottom
            fulfillAreaBottom.anchors.bottom = filterSelectionScreen.bottom
        }

        //var totalFulFillAreaHeight = fulfillAreaBottom.height + fulfillAreaTop.height;
        //fulfillAreaTop.height = totalFulFillAreaHeight >> 1;
        //fulfillAreaBottom.height = totalFulFillAreaHeight >> 1;

        var filterList = filter.getFilters();
        for(var i = 0; i < filterList.length; i++){
            var _filterIcon = FilterScript.createFilterIconControl(filterList[i], userManager.getPhotoCount());
            _filterIcon.clicked.connect(
                function(name)
                {
                    onFilterIconClicked(name, false);
                }
            );
        }

        FilterScript.selectItem(0);

        selectedFilterName = filterList[0].name;
        selectedFilterId = filterList[0].filterId;
    }

    function onFilterIconClicked(name, force) {
        var filterIcon = FilterScript.getItemByName(name);
        if (filterIcon === null)
            return;

        if (filterIcon.locked)
        {
            var infoDialog = CreateComponent.createInformationDialog(filterSelectionScreen, "", "You need to upload at least " + filterIcon.imagesToUnlock + " photos to unlock this filter");
            infoDialog.clicked.connect(
                function () {
                }
            );
            return;
        }

        if (filterIcon.filterId === 26) //Color Picker
        {
            if (force)
            {
                colorPicked = filterSelectionScreen.colorPicked;

                selectedFilterName = name;
                selectedFilterId = filterIcon.filterId;

                filterSelectionScreen.applyFilterPreview(name,colorPicked);
                //console.log(ref.color1,ref.color2,ref.color3,ref.color4,ref.color5,ref.color6,ref.color7,ref.color8);
                //Common.log(JSON.stringify(colorPicked));

                FilterScript.selectItemByName(selectedFilterName);
                return;
            }

            var colorPickerDialog = CreateComponent.createColorPickerDialog(filterSelectionScreen);
            //Common.log(JSON.stringify(filterSelectionScreen.colorPicked));
            //Common.log("selectedFilterName:"+selectedFilterName+", name:"+name);

            if (selectedFilterId === filterIcon.filterId)
            {
                colorPickerDialog.refP = filterSelectionScreen.colorPicked;
            }
            else
            {
                colorPickerDialog.refP = [false, false, false, false, false, false, false, false];
            }

            colorPickerDialog.clicked.connect(

                function(ref) {
                    Common.log(JSON.stringify(ref));
                    colorPicked = ref;

                    selectedFilterName = name;
                    selectedFilterId = filterIcon.filterId;

                    filterSelectionScreen.applyFilterPreview(name,colorPicked);
                    //console.log(ref.color1,ref.color2,ref.color3,ref.color4,ref.color5,ref.color6,ref.color7,ref.color8);
                    //Common.log(JSON.stringify(colorPicked));

                    FilterScript.selectItemByName(selectedFilterName);
                }
            );

            colorPickerDialog.cancelClicked.connect(
                function() {
                    FilterScript.selectItemByName(selectedFilterName);
                }
            );

        } else
        {
            if (filterIcon.selected && !force)
                return;


            if (filterIcon.expensive)
            {
                filterSelectionScreen.dialog = CreateComponent.createLoadingDialog(filterSelectionScreen, "Previewing...");
                filterSelectionScreen.dialog.cancelBtnAvailable = false;
                //filterSelectionScreen.listModel = Qt.createQmlObject("import QtQuick 1.0; ListModel{id:listModel}", filterSelectionScreen, "");
                //filterSelectionScreen.listModel.append({'filterScreen':filterSelectionScreen,
                //                                        'filterName':selectedFilterName});
                //applyFilterPreviewWorker.sendMessage(listModel);
            }
            else
            {
                //filterSelectionScreen.applyFilterPreview(name);
            }

            filterSelectionScreen.applyFilterPreview(name);

            selectedFilterName = name;
            selectedFilterId = filterIcon.filterId;


        }

        FilterScript.selectItemByName(name);
    }

    function applyFilterPreview(name, param) {
        filter.applyFilterByName(name, filterSelectionScreen.darkAreas, true, param);
    }

    function applyFilterLarge(name, param) {
        filter.applyFilterByName(name, filterSelectionScreen.darkAreas, false, param);
    }

    Component.onDestruction:{
        filter.filterApplyCompleted.disconnect(filterFlow.completed);
        filter.filterApplyError.disconnect(filterFlow.error);

        FilterScript.destroyAll();
    }

    /******************************
     * Apply Filter Preview Worker
     ******************************/

    /*
    WorkerScript {
       id: applyFilterPreviewWorker
       source: "../js/applyFilterPreview.js"

       onMessage:
       {
           filterSelectionScreen.listModel.destroy(0);
           //CreateComponent.destroyComponent(filterSelectionScreen.dialog.getPageId(),0);
           filterSelectionScreen.dialog.destroy(0);
       }
    }
    */


    MouseArea {
        anchors.fill: parent
    }

    Header {
        id: header
        hasBack: true
        hasNext: true
        anchors.top: parent.top
        property variant dialog
        property variant listModel
        onBackClicked: {
            var dialog = CreateComponent.createConfirmationDialog("../", filterSelectionScreen, "Discard Changes?");
            dialog.clicked.connect(
                function() {
                    pageStack.replace(Qt.resolvedUrl("CaptureScreen.qml"), null, true);
                }
            );
        }
        onNextClicked: {
            dialog = CreateComponent.createLoadingDialog(filterSelectionScreen,"MOLOing...");
            dialog.cancelBtnAvailable = false;
            //listModel = Qt.createQmlObject("import QtQuick 1.0; ListModel{id:listModel}",header,"");
            //listModel.append({'filterScreen':filterSelectionScreen,
            //                 'filterName':selectedFilterName});
            //applyFilterLargeWorker.sendMessage(listModel);

            applyFilterLarge(selectedFilterName, filterSelectionScreen.colorPicked);
        }

        /*
        WorkerScript {
           id: applyFilterLargeWorker
           source: "../js/applyFilterLarge.js"

           onMessage:
           {
               header.listModel.destroy(0);
               CreateComponent.destroyComponent(header.dialog.getPageId(),0);
               storageManager.saveProcessedImageToGallery(storageDriveIndex);
               pageStack.push(Qt.resolvedUrl("ShareScreen.qml"),{
                                  filterName: filterSelectionScreen.selectedFilterName,
                                  filterId: filterSelectionScreen.selectedFilterId,
                                  darkAreas: filterSelectionScreen.darkAreas,
                                  filepathLarge: filterSelectionScreen.filepathLarge
                              });
           }
        }
        */
    }

    HeaderBar {
        id: headerCaption
        anchors.top: header.bottom
        text: qsTr("Select Effect Filter")

        Button {
            visible: rotatable
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            bitmap: "../res/btn_rotate_left.png"
            bitmap_pressed: "../res/btn_rotate_left_click.png"
            onClicked: {
                filter.rotateSourcePhoto(-90);
                onFilterIconClicked(selectedFilterName, true);
            }
        }

        Button {
            visible: rotatable
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            bitmap: "../res/btn_rotate_right.png"
            bitmap_pressed: "../res/btn_rotate_right_click.png"
            onClicked: {
                filter.rotateSourcePhoto(90);
                onFilterIconClicked(selectedFilterName, true);
            }
        }
    }

    Image {
        id: fulfillAreaTop
        width: parent.width
        //fillMode: Image.Stretch
        anchors.top: headerCaption.bottom
        source: "../res/fulfill_bar_top.png"
        height: themeManager.isPortrait ? sourceSize.height : 0
    }

    SimpleImage {
        id: previewImage
        width: themeManager.isPortrait ? parent.width : themeManager.previewImageSize
        height: themeManager.isPortrait ? parent.width : themeManager.previewImageSize
        anchors.top: fulfillAreaTop.bottom
        source: filter.getSourcePreviewPath() // ".MOLOME/output/source_preview.jpg" //"image://imageprovider/output/source_preview.jpg"
    }

    Image {
        id: fulfillAreaBottom
        width: parent.width
        fillMode: Image.Stretch
        anchors.top: previewImage.bottom
        anchors.bottom: filterSelectionBar.top
        source: "../res/fulfill_bar_bottom.png"
    }

    Image {
        id: filterSelectionBar
        source: themeManager.isPortrait ? "../res/select_effect_filter_side_bg_wide.png" : "../res/select_effect_filter_side_right_bg_wide.png"
        anchors.bottom: parent.bottom

        Flickable {
            id: filterArea
            clip: true
            flickableDirection: themeManager.isPortrait ? Flickable.HorizontalFlick : Flickable.VerticalFlick
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            anchors.topMargin: 5
            anchors.bottomMargin: 5
            contentWidth: filterFlow.width
            contentHeight: filterFlow.height

            Flow {
                id: filterFlow

                //width: themeManager.isPortrait ? childrenRect.width : filterSelectionBar.width
                height: themeManager.isPortrait ? filterSelectionBar.height : childrenRect.height
            }

            Component.onCompleted: {
                if (themeManager.isPortrait)
                    filterFlow.height = filterSelectionBar.height
                else
                    filterFlow.width = filterSelectionBar.width
            }

        }
    }


    function previewCompleted(path)
    {
        if (typeof dialog !== 'undefined' && dialog !== null)
        {
            CreateComponent.destroyComponent(dialog.getPageId(),0);
            dialog = null;
        }

        previewImage.source = "";
        previewImage.source = path;//"output/processed_preview_.jpg";
    }

    function completed(path)
    {
        filterSelectionScreen.filepathLarge = path;

        CreateComponent.destroyComponent(header.dialog.getPageId(),0);
        storageManager.saveProcessedImageToGallery(storageDriveIndex);
        Qt.quit();
        /*pageStack.push(Qt.resolvedUrl("ShareScreen.qml"),{
                           filterName: filterSelectionScreen.selectedFilterName,
                           filterId: filterSelectionScreen.selectedFilterId,
                           darkAreas: filterSelectionScreen.darkAreas,
                           filepathLarge: filterSelectionScreen.filepathLarge
                       });
                       */
    }

    function error(reason)
    {
        console.debug("$$$$"+reason);
    }

}

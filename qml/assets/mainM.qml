import QtQuick 1.0
import MOLOMELib 1.0
import com.nokia.meego 1.0
import "../util/constant.js" as Constant
import "../util/common.js" as Common
import "js/storage.js" as Storage
import "Screen"
import "../platforms"


PageStackWindow {
    id: main

    initialPage: mainPage

    MeeGoInitialPage { id: mainPage }

    //WelcomeScreen {id: mainPage}

    color: "black"

    property int storageDriveIndex
    property int finalImageResolution: 600
    property int autoRefreshTime: 180000
    property bool isAutoRefreshOn

    showToolBar: false
    showStatusBar: false

    function changeAutoReFresh(timeInterval) {
        main.autoRefreshTime = 0;
        main.autoRefreshTime = timeInterval *(60* 1000);
    }

    function fromWhrerChange(_storageDriveIndex) {
        main.storageDriveIndex = _storageDriveIndex;
    }

    function autoRefreshOn() {
        timerAutoRefresh.start();
    }

    function autoRefreshOff() {
        timerAutoRefresh.stop();
    }

    function getCommon()
    {
        return Common;
    }

    PageStack {
        id: pageStack
        anchors { left: parent.left; right: parent.right; top: parent.top; bottom: parent.bottom }
    }

    CommonCPP{
        id: commonCPP
    }

    FilterManager {
        id: filter;
    }

    UserManager {
        id: userManager
    }

    ImageProcessor {
        id:imageProcessor
    }

    //Languagemanager {
    //    id: languageManager
    //}

    //MolomeLanguage {
    //    id: molomeLanguage
    //}

    DateTimeModel {
        id: dateTimeModel
    }

    ThemeManager {
        id: themeManager
    }

    StorageManager {
        id: storageManager
    }

    Timer {
        id: timerAutoRefresh
        interval: autoRefreshTime; running: false; repeat: true
        onTriggered: globalServices.emitRefreshRequested();
    }

    /*
    Timer {
        id: timerCachePruner
        interval: 1000; running: false; repeat: false;
        onTriggered: commonCPP.pruningCache();
    }
    */

    Component.onCompleted: {
        Storage.initialize();

        if (userManager.isLoggedIn())
            pageStack.replace(Qt.resolvedUrl("Screen/CaptureScreen.qml"), null, true);
        else
            pageStack.replace(Qt.resolvedUrl("Screen/WelcomeScreen.qml"), null, true);

        main.storageDriveIndex = (Storage.getData("storageDriveIndex") === null) ? 0 : Storage.getData("storageDriveIndex");
        main.finalImageResolution = (Storage.getData("finalImageResolution") === null) ? 600 : Storage.getData("finalImageResolution");
        filter.setFinalImageResolution(main.finalImageResolution)
        main.autoRefreshTime = (Storage.getData("timeInterval") === null) ? (3*60)*1000 : (Storage.getData("timeInterval")) *60*1000;
        if( (Storage.getData("isAutoRefreshOn") === null) ||  (Storage.getData("isAutoRefreshOn") === "1"))
            main.isAutoRefreshOn =  true;
        else if( (Storage.getData("isAutoRefreshOn") === "0"))
            main.isAutoRefreshOn =  false;
        timerAutoRefresh.interval = main.autoRefreshTime

        if (!main.isAutoRefreshOn)
            timerAutoRefresh.stop()
        else
            timerAutoRefresh.start()
        //timerCachePruner.start()
    }

    Component.onDestruction: {
        globalServices.destroyObjects();
    }
}

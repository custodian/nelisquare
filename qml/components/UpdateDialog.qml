import Qt 4.7
import com.nokia.meego 1.0

QueryDialog  {
    id: updateDialog
    property string version: ""
    property string build: ""
    property string url: ""
    property string changelog: ""

    icon: "image://theme/icon-m-content-system-update-dialog"
    titleText: "New update available"
    message: "Version: " + version
             +"<br>Type: " + configuration.checkupdates
             +"<br>Build: " + build
             +"<br><br>Changelog:"
             +"<br>"+changelog
    acceptButtonText: "Update!"
    rejectButtonText: "No, thanks"
    onAccepted: {
        Qt.openUrlExternally(url);
        windowHelper.disableSwype(false);
        Qt.quit();
    }
    onRejected: {

    }
}

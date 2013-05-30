import Qt 4.7
import com.nokia.meego 1.0

QueryDialog  {
    id: updateDialog
    property string version: ""
    property string build: ""
    property string url: ""
    property string changelog: ""

    icon: "image://theme/icon-m-content-system-update-dialog"
    titleText: qsTr("New update available")
    message: qsTr("Version: %1<br>Type: %2<br>Build: %3<br><br>Changelog: <br>%4")
        .arg(version)
        .arg(configuration.checkupdates)
        .arg(build)
        .arg(changelog);

    acceptButtonText: qsTr("Update!")
    rejectButtonText: qsTr("No, thanks")
    onAccepted: {
        Qt.openUrlExternally(url);
        windowHelper.disableSwype(false);
        Qt.quit();
    }
    onRejected: {

    }
}

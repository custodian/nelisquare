import Qt 4.7
import QtQuick 1.1
import com.nokia.meego 1.0
import "."

//Rectangle   {
Page {
    id: pageWrapper

    width: parent.width
    height: parent.height

    //color: mytheme.colors.backgroundMain
    //property alias color: background.color
    property string color
    property alias pagetop: pageHeader.bottom
    //property Item tools: commonTools
    tools : commonTools
    property alias dummyMenu: dummyMenu
    property alias headerText: pageHeader.headerText
    property alias headerIcon: pageHeader.headerIcon

    Component.onCompleted: {
        if (pageWrapper.load)
            pageWrapper.load()
    }

/*
    Rectangle {
        id: background
        anchors.fill: parent
        color: mytheme.colors.backgroundMain
    }
*/

    PageHeader {
        id: pageHeader
        z: 1
        headerText: "Awesome header";
    }

    function waiting_show() {
        pageHeader.busy = true;
    }

    function waiting_hide() {
        pageHeader.busy = false;
    }


    function show_error(msg) {
        show_error_base(msg);
    }

    function show_error_base(msg){
        waiting_hide();
        console.log("Error: "+ msg);
        notificationDialog.message += msg + "<br/>"
        notificationDialog.state = "shown";
        notificationDialog.hider.restart();
    }

    function show_info(msg) {
        notificationDialog.message = msg
        notificationDialog.state = "shown";
    }

    Menu {
        id: dummyMenu
        MenuLayout {
            MenuItem {
                text: qsTr("Settings")
                onClicked: {
                    stack.replace(Qt.resolvedUrl("../pages/Settings.qml"));
                }
            }
            MenuItem {
                text: qsTr("Exit")
                onClicked: {
                    windowHelper.disableSwype(false);
                    Qt.quit();
                }
            }
        }
    }

}

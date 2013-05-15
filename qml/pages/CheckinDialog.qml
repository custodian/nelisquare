import Qt 4.7
import com.nokia.meego 1.0
import "../components"

import "../js/api.js" as Api

//Sheet {
PageWrapper {
    id: checkin
    //width: parent.width
    //height: items.height + 20
    //color: mytheme.colors.backgroundBlueDark
    state: "hidden"
    property string venueID: ""
    property string venueName: ""
    property bool useFacebook: false
    property bool useTwitter: false
    property bool useFriends: true

    signal checkin(string venueID, string comment, bool friends, bool facebook, bool twitter)

    headerText: "NEW CHECK-IN"
    headerIcon: "../icons/icon-header-newcheckin.png"
    headerBubble: false

    function reset() {
        shoutText.text = "";
    }

    function checkinCompleted(checkinID, message, specials) {
        waiting_hide();
        show_info(message);
        stack.replace(Qt.resolvedUrl("../pages/Checkin.qml"),{"checkinID":checkinID , "specials": specials});
    }

    onCheckin: {
        waiting_show();
        Api.checkin.addCheckin(venueID, checkin, comment, friends, facebook, twitter);
    }
    tools: ToolBarLayout{
        parent: checkin
        //anchors.centerIn: parent;
        anchors{ left: parent.left; right: parent.right; margins: mytheme.graphicSizeLarge }
        ButtonRow{
            exclusive: false
            spacing: mytheme.graphicSizeTiny
            ToolButton {
                text: "CHECK IN"
                platformStyle: SheetButtonAccentStyle { }
                onClicked: {
                    enabled = false;
                    checkin.checkin( checkin.venueID, shoutText.text, checkin.useFriends, checkin.useFacebook, checkin.useTwitter )

                }
            }
            ToolButton {
                text: "Cancel"
                onClicked: stack.pop();
            }
        }
    }

    Flickable{
        id: flickableArea
        anchors.top: pagetop
        width: parent.width
        height: parent.height - y
        contentWidth: parent.width

        clip: true
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds
        pressDelay: 100

        Column {
            onHeightChanged: {
                flickableArea.contentHeight = height + y;
            }

            id: items
            x: 10
            y: 10
            width: parent.width - 20
            spacing: 10

            Text {
                id: venueName
                text: checkin.venueName
                width: parent.width
                font.pixelSize: 24
                color: mytheme.colors.textColorOptions
            }

            TextArea {
                id: shoutText
                x: 5
                width: parent.width - 10
                height: 130

                placeholderText: mytheme.textDefaultCheckin
                textFormat: TextEdit.PlainText

                font.pixelSize: mytheme.fontSizeMedium

                onTextChanged: {
                    if (text.length>140) {
                        errorHighlight = true;
                    } else {
                        errorHighlight = false;
                    }
                }
                Text {
                    anchors { right: parent.right; bottom: parent.bottom; margins: mytheme.paddingMedium }
                    font.pixelSize: mytheme.fontSizeMedium
                    color: mytheme.colors.textColorTimestamp
                    text: 140 - shoutText.text.length
                }
            }

            Column {
                width: parent.width

                SectionHeader {
                    text: "Sharing options"
                }

                SettingSwitch {
                    text: "Share with Friends"
                    checked: checkin.useFriends
                    onCheckedChanged: {
                        checkin.useFriends = checked
                    }
                }

                SettingSwitch {
                    text: "Post to Facebook"
                    checked: checkin.useFacebook
                    onCheckedChanged: {
                        checkin.useFacebook = checked
                    }
                }

                SettingSwitch {
                    text: "Post to Twitter"
                    checked: checkin.useTwitter
                    onCheckedChanged: {
                        checkin.useTwitter = checked
                    }
                }
            }
        }
    }
}

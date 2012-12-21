import Qt 4.7
import com.nokia.meego 1.0

import "../js/api-checkin.js" as CheckinAPI

Sheet {
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

    acceptButtonText: "CHECKIN"
    rejectButtonText: "Cancel"

    function reset() {
        shoutText.text = "";
    }

    function checkinCompleted(checkinID) {
        waiting_hide();
        pageStack.push(Qt.resolvedUrl("../pages/Checkin.qml"),{"checkinID":checkinID});
    }

    onCheckin: {
        waiting_show();
        CheckinAPI.addCheckin(venueID, checkin, comment, friends, facebook, twitter);
    }

    onAccepted: {
        checkin.checkin( checkin.venueID, shoutText.text, checkin.useFriends, checkin.useFacebook, checkin.useTwitter )
    }

    onRejected: {

    }

    content: Column {
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

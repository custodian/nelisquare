import Qt 4.7
import com.nokia.meego 1.0
import "../components"

import "../js/api.js" as Api

//Sheet {
PageWrapper {
    id: debuginfo
    //width: parent.width
    //height: items.height + 20
    //color: mytheme.colors.backgroundBlueDark
    state: "hidden"
    property variant content: {}

    signal submit()

    headerText: qsTr("DEBUG SUBMIT")
    headerIcon: "image://theme/icon-l-settings-main-view"
    headerBubble: false

    function reset() {
        shoutText.text = "";
    }

    function submitCompleted(status, message) {
        waiting_hide();

        if (!status) {
            buttonSubmit.enabled = true;
            show_info(message);
        }
        else {
            show_info(message + "<br>" + qsTr("Thank you for submit!<br>This will be implemented soon!"));
            stack.pop();
        }
    }

    onSubmit: {
        waiting_show();
        Api.submitDebugInfo(content, submitCompleted);
    }

    tools: ToolBarLayout{
        parent: debuginfo
        //anchors.centerIn: parent;
        anchors{ left: parent.left; right: parent.right; margins: mytheme.graphicSizeLarge }
        ButtonRow{
            exclusive: false
            spacing: mytheme.graphicSizeTiny
            ToolButton {
                id: buttonSubmit
                text: qsTr("SUBMIT")
                platformStyle: SheetButtonAccentStyle { }
                onClicked: {
                    enabled = false;
                    debuginfo.submit();
                }
            }
            ToolButton {
                text: qsTr("Cancel")
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

        //DBG clip: true
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
                text: qsTr("You can help me with Nelisquare development by submitting debug info.\n\nThe following information are going to be submitted:")
                width: parent.width
                wrapMode: Text.WordWrap
                font.pixelSize: 24
                color: mytheme.colors.textColorOptions
            }

            TextArea {
                id: shoutText
                x: 5
                width: parent.width - 10

                text: JSON.stringify(content);
                readOnly: true

                textFormat: TextEdit.PlainText

                font.pixelSize: mytheme.fontSizeMedium

                onTextChanged: {
                    if (text.length>15000) {
                        errorHighlight = true;
                    } else {
                        errorHighlight = false;
                    }
                }
                Text {
                    anchors {
                        right: parent.right;
                        bottom: parent.bottom;
                        bottomMargin: mytheme.paddingMedium;
                        rightMargin: mytheme.paddingXLarge
                    }
                    font.pixelSize: mytheme.fontSizeMedium
                    color: mytheme.colors.textColorTimestamp
                    text: 16000 - shoutText.text.length
                }
            }
        }
    }
}

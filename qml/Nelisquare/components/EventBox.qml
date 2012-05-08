import Qt 4.7

Item {
    signal userClicked()
    signal areaClicked()
    signal deleteEvent()

    property string userID: ""
    property string userName: ""
    property string userShout: ""
    property string venueID: ""
    property string venueName: ""
    property string venueCity: ""
    property string venuePhoto: ""
    property string venueAddress: ""
    property string createdAt: ""
    property string eventOwner: ""
    property int comments: 0
    property int fontSize: 22

    property alias userPhoto: profileImage

    property bool activeWhole: false
    property bool showRemoveButton: true

    id: eventItem
    width: parent.width
    height: titleContainer.height + 2

    Rectangle {
        id: titleContainer
        color: mouseArea.pressed ? "#ddd" : "#eee"
        y: 1
        width: parent.width
        height: statusTextArea.height + 16 < profileImage.height+2 ? profileImage.height + 16 : statusTextArea.height + 16

        ProfilePhoto {
            id: profileImage

            onClicked: {
                eventItem.userClicked();
            }
        }

        Column {
            id: statusTextArea
            spacing: 4
            x: profileImage.width + 12
            y: 4
            width: parent.width - x - 12

            Text {
                id: messageText
                color: theme.toolbarDarkColor
                font.pixelSize: fontSize
                font.bold: true
                width: parent.width
                text: (userName + (venueName !="" ? ("<span style='color:#000'> @ </span>" + venueName):""))
                wrapMode: Text.Wrap
                visible: messageText.text != ""
            }

            Text {
                id: commentText
                color: "#555"
                font.pixelSize: fontSize
                width: parent.width
                text: userShout!="" ? userShout : (venueAddress + " " + venueCity)
                wrapMode: Text.Wrap
                visible: venuePhoto == "" && text.length > 1
            }
            Row {
                width: parent.width
                ProfilePhoto {
                    photoUrl: venuePhoto
                    photoSize: 200
                    photoBorder: 2
                }
                visible: venuePhoto.length>0
            }
            Row {
                width: parent.width
                Text {
                    color: "#888"
                    font.pixelSize: fontSize - 2
                    width: parent.width * 0.7
                    text: createdAt
                    wrapMode: Text.Wrap
                }
                Image {
                    id: commentImage
                    source: "../pics/112-group@2x.png"
                    smooth: true
                    width: 32
                    height: 21
                    visible: comments>0
                }
                Text {
                    id: commentCount
                    color: theme.toolbarDarkColor
                    font.pixelSize: fontSize - 2
                    text: comments
                    visible: comments>0
                }
            }
        }
        MouseArea {
            anchors.fill: statusTextArea
            onClicked: {
                eventItem.areaClicked();
            }
        }

        Rectangle {
            anchors.right: parent.right
            color: "black"
            width: 32
            height: 32
            visible: eventOwner == "self" && showRemoveButton

            Image {
                source: "../pics/delete.png"
                smooth: true
            }            

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    eventItem.deleteEvent()
                }
            }
        }
    }

    Rectangle {
        width:  parent.width
        x: 4
        y: eventItem.height - 1
        height: 1
        color: "#ddd"
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: {
            eventItem.areaClicked();
        }
        visible: activeWhole
    }
}

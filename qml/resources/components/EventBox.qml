import Qt 4.7

Item {
    signal userClicked()
    signal areaClicked()
    signal deleteEvent()

    property string userID: ""
    property string userName: ""
    property string userShout: ""
    property bool userMayor: false
    property string venueID: ""
    property string venueName: ""
    property string venueCity: ""
    property string venuePhoto: ""
    property string venueAddress: ""
    property string createdAt: ""
    property string eventOwner: ""
    property int commentsCount: 0
    property int fontSize: theme.font.sizeSigns

    property alias userPhoto: profileImage

    property bool activeWhole: false
    property bool showRemoveButton: true
    property bool showSeparator: true

    id: eventItem
    width: parent.width
    height: titleContainer.height + 2

    Rectangle {
        id: titleContainer
        color: mouseArea.pressed ? "#ddd": theme.backgroundMain // "#eee"
        y: 1
        width: parent.width
        height: 10 + Math.max(statusTextArea.height,profileImage.height)

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

            Row {
                width: parent.width
                spacing: userMayor?5:0

                Image {
                    id: mayorImage
                    anchors.verticalCenter: messageText.verticalCenter
                    asynchronous: true
                    source: "https://foursquare.com/img/points/mayor.png"
                    visible: userMayor
                }

                Text {
                    id: messageText
                    color: theme.textColorOptions
                    font.pixelSize: fontSize
                    font.bold: true
                    width: (parent.width - (userMayor?mayorImage.width+5:0))
                    text: (userName + (venueName !="" ? ("<span style='color:"+theme.textColorTimestamp+"'> @ </span>" + venueName):""))
                    wrapMode: Text.Wrap
                    visible: messageText.text != ""
                }
            }

            Text {
                id: commentText
                color: "#555"
                font.pixelSize: fontSize
                width: parent.width
                text: userShout!="" ? userShout : (venueAddress + " " + venueCity)
                wrapMode: Text.Wrap
                visible: text.length > 1
            }
            Row {
                width: parent.width
                ProfilePhoto {
                    photoUrl: venuePhoto
                    photoCache: false
                    photoSize: 200
                    photoBorder: 2
                }
                visible: venuePhoto.length>0
            }
            Row {
                width: parent.width
                spacing: 10
                Text {
                    color: theme.textColorTimestamp
                    font.pixelSize: fontSize - 2
                    width: parent.width * 0.7
                    text: createdAt
                    wrapMode: Text.Wrap
                    visible: createdAt.length>0
                }
                Image {
                    id: commentImage
                    source: "../pics/commentcount.png"
                    asynchronous: true
                    smooth: true
                    //width: 32
                    height: 32
                    fillMode: Image.PreserveAspectFit
                    visible: commentsCount>0
                }
                Text {
                    id: commentCount
                    color: theme.textColorTimestamp
                    font.pixelSize: fontSize - 2
                    text: commentsCount
                    visible: commentsCount>0
                }
                visible: createdAt.length>0 || commentsCount>0
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
            color: titleContainer.color//window.color
            width: 32
            height: 32
            visible: eventOwner == "self" && showRemoveButton

            Image {
                asynchronous: true
                source: "../pics/delete.png"
                width: parent.width
                height: parent.height
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

    /* //separator
    Rectangle {
        width:  parent.width
        y: eventItem.height - 1
        height: 1
        color: "#ccc"
        visible: showSeparator
    }*/

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: {
            eventItem.areaClicked();
        }
        visible: activeWhole
    }
}

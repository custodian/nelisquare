import Qt 4.7
import "."

Rectangle {
    id: photoShare
    width: parent.width
    height: items.height + 20
    color: mytheme.colors.backgroundBlueDark
    state: "hidden"

    signal cancel()
    signal uploadPhoto(variant params)

    property variant options //type, id, owner page.
    property variant owner //owner page (photo selection page)

    property string photoUrl: ""
    property bool useFacebook: false
    property bool useTwitter: false
    property bool makePublic: false

    onPhotoUrlChanged: {
        selectedPhoto.photoUrl = photoShare.photoUrl
    }

    function reset() {
    }

    Column {
        id: items
        x: 10
        y: 10
        width: parent.width - 20
        spacing: 10

        Text {
            text: "Selected photo"
            width: parent.width
            font.pixelSize: 24
            color: mytheme.colors.textColorSign
        }

        Row {
            width: parent.width
            spacing: 10

            ProfilePhoto {
                id: selectedPhoto
                anchors.verticalCenter: parent.verticalCenter
                photoAspect: Image.PreserveAspectFit
                photoBorder: 2
                photoSize: 240
            }

            Rectangle {
                width: parent.width - selectedPhoto.width - parent.spacing
                color: mytheme.colors.toolbarDarkColor
                border.color: "#2774aA"
                border.width: 1
                height: 10 + twitterRow.y + twitterRow.height
                radius: 5
                smooth: true

                Row {
                    id: friendsRow
                    y: 10
                    x: 10
                    spacing: 10
                    width: parent.width
                    height: 42

                    Rectangle {
                        border.width: 1
                        border.color: mytheme.colors.checktapBorderColor
                        color: friendsMouseArea.pressed ? mytheme.colors.checktapBackgroundActive : mytheme.colors.checktapBackground
                        radius: 5
                        width: 42
                        height: 42

                        Image {
                            anchors.centerIn: parent
                            source: "../pics/"+mytheme.name+"/checktap.png"
                            visible: photoShare.makePublic
                        }

                        MouseArea {
                            id: friendsMouseArea
                            anchors.fill: parent
                            onClicked: {
                                photoShare.makePublic = !photoShare.makePublic;
                            }
                        }
                    }

                    Text {
                        text: "Make public"
                        width: parent.width
                        wrapMode: Text.Wrap
                        font.pixelSize: 22
                        anchors.verticalCenter: parent.verticalCenter
                        color: mytheme.colors.textColorSign
                    }
                }

                Row {
                    id: facebookRow
                    y: 20 + 42
                    x: 10
                    spacing: 10
                    width: parent.width
                    height: 42

                    Rectangle {
                        border.width: 1
                        border.color: mytheme.colors.checktapBorderColor
                        color: facebookMouseArea.pressed ? mytheme.colors.checktapBackgroundActive : mytheme.colors.checktapBackground
                        radius: 5
                        width: 42
                        height: 42

                        Image {
                            anchors.centerIn: parent
                            source: "../pics/"+mytheme.name+"/checktap.png"
                            visible: photoShare.useFacebook
                        }

                        MouseArea {
                            id: facebookMouseArea
                            anchors.fill: parent
                            onClicked: {
                                photoShare.useFacebook = !photoShare.useFacebook;
                            }
                        }
                    }

                    Text {
                        text: "Facebook"
                        width: parent.width
                        wrapMode: Text.Wrap
                        font.pixelSize: 22
                        anchors.verticalCenter: parent.verticalCenter
                        color: mytheme.colors.textColorSign
                    }
                }

                Row {
                    y: 30 + 42*2
                    x: 10
                    id: twitterRow
                    spacing: 10
                    width: parent.width - 64
                    height: 42

                    Rectangle {
                        border.width: 1
                        border.color: mytheme.colors.checktapBorderColor
                        color: twitterMouseArea.pressed ? mytheme.colors.checktapBackgroundActive : mytheme.colors.checktapBackground
                        radius: 5
                        width: 42
                        height: 42

                        Image {
                            anchors.centerIn: parent
                            source: "../pics/"+mytheme.name+"/checktap.png"
                            visible: photoShare.useTwitter
                        }

                        MouseArea {
                            id: twitterMouseArea
                            anchors.fill: parent
                            onClicked: {
                                photoShare.useTwitter = !photoShare.useTwitter;
                            }
                        }
                    }

                    Text {
                        text: "Twitter"
                        width: parent.width
                        wrapMode: Text.Wrap
                        font.pixelSize: 22
                        anchors.verticalCenter: parent.verticalCenter
                        color: mytheme.colors.textColorSign
                    }
                }
            }
        }

        Item {
            width: parent.width
            height: checkinButton.height

            ButtonGreen {
                id: checkinButton
                label: "Upload photo"
                width: parent.width - 130
                onClicked: {
                    var params = options;
                    params["path"] = photoUrl;
                    params["facebook"] = useFacebook;
                    params["twitter"] = useTwitter;
                    params["public"] = makePublic;
                    photoShare.uploadPhoto(params)
                }
            }

            ButtonGreen {
                label: "Cancel"
                x: parent.width - 120
                width: 120
                onClicked: photoShare.cancel();
            }
        }
    }

    Image {
        id: shadow
        source: "../pics/top-shadow.png"
        width: parent.width
        y: parent.height - 1
    }

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: photoShare
                y: -200-photoShare.height
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: photoShare
                y: 0
            }
        }
    ]

    transitions: [
        Transition {
            from: "shown"
            SequentialAnimation {
                PropertyAnimation {
                    target: photoShare
                    properties: "y"
                    duration: 300
                    easing.type: "InOutQuad"
                }
                PropertyAction {
                    target: photoShare
                    properties: "visible"
                    value: false
                }
            }
        },
        Transition {
            to: "shown"
            SequentialAnimation {
                PropertyAction {
                    target: photoShare
                    properties: "visible"
                    value: true
                }
                PropertyAnimation {
                    target: photoShare
                    properties: "y"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}

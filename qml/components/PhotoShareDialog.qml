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

            Column {
                width: parent.width - selectedPhoto.width - 10

                SectionHeader {
                    text: "Sharing"
                }

                SettingSwitch {
                    text: "Public"
                    checked: photoShare.makePublic
                    onCheckedChanged: {
                        photoShare.makePublic = checked
                    }
                }
                SettingSwitch {
                    text: "Facebook"
                    checked: photoShare.useFacebook
                    onCheckedChanged: {
                        photoShare.useFacebook = checked
                    }
                }
                SettingSwitch {
                    text: "Twitter"
                    checked: photoShare.useTwitter
                    onCheckedChanged: {
                        photoShare.useTwitter = checked
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

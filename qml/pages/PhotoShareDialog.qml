import Qt 4.7
import com.nokia.meego 1.0
import "../components"

PageWrapper {
    id: photoShare
    width: parent.width
    height: parent.height
    color: mytheme.colors.backgroundBlueDark
    state: "hidden"

    property variant options //type, id, owner page.
    property variant owner //owner page (photo selection page)

    property string photoUrl: ""
    property bool useFacebook: configuration.sharePhotoFacebook === "1"
    property bool useTwitter: configuration.sharePhotoTwitter === "1"
    property bool makePublic: configuration.sharePhotoPublic === "1"

    headerText: qsTr("PHOTO UPLOAD")
    headerIcon: "../icons/icon-header-photos.png"
    headerBubble: false

    onPhotoUrlChanged: {
        selectedPhoto.photoUrl = photoShare.photoUrl
    }

    tools: ToolBarLayout{
        parent: photoShare
        //anchors.centerIn: parent;
        anchors{ left: parent.left; right: parent.right; margins: mytheme.graphicSizeLarge }
        ButtonRow{
            exclusive: false
            spacing: mytheme.graphicSizeTiny
            ToolButton {
                text: qsTr("UPLOAD")
                platformStyle: SheetButtonAccentStyle { }
                onClicked: {
                    var params = options;
                    params["path"] = photoUrl;
                    params["facebook"] = useFacebook;
                    params["twitter"] = useTwitter;
                    params["public"] = makePublic;
                    owner.uploadPhoto(params);
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

            ProfilePhoto {
                id: selectedPhoto
                anchors.horizontalCenter: parent.horizontalCenter
                photoAspect: Image.PreserveAspectFit
                photoBorder: 2
                photoSize: 300
            }

            Column {
                spacing: 10
                width:parent.width
                visible: options.type !== "avatar"

                SectionHeader {
                    text: qsTr("Sharing options")
                }

                SettingSwitch {
                    text: qsTr("Public")
                    checked: photoShare.makePublic
                    onCheckedChanged: {
                        configuration.sharePhotoPublic = (checked) ? "1": "0"
                    }
                }
                SettingSwitch {
                    text: qsTr("Post to Facebook")
                    checked: photoShare.useFacebook
                    onCheckedChanged: {
                        configuration.sharePhotoFacebook = (checked) ? "1": "0"
                    }
                }
                SettingSwitch {
                    text: qsTr("Post to Twitter")
                    checked: photoShare.useTwitter
                    onCheckedChanged: {
                        configuration.sharePhotoTwitter = (checked) ? "1": "0"
                    }
                }
            }
        }
    }
}

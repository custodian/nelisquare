import Qt 4.7
import com.nokia.meego 1.0
import "../components"

PageWrapper {
    signal venue(string venueID)

    id: badgeInfo
    width: parent.width
    height: parent.height
    color: mytheme.colors.backgroundMain

    property string name: ""
    property string image: ""
    property string imageLarge: ""
    property string info: ""
    property string venueName: ""
    property string venueID: ""
    property string time: ""
    property string index: ""

    headerText: name
    headerIcon: "../icons/icon-header-badges.png"

    function load() {
        var page = badgeInfo;
        page.venue.connect(function(venueID) {
            stack.push(Qt.resolvedUrl("Venue.qml"),{"venueID":venueID});
        });
    }

    Flickable{
        id: flickableArea
        anchors.top: pagetop
        width: parent.width
        height: parent.height
        contentWidth: parent.width

        clip: true
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds
        pressDelay: 100

        Column {
            x: 10
            y: 20
            width: parent.width - 20
            spacing: 20

            onHeightChanged: {
                flickableArea.contentHeight = y + height + spacing;
            }

            Image {
                width: 300
                height: 300
                anchors.horizontalCenter: parent.horizontalCenter
                source: imageLarge

                Image {
                    anchors.centerIn: parent
                    source: "../pics/"+mytheme.name+"/loader.png"
                    visible: (parent.status != Image.Ready)
                }
            }

            /*Text {
                x: 10
                font.pixelSize: mytheme.font.sizeSettigs
                color: mytheme.colors.textColorOptions
                text: name
            }*/

            Text {
                x: 10
                width: parent.width - 20
                text: badgeInfo.info
                color: mytheme.colors.textColorOptions
                font.pixelSize: mytheme.font.sizeDefault
                wrapMode: Text.WordWrap
            }


            Text {
                x: 10
                text: '@ ' + venueName
                width: parent.width - 20
                font.pixelSize: mytheme.font.sizeDefault
                color: mytheme.colors.textColorOptions
                wrapMode: Text.WordWrap
                visible: venueName.length>0
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        badgeInfo.venue(venueID);
                    }
                }
            }
            Text {
                x: 10
                width: parent.width - 20
                text: time
                color: mytheme.colors.textColorTimestamp
                font.pixelSize: mytheme.font.sizeSigns
            }
        }
    }

    ScrollDecorator{ flickableItem: flickableArea }
}

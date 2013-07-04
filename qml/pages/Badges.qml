import Qt 4.7
import com.nokia.meego 1.0
import "../components"

import "../js/api.js" as Api

PageWrapper {
    signal badge(variant params)

    property string userID: ""
    property alias badgeModel: badgeModel

    id: badgesPage
    width: parent.width
    height: parent.height
    color: mytheme.colors.backgroundMain

    headerText: qsTr("BADGES")
    headerIcon: "../icons/icon-header-badges.png"

    function load() {
        var page = badgesPage;
        page.badge.connect(function(params) {
            stack.push(Qt.resolvedUrl("BadgeInfo.qml"),params);
        });
        Api.users.loadBadges(page,userID);
    }

    ListModel {
        id: badgeModel
    }

    GridView {
        id: badgeGrid
        anchors {
            top: pagetop
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        //DBG clip: true

        cellWidth: parent.width/3
        cellHeight: cellWidth

        model: badgeModel
        delegate: badgeDelegate
        header: Item {
                width: parent.width
                height: 20
            }
    }

    ScrollDecorator{ flickableItem: badgeGrid }

    Component {
        id: badgeDelegate

        Item {
            width: badgeGrid.cellWidth

            CacheImage {
                id: badgeImage
                width: 114
                height: 114
                sourceUncached: model.image
                anchors.horizontalCenter: parent.horizontalCenter

                MouseArea {
                    anchors.fill: badgeImage
                    onClicked: {
                        //To get rid of internal properties
                        badgesPage.badge(JSON.parse(JSON.stringify(model)));
                    }
                }
            }
            Text {
                text: model.name;
                y: badgeImage.y + badgeImage.height
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: mytheme.font.sizeSigns
                color: mytheme.colors.textColorOptions
            }
        }
    }
}

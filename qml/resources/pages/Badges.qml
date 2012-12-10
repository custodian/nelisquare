import Qt 4.7
import "../components"

import "../js/api-user.js" as UserAPI

PageWrapper {
    signal badge(variant params)

    property string userID: ""
    property alias badgeModel: badgeModel

    id: badgesPage
    width: parent.width
    height: parent.height
    color: mytheme.colors.backgroundMain

    function load() {
        var page = badgesPage;
        page.badge.connect(function(params) {
            pageStack.push(Qt.resolvedUrl("BadgeInfo.qml"),params);
        });
        UserAPI.loadBadges(page,userID);
    }

    ListModel {
        id: badgeModel
    }

    GridView {
        id: badgeGrid
        anchors.fill: parent
        clip: true

        cellWidth: parent.width/3
        cellHeight: cellWidth

        model: badgeModel
        delegate: badgeDelegate
        header: Item {
                width: parent.width
                height: 20
            }
    }

    Component {
        id: badgeDelegate

        Item {
            width: badgeGrid.cellWidth

            Image {
                id: badgeImage
                width: 114
                height: 114
                source: cache.get(model.image)
                anchors.horizontalCenter: parent.horizontalCenter

                MouseArea {
                    anchors.fill: badgeImage
                    onClicked: {
                        //var badgeObj = model;
                        /*{
                            "name":model.name,
                            "image":model.imageLarge,
                            "info":model.info,
                            "venueName":model.venueName,
                            "venueID":model.venueID,
                            "time":model.time
                        }*/
                        badgesPage.badge(model);
                    }
                }
                Image {
                    anchors.centerIn: badgeImage
                    source: "../pics/"+mytheme.name+"/loader.png"
                    visible: (badgeImage.status != Image.Ready)
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

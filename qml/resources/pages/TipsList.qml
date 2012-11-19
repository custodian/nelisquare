import Qt 4.7
import "../components"

import "../js/api-tip.js" as TipAPI

Rectangle {
    id: tipsList
    signal tip(string id)
    signal update()

    property alias tipsModel: tipsModel

    width: parent.width
    height: parent.height
    color: theme.colors.backgroundMain

    property string baseID: ""
    property string baseType: "venues" //"venues/ID/tips" , "lists/ID/todos"("users/ID/tips")
    property string sortType: "popular" //"friends|nearby", "popular", "recent"
    property int loaded: 0
    property int batchsize: 20
    property bool completed: false

    function load() {
        var page = tipsList;
        page.tip.connect(function(tip) {
            pageStack.push(Qt.resolvedUrl("TipPage.qml"),{"tipID":tip});
        });
        page.update.connect(function(){
            TipAPI.loadTipsList(page, baseID);
        });
        page.update();
    }

    ListModel {
        id: tipsModel
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { }
    }

    ListView {
        model: tipsModel
        width: parent.width
        height: parent.height - y
        delegate: tipDelegate
        cacheBuffer: 400

        header: LineGreen{
            width: tipsList.width
            anchors.horizontalCenter: parent.horizontalCenter
            height: 30
            text: "TIPS LIST"
        }
    }

    Component {
        id: tipDelegate

        EventBox {
            activeWhole: true

            venueName: model.venueName
            userName: model.userName
            userShout: model.tipText
            createdAt: model.tipAge
            likesCount: model.likesCount
            peoplesCount: model.peoplesCount
            venuePhoto: model.tipPhoto
            venuePhotoSize: 150

            Component.onCompleted: {
                userPhoto.photoUrl = model.userPhoto

                if (loaded === (index + 1)){
                    if (!completed) {
                        update();
                    }
                }
            }
            onAreaClicked: {
                tipsList.tip( model.tipID );
            }
        }
    }
}

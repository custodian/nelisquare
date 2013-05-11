import Qt 4.7
import com.nokia.meego 1.0
import "../components"

import "../js/api.js" as Api

PageWrapper {
    id: tipsList
    signal tip(string id)
    signal update()

    property alias tipsModel: tipsModel

    width: parent.width
    height: parent.height
    color: mytheme.colors.backgroundMain

    headerText: "TIPS LIST"

    property string baseID: ""
    property string baseType: "venues" //"venues/ID/tips" , "lists/ID/todos"("users/ID/tips")
    property string sortType: "popular" //"friends|nearby", "popular", "recent"
    property int loaded: 0
    property int batchsize: 20
    property bool completed: false

    function load() {
        var page = tipsList;
        page.tip.connect(function(tip) {
            stack.push(Qt.resolvedUrl("TipPage.qml"),{"tipID":tip});
        });
        page.update.connect(function(){
            Api.tips.loadTipsList(page, baseID);
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
        id: listViewTips
        anchors.top: pagetop
        model: tipsModel
        width: parent.width
        height: parent.height - y
        delegate: tipDelegate
        cacheBuffer: 400
    }

    ScrollDecorator{ flickableItem: listViewTips }

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

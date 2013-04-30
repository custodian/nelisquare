import Qt 4.7
import "../components"

import "../js/api-user.js" as UserAPI

PageWrapper {
    id: checkinHistory
    signal checkin(string id)
    signal update()

    property string userID: ""

    property int loaded: 0
    property int batchsize: 20
    property bool completed: false

    property alias checkinHistoryModel: checkinHistoryModel

    width: parent.width
    height: parent.height
    color: mytheme.colors.backgroundMain

    function load() {
        var page = checkinHistory;
        page.checkin.connect(function(id) {
            stack.push(Qt.resolvedUrl("Checkin.qml"),{"checkinID":id});
        });
        page.update.connect(function(){
            if (userID === "self")
                UserAPI.loadCheckinHistory(page,userID);
            else
                UserAPI.loadActivityHistory(page,userID);
        })
        page.update();
    }

    ListModel {
        id: checkinHistoryModel
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { }
    }

    ListView {
        model: checkinHistoryModel
        anchors.top: pagetop
        width: parent.width
        height: parent.height - y
        delegate: checkinHistoryDelegate
        //highlightFollowsCurrentItem: true
        //clip: true
        cacheBuffer: 400

        header: LineGreen{
            width: checkinHistory.width
            anchors.horizontalCenter: parent.horizontalCenter
            height: 30
            text: "CHECKIN HISTORY"
        }
    }

    Component {
        id: checkinHistoryDelegate

        EventBox {
            activeWhole: true

            userShout: model.shout
            userMayor: model.mayor
            venueName: model.venueName
            venuePhoto: model.venuePhoto
            createdAt: model.createdAt
            commentsCount: model.commentsCount
            photosCount: model.photosCount
            likesCount: model.likesCount

            Component.onCompleted: {
                userPhoto.photoUrl = model.photo

                if (loaded === (index + 1)){
                    if (!completed) {
                        update();
                    }
                }
            }

            onAreaClicked: {
                checkinHistory.checkin( model.id );
            }
        }
    }
}

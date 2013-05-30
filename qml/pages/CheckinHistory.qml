import Qt 4.7
import com.nokia.meego 1.0
import "../components"

import "../js/api.js" as Api

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

    headerText: qsTr("CHECK-IN HISTORY")
    headerIcon: "../icons/icon-header-checkinhistory.png"

    function load() {
        var page = checkinHistory;
        page.checkin.connect(function(id) {
            stack.push(Qt.resolvedUrl("Checkin.qml"),{"checkinID":id});
        });
        page.update.connect(function(){
            if (userID === "self")
                Api.users.loadCheckinHistory(page,userID);
            else
                Api.users.loadActivityHistory(page,userID);
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

        footer: Column{
            width: parent.width
            ToolButton {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Load More")
                visible: !completed
                onClicked: {
                    completed = true;
                    update();
                }
            }
            Item {
                width: parent.width
                height: 20
            }
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
            }

            onAreaClicked: {
                checkinHistory.checkin( model.id );
            }
        }
    }
}

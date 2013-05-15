import Qt 4.7
import com.nokia.meego 1.0
import "../components"

import "../js/api.js" as Api

PageWrapper {
    id: leaderBoard
    signal user( string user )
    property string rank: ""

    property alias boardModel: boardModel

    width: parent.width
    height: parent.height

    color: mytheme.colors.backgroundMain

    headerText: "YOU ARE #" + leaderBoard.rank
    headerIcon: "../icons/icon-header-leadersboard.png"

    function load() {
        var page = leaderBoard;
        page.user.connect(function(user) {
            stack.push(Qt.resolvedUrl("User.qml"),{"userID":user});
        });
        Api.users.loadLeaderBoard(page);
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { }
    }

    ListModel {
        id: boardModel
    }

    ListView {
        id: listViewLeader
        model: boardModel
        anchors.top: pagetop
        width: parent.width
        height: parent.height - y
        delegate: leaderBoardDelegate
        //highlightFollowsCurrentItem: true
        clip: true

        spacing: 5
    }

    ScrollDecorator{ flickableItem: listViewLeader }

    Component {
        id: leaderBoardDelegate

        EventBox {
            activeWhole: true
            width: leaderBoard.width

            userName: "#" + model.rank + ". " + model.name
            //userShout:
            createdAt: "<b>"+model.recent+" "+"points" + "</b> " + model.checkinsCount + " " + "checkins"

            Component.onCompleted: {
                userPhoto.photoUrl = model.photo
            }

            onAreaClicked: {
                stack.push(Qt.resolvedUrl("User.qml"),{"userID":model.user});
            }
        }
    }
}

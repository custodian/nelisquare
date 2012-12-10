import Qt 4.7
import "../components"

import "../js/api-user.js" as UserAPI

PageWrapper {
    id: leaderBoard
    signal user( string user )
    property string rank: ""

    property alias boardModel: boardModel

    width: parent.width
    height: parent.height

    color: mytheme.colors.backgroundMain

    function load() {
        var page = leaderBoard;
        page.user.connect(function(user) {
            pageStack.push(Qt.resolvedUrl("User.qml"),{"userID":user});
        });
        UserAPI.loadLeaderBoard(page);
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { }
    }

    ListModel {
        id: boardModel
    }

    ListView {
        y: 40
        model: boardModel
        width: parent.width
        height: parent.height - y
        delegate: leaderBoardDelegate
        //highlightFollowsCurrentItem: true
        clip: true

        spacing: 5
    }

    LineGreen {
        height: 40
        text: "YOU ARE #" + leaderBoard.rank
    }

    Image {
        id: shadow
        source: "../pics/top-shadow.png"
        width: parent.width
        y: 40
    }

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
                pageStack.push(Qt.resolvedUrl("User.qml"),{"userID":model.user});
            }
        }
    }
}

import Qt 4.7
import com.nokia.meego 1.0
import "../components"

import "../js/api.js" as Api

PageWrapper {
    id: usersList
    signal user(string id)

    property string objID: ""
    property string objType: ""
    property int limit: 0
    property alias usersModel: usersModel

    width: parent.width
    height: parent.height

    color: mytheme.colors.backgroundMain

    headerText: "Loading..."
    headerIcon: "../icons/icon-header-userslist.png"

    function load() {
        var page = usersList;
        page.user.connect(function(params){
            stack.push(Qt.resolvedUrl("User.qml"),{"userID":params});
        });
        if (objType === "user") {
            headerText = "USER FRIENDS"
            Api.users.loadUserFriends(page,objID);
        } else {
            headerText = "LIKERS LIST"
            Api.users.loadLikeUsers(page,objID,objType,limit);
        }
    }

    ListModel{
        id: usersModel
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { }
    }

    ListView {
        id: listViewUsers
        model: usersModel
        anchors.top: pagetop
        width: parent.width
        height: parent.height - y
        delegate: usersDelegate
        clip: true
    }

    ScrollDecorator{ flickableItem: listViewUsers }

    Component {
        id: usersDelegate

        EventBox {
            activeWhole: true

            venueName: model.name
            createdAt: model.city

            Component.onCompleted: {
                userPhoto.photoUrl = model.photo
            }

            onAreaClicked: {
                usersList.user( model.id );
            }
        }
    }
}

import Qt 4.7
import com.nokia.meego 1.0
import "../components"

import "../js/api-user.js" as UserAPI

PageWrapper {
    id: usersList
    signal user(string id)

    property string userID: ""
    property alias usersModel: usersModel

    width: parent.width
    height: parent.height

    color: mytheme.colors.backgroundMain

    function load() {
        var page = usersList;
        page.user.connect(function(params){
            pageStack.push(Qt.resolvedUrl("User.qml"),{"userID":params});
        });
        UserAPI.loadUserFriends(page,userID);
    }

    ListModel{
        id: usersModel
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { }
    }

    LineGreen {
        height: 30
        text: "USER FRIENDS"
    }

    ListView {
        id: listViewUsers
        model: usersModel
        y: 30
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

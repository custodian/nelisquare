import Qt 4.7
import "../components"

import "../js/api-user.js" as UserAPI

PageWrapper {
    id: mayorships
    signal venue(string id)

    property string userID: ""
    property alias mayorshipsModel: mayorshipsModel

    width: parent.width
    height: parent.height

    color: mytheme.colors.backgroundMain

    function load() {
        var page = mayorships;
        page.venue.connect(function(id) {
            pageStack.push(Qt.resolvedUrl("Venue.qml"),{"venueID":id});
        });
        UserAPI.loadMayorships(page,userID);
    }

    ListModel{
        id: mayorshipsModel
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { }
    }

    LineGreen {
        height: 30
        text: "MAYORSHIPS"
    }

    ListView {
        model: mayorshipsModel
        y: 30
        width: parent.width
        height: parent.height - y
        delegate: mayorshipsDelegate
        //highlightFollowsCurrentItem: true
        clip: true
    }

    Component {
        id: mayorshipsDelegate

        EventBox {
            activeWhole: true

            venueName: model.name
            createdAt: model.address

            Component.onCompleted: {
                userPhoto.photoUrl = model.icon
            }

            onAreaClicked: {
                mayorships.venue( model.id );
            }
        }
    }
}

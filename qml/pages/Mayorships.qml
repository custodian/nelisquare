import Qt 4.7
import com.nokia.meego 1.0
import "../components"

import "../js/api.js" as Api

PageWrapper {
    id: mayorships
    signal venue(string id)

    property string userID: ""
    property alias mayorshipsModel: mayorshipsModel

    width: parent.width
    height: parent.height

    color: mytheme.colors.backgroundMain

    headerText: "MAYORSHIPS"

    function load() {
        var page = mayorships;
        page.venue.connect(function(id) {
            stack.push(Qt.resolvedUrl("Venue.qml"),{"venueID":id});
        });
        Api.users.loadMayorships(page,userID);
    }

    ListModel{
        id: mayorshipsModel
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { }
    }

    ListView {
        id: listViewMayorships
        model: mayorshipsModel
        anchors.top: pagetop
        width: parent.width
        height: parent.height - y
        delegate: mayorshipsDelegate
        //highlightFollowsCurrentItem: true
        clip: true
    }

    ScrollDecorator{ flickableItem: listViewMayorships }

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

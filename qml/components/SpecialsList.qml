import Qt 4.7
import com.nokia.meego 1.0
import "../components"

Column {
    width: parent.width
    property alias specialsModel: specialsModel

    ListModel {
        id: specialsModel
    }
    SectionHeader {
        text: qsTr("VENUE SPECIALS")
    }
    Repeater {
        id: specialRepeater
        x: 10
        width: parent.width - 20
        model: specialsModel
        delegate: specialDelegate
    }

    Component {
        id: specialDelegate

        EventBox {
            activeWhole: true
            width: specialRepeater.width

            userName: model.specialName
            venueName: model.specialState ? qsTr("Unlocked!") : ""
            userShout: model.specialText
            likesCount: model.likesCount

            Component.onCompleted: {
                var iconUrl = "";
                switch(model.specialIcon) {
                case "frequency":
                    iconUrl = "https://ss1.4sqi.net/img/specials/frequency-35f4e372d6f61449d3c4b8d1ca6b8abd.png";
                    break;
                case "mayor":
                    iconUrl = "https://ss0.4sqi.net/img/specials/mayor-5ec615adb6c9fec6bde8fadfc392055e.png";
                    break;
                case "newbie":
                    iconUrl = "https://ss0.4sqi.net/img/specials/newbie-6a48af8e03d46ad488b795237af2f344.png";
                    break;
                case "flash":
                    iconUrl = "https://ss0.4sqi.net/img/specials/flash-b594489f778e71c1d062b2f7b44e6edc.png";
                    break;
                default:
                case "check-in":
                    iconUrl = "https://ss1.4sqi.net/img/specials/check-in-f870bc36c0cc2a842fac06c35a6dccdf.png";
                    break;
                }
                userPhoto.photoUrl = iconUrl
            }
        }
    }

    visible: specialsModel.count>0
}

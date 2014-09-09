import Qt 4.7
import com.nokia.meego 1.0
import "../components"

import "../js/api.js" as Api

PageWrapper {
    id: exploreOptions

    width: parent.width
    height: parent.height
    color: mytheme.colors.backgroundMain

    property PageWrapper searchAction
    property alias query: queryText.text
    //property alias section: sectionModel.get(sectionSelection.selectedIndex).section
    property bool specialsOnly: false

    signal search()

    headerText: qsTr("EXPLORE OPTIONS")
    headerIcon: "../icons/icon-header-venueslist.png"

    function load() {
        var page = exploreOptions;
        page.search.connect(function() {
            searchAction.search(query, "", specialsOnly)
        });
    }

    tools: ToolBarLayout {
        parent: exploreOptions

        ToolIcon {
            iconId: "toolbar-back"
            onClicked: pageStack.pop()
        }

        ToolIcon {
            iconId: "toolbar-search"
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: exploreOptions.search()
        }
    }

    Column {
        anchors.top: pagetop
        width: parent.width
        spacing: mytheme.paddingXLarge

        TextField {
            id: queryText
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: mytheme.paddingXLarge

            placeholderText: qsTr("Search query...")
            Keys.onReturnPressed: exploreOptions.search()
        }

        Rectangle {
            id: section
            height: 80
            anchors {
                left: parent.left
                right: parent.right
                margins: mytheme.paddingXLarge
            }
            color: mouseArea.pressed ? mytheme.colors.backgroundSand : mytheme.colors.backgroundMain

            Text {
                id: title
                anchors.leftMargin: mytheme.paddingMedium
                anchors.topMargin: mytheme.paddingMedium
                anchors.left: parent.left
                anchors.top: parent.top

                text: qsTr("Section")

                font.bold: true
                font.pixelSize: mytheme.fontSizeLarge
                color: mytheme.colors.textColorOptions
                wrapMode: Text.Wrap
                elide: Text.ElideRight
            }

            Text {
                anchors.top: title.bottom
                anchors.left: title.left

                text: sectionModel.get(sectionSelection.selectedIndex).name

                font.pixelSize: mytheme.fontSizeLarge
                color: mytheme.colors.textColorOptions
                wrapMode: Text.Wrap
                elide: Text.ElideRight
            }

            ToolIcon {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                platformIconId: "common-combobox-arrow"
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                onClicked: sectionSelection.open()
            }
        }

        SettingSwitch {
            anchors {
                left: parent.left
                right: parent.right
                margins: mytheme.paddingXLarge
            }
            text: qsTr("Specials only")
            checked: exploreOptions.specialsOnly
            onCheckedChanged: exploreOptions.specialsOnly = checked
        }
    }

    SelectionDialog {
         id: sectionSelection
         titleText: qsTr("Section")
         selectedIndex: 0

         model: ListModel {
             id: sectionModel

             ListElement { section: ""; name: "All" }
             ListElement { section: "specials"; name: "Specials" }
             ListElement { section: "trending"; name: "Trending" }
             ListElement { section: "nextVenues"; name: "Next venues" }
             ListElement { section: "topPicks"; name: "Top picks" }
             ListElement { section: "food"; name: "Food" }
             ListElement { section: "drinks"; name: "Drinks" }
             ListElement { section: "coffee"; name: "Coffee" }
             ListElement { section: "shops"; name: "Shops" }
             ListElement { section: "arts"; name: "Arts" }
             ListElement { section: "outdoors"; name: "Outdoors" }
             ListElement { section: "sights"; name: "Sights" }
         }
     }
}

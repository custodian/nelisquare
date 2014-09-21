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

    headerText: qsTr("EXPLORE OPTIONS")
    headerIcon: "../icons/icon-header-venueslist.png"

    tools: ToolBarLayout {
        parent: exploreOptions

        ToolIcon {
            iconId: "toolbar-back"
            onClicked: pageStack.pop()
        }

        ToolIcon {
            iconId: "toolbar-search"
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: exploreOptions.searchAction.search()
        }
    }

    Column {
        anchors.top: pagetop
        width: parent.width
        spacing: mytheme.paddingXLarge

        TextField {
            id: queryText
            anchors {
                left: parent.left
                right: parent.right
                margins: mytheme.paddingXLarge
            }
            placeholderText: qsTr("Search query...")
            text: exploreOptions.searchAction.query
            onTextChanged: exploreOptions.searchAction.query = text
            Keys.onReturnPressed: exploreOptions.searchAction.search()
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
                id: sectionText
                anchors.top: title.bottom
                anchors.left: title.left

                text: sectionModel.get(sectionIndexById(exploreOptions.searchAction.section)).name

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
            text: qsTr("Sort by distance")
            checked: exploreOptions.searchAction.sortByDistance
            onCheckedChanged: exploreOptions.searchAction.sortByDistance = checked
        }

        SettingSwitch {
            anchors {
                left: parent.left
                right: parent.right
                margins: mytheme.paddingXLarge
            }
            text: qsTr("Opened now")
            checked: exploreOptions.searchAction.openNow
            onCheckedChanged: exploreOptions.searchAction.openNow = checked
        }

        SettingSwitch {
            anchors {
                left: parent.left
                right: parent.right
                margins: mytheme.paddingXLarge
            }
            text: qsTr("Specials only")
            checked: exploreOptions.searchAction.specialsOnly
            onCheckedChanged: exploreOptions.searchAction.specialsOnly = checked
        }

        SettingSwitch {
            anchors {
                left: parent.left
                right: parent.right
                margins: mytheme.paddingXLarge
            }
            text: qsTr("Saved on my lists")
            checked: exploreOptions.searchAction.savedOnly
            onCheckedChanged: exploreOptions.searchAction.savedOnly = checked
        }

        // TODO multi selection list? (e.g. 2,3)
//        Slider {
//            id: priceSlider
//            anchors {
//                left: parent.left
//                right: parent.right
//                margins: mytheme.paddingXLarge
//            }
//            minimumValue: 0
//            maximumValue: 4
//            stepSize: 1

////            function formatValue(val) {
////                if(val === 0)
////                    return "Any"
////                else
////                    return val
////            }
//            valueIndicatorText: value
//            value: exploreOptions.searchAction.price
//            // onValueChanged: exploreOptions.searchAction.price = value
//        }

        // novelty: new, old or `omit`
        Item {
            height: 120
            anchors {
                left: parent.left
                right: parent.right
                margins: mytheme.paddingXLarge
            }

            Text {
                id: noveltyTitle

                anchors.leftMargin: mytheme.paddingMedium
                anchors.topMargin: mytheme.paddingMedium
                anchors.left: parent.left
                anchors.top: parent.top

                text: qsTr("Novelty")

                font.bold: true
                font.pixelSize: mytheme.fontSizeLarge
                color: mytheme.colors.textColorOptions
                wrapMode: Text.Wrap
                elide: Text.ElideRight
            }

            ButtonRow {
                anchors.leftMargin: mytheme.paddingMedium
                anchors.topMargin: mytheme.paddingMedium
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: noveltyTitle.bottom

                Button { id: nov1; text: "All" }
                Button { id: nov2; text: "New" }
                Button { id: nov3; text: "Old" }

                checkedButton: getButton(exploreOptions.searchAction.novelty)
                onCheckedButtonChanged: {
                    var val = checkedButton.text.toLowerCase()
                    if(exploreOptions.searchAction.novelty !== val)
                        exploreOptions.searchAction.novelty = val
                }

                function getButton(val) {
                    if(val === "new")
                        return nov2
                    if(val === "old")
                        return nov3
                    return nov1
                }
            }
        }
    }

    SelectionDialog {
        id: sectionSelection
        titleText: qsTr("Section")
        selectedIndex: sectionIndexById(exploreOptions.searchAction.section)

        model: ListModel {
            id: sectionModel

            ListElement { section: ""; name: "All" }
            ListElement { section: "food"; name: "Food" }
            ListElement { section: "drinks"; name: "Drinks" }
            ListElement { section: "coffee"; name: "Coffee" }
            ListElement { section: "shops"; name: "Shops" }
            ListElement { section: "arts"; name: "Arts" }
            ListElement { section: "outdoors"; name: "Outdoors" }
            ListElement { section: "sights"; name: "Sights" }
            ListElement { section: "trending"; name: "Trending" }
            ListElement { section: "specials"; name: "Specials" }
            ListElement { section: "nextVenues"; name: "Next venues" }
            ListElement { section: "topPicks"; name: "Top picks" }
        }

        onSelectedIndexChanged: {
            var selectedItem = sectionModel.get(sectionSelection.selectedIndex)
            sectionText.text = selectedItem.name
            exploreOptions.searchAction.section = selectedItem.section
        }
    }

    function sectionIndexById (sectionId) {
        for(var i = 0; i < sectionModel.count; i++) {
            var item = sectionModel.get(i)
            if(item.section === sectionId)
                return i
        }
    }
}

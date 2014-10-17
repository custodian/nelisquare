import Qt 4.7
import com.nokia.meego 1.0
import "../components"

import "../js/api.js" as Api

PageWrapper {
    id: exploreOptions

    width: parent.width
    height: parent.height
    color: mytheme.colors.backgroundMain

    signal search()

    property PageWrapper searchAction

    headerText: qsTr("EXPLORE OPTIONS")
    headerIcon: "../icons/icon-header-venueslist.png"

    function load() {
        var sectionIndex = sectionSelection.sectionIndexById(exploreOptions.searchAction.section)

        queryText.text = exploreOptions.searchAction.query
        sectionText.text = sectionModel.get(sectionIndex).name

        p1.checked = prices.containsPrice(0)
        p2.checked = prices.containsPrice(1)
        p3.checked = prices.containsPrice(2)
        p4.checked = prices.containsPrice(3)

        novelty.checkedButton = novelty.getButton(exploreOptions.searchAction.novelty)
        sectionSelection.selectedIndex = sectionIndex

        exploreOptions.search.connect(function() {
            pageStack.pop()
            searchAction.search()
        })
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
            anchors {
                left: parent.left
                right: parent.right
                margins: mytheme.paddingXLarge
            }
            placeholderText: qsTr("I'm looking for...")

            onTextChanged: exploreOptions.searchAction.query = text
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
                id: sectionText
                anchors.top: title.bottom
                anchors.left: title.left

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

        // price
        Item {
            height: 100
            anchors {
                left: parent.left
                right: parent.right
                margins: mytheme.paddingXLarge
            }

            Text {
                id: priceTitle

                anchors.leftMargin: mytheme.paddingMedium
                anchors.topMargin: mytheme.paddingMedium
                anchors.left: parent.left
                anchors.top: parent.top

                text: qsTr("Price")

                font.bold: true
                font.pixelSize: mytheme.fontSizeLarge
                color: mytheme.colors.textColorOptions
                wrapMode: Text.Wrap
                elide: Text.ElideRight
            }

            ButtonRow {
                id: prices
                anchors.leftMargin: mytheme.paddingMedium
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: priceTitle.bottom

                Button {
                    id: p1; text: "$"; checkable: true
                    onCheckedChanged: prices.updatePrice(0, checked)
                }
                Button {
                    id: p2; text: "$$"; checkable: true
                    onCheckedChanged: prices.updatePrice(1, checked)
                }
                Button {
                    id: p3; text: "$$$"; checkable: true
                    onCheckedChanged: prices.updatePrice(2, checked)
                }
                Button {
                    id: p4; text: "$$$$"; checkable: true
                    onCheckedChanged: prices.updatePrice(3, checked)
                }

                exclusive: false

                function containsPrice(n) {
                    return exploreOptions.searchAction.price & (1 << n)
                }
                function updatePrice(n, checked) {
                    if(checked)
                        exploreOptions.searchAction.price |= 1 << n
                    else
                        exploreOptions.searchAction.price &= ~(1 << n)
                }
            }
        }

        // novelty: new, old or omit
        Item {
            height: 100
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
                id: novelty
                anchors.leftMargin: mytheme.paddingMedium
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: noveltyTitle.bottom

                Button { id: nov1; text: "All"; onClicked: exploreOptions.searchAction.novelty = "" }
                Button { id: nov2; text: "New"; onClicked: exploreOptions.searchAction.novelty = "new" }
                Button { id: nov3; text: "Old"; onClicked: exploreOptions.searchAction.novelty = "old" }

                function getButton(val) {
                    if(val === "new") return nov2
                    if(val === "old") return nov3
                    return nov1
                }
            }
        }
    }

    SelectionDialog {
        id: sectionSelection
        titleText: qsTr("Section")

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

        function sectionIndexById (sectionId) {
            for(var i = 0; i < sectionModel.count; i++) {
                var item = sectionModel.get(i)
                if(item.section === sectionId)
                    return i
            }
        }
    }
}

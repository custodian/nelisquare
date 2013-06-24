import Qt 4.7
import QtMobility.location 1.2
import com.nokia.meego 1.0
import "../components"

import "../js/api.js" as Api

PageWrapper {
    id: venueAdd
    signal create(variant venue)
    signal createCompleted(string venue)

    property string venueID: ""
    property variant categories: undefined
    property string categoryID: ""

    property alias categoriesModel: categoriesModel

    onCategoriesChanged: {
        if (categories!==undefined) {
            waiting_hide();
            categories.forEach(function(category) {
                categoriesModel.append(category)
            });
        }
    }

    width: parent.width
    height: parent.height
    color: mytheme.colors.backgroundMain

    headerText: qsTr("ADD NEW VENUE")
    headerIcon: "../icons/icon-header-venueslist.png"

    function load() {
        var page = venueAdd;
        page.create.connect(function(params){
            Api.venues.createVenue(page,params);
        });
        page.createCompleted.connect(function(venue){
            stack.replace(Qt.resolvedUrl("Venue.qml"),{"venueID":venue});
        });

        waiting_show();
        var catinfo = "catinfo-object";
        var catinfoobj = Api.objs.save(catinfo);

        catinfoobj.cacheCallback = function(status, url) {
            if (!status) return;
            Api.venues.parseCategoryInfo(page,url);
        }
        cache.queueObject(Api.venues.getCategoryInfoURL(), catinfo);
    }

    Plugin {
        id: mapplugin
        property string mapprovider: configuration.mapprovider
        onMapproviderChanged: {
            mapplugin.name = mapprovider
            map.plugin = mapplugin;
        }
        name: configuration.mapprovider
    }

    ListModel {
        id: categoriesModel
    }
    ListModel {
        id: subCategoriesModel
    }

    SelectionDialog {
        id: categoryDialog
        titleText: qsTr("Select category")
        model: categoriesModel
        onAccepted: {
            subCategoriesModel.clear();
            var catid = categoriesModel.get(selectedIndex).id;
            var subcats;
            categories.forEach(function(category) {
                if (category.id === catid)
                    subcats = category.categories;
            });
            subcats.forEach(function(category) {
                subCategoriesModel.append(category)
            });
            subCategoryDialog.selectedIndex = -1;
            subCategoryDialog.open();
        }
    }

    SelectionDialog {
        id: subCategoryDialog
        titleText: qsTr("Select sub-category")
        model: subCategoriesModel
        onAccepted: {
            var category = subCategoriesModel.get(selectedIndex);
            categoryID = category.id;
            categoryBox.userShout = categoriesModel.get(categoryDialog.selectedIndex).name;
            categoryBox.userName = category.name;
            categoryBox.userPhoto.photoUrl = Api.parseIcon(category.icon);
        }
        onRejected: {
            categoryDialog.open();
        }
    }

    Flickable{
        id: flickableArea
        anchors {
            top: pagetop
            bottom: parent.bottom
        }
        width: parent.width
        contentWidth: parent.width

        clip: true
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds
        pressDelay: 100

        Column {
            onHeightChanged: {
                flickableArea.contentHeight = height;
            }

            width: parent.width
            spacing: 10

            SectionHeader {
                text: qsTr("VENUE NAME");
            }

            TextField {
                id: textVenueName
                placeholderText: qsTr("Venue name required")
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: 10
                }
            }

            SectionHeader {
                text: qsTr("VENUE ADDRESS");
            }

            TextField {
                id: textVenueAddress
                placeholderText: qsTr("Street address is optional")
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: 10
                }
            }

            SectionHeader {
                text: qsTr("VENUE CATEGORY")
            }

            EventBox {
                id: categoryBox
                userName: qsTr("Not selected")
                userShout: qsTr("Tap to select category")
                activeWhole: true

                onAreaClicked: {
                    if (categoriesModel.count > 0)
                        categoryDialog.open();
                    else {
                        show_error(qsTr("Venue categories are not loaded yet"));
                    }
                }

                Component.onCompleted: {
                    userPhoto.photoUrl = Api.parseIcon(Api.defaultVenueIcon);
                }
            }

            SectionHeader {
                text: qsTr("VENUE LOCATION");
            }

            Item {
                id: mapArea
                width: parent.width
                height: 200

                Map {
                    id: map
                    anchors.fill: parent
                    center: positionSource.position.coordinate
                    zoomLevel: 15

                    MapImage{
                        id: markerVenue
                        offset.x: -24
                        offset.y: -24
                        coordinate: positionSource.position.coordinate
                        source: "../pics/pin_venue.png"
                    }
                }
            }

            Button {
                width: parent.width * 0.7
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("CREATE VENUE")
                onClicked: {
                    if (textVenueName.text.length < 3) {
                        show_error(qsTr("You should specify venue name"));
                        return;
                    }
                    if (categoryID === "") {
                        show_error(qsTr("You should select category"));
                        return;
                    }
                    if (!positionSource.position.latitudeValid) {
                        show_error(qsTr("Can't get GPS position for venue"));
                        return;
                    }
                    var params = {};
                    params.address = textVenueAddress.text;
                    params.name = textVenueName.text;
                    params.ll = map.center.latitude + "," + map.center.longitude;;
                    params.category = categoryID;
                    venueAdd.create(params);
                }
            }
        }
    }
}

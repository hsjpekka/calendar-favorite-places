import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0

Page {
    id: page
    allowedOrientations: Orientation.All
    Component.onCompleted: {
        showPlaces()
    }

    ConfigurationValue {
        id: favoritePlaces
        key: "/apps/patchmanager/calendar-favorite-place/place"
        defaultValue: ["empty list"]
    }

    RemorsePopup {
        id: remorsePU
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        VerticalScrollDecorator{}

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader {
                title: "Favorite event locations"
            }

            SectionHeader {
                text: qsTr("Description")
            }

            Label {
                text: qsTr("Store calendar event locations, as the autofill component in the location field does not work.")
                color: Theme.highlightColor
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                width: parent.width - 2*x
                x: Theme.horizontalPageMargin
            }

            Label {
                color: Theme.highlightColor
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                width: parent.width - 2*x
                x: Theme.horizontalPageMargin
                text: qsTr("Press and hold event location for the list of the favorite places.")
            }

            Label {
                text: qsTr("Modifies EditEventPage.qml.")
                color: Theme.highlightColor
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                width: parent.width - 2*x
                x: Theme.horizontalPageMargin
            }

            SectionHeader {
                text: qsTr("Event locations")
            }

            Label {
                color: Theme.highlightColor
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                width: parent.width - 2*x
                x: Theme.horizontalPageMargin
                text: qsTr("The first item in the list (in italics) will be overwritten each time an event is saved.")
            }

            Row {
                id: rowPlaceField
                spacing: Theme.paddingMedium
                width: parent.width

                TextField {
                    id: placeField
                    placeholderText: qsTr("address")
                    text: ""
                    label: qsTr("address to store")
                    width: parent.width - placeFieldClear.width - 2*rowPlaceField.spacing
                    EnterKey.enabled: text.length > 0
                    EnterKey.iconSource: "image://theme/icon-m-enter-next"
                    EnterKey.onClicked: {
                        if (text != "") {
                            addPlace(text);
                        }
                        focus = false;
                    }
                }

                IconButton {
                    id: placeFieldClear
                    icon.source: "image://theme/icon-m-clear"
                    width: Theme.iconSizeMedium
                    height: width
                    onClicked: {
                        favoritePlacesView.currentIndex = -1
                        placeField.text = ""
                    }
                }
            }

            SilicaListView {
                id: favoritePlacesView
                width: parent.width
                height: page.height - y > minHeight? page.height - y : minHeight
                clip: true
                highlight: Rectangle {
                    color: Theme.highlightBackgroundColor
                    height: favoritePlacesView.currentIndex >= 0 ?
                                favoritePlacesView.currentItem.height : Theme.fontSizeMedium
                    radius: Theme.paddingMedium
                    border.color: Theme.highlightColor
                    border.width: 2
                    opacity: Theme.highlightBackgroundOpacity
                }

                highlightFollowsCurrentItem: true

                model: ListModel {
                    id: favoritePlacesList

                    function add(address) {
                        favoritePlacesList.append({"place" : address});
                        return favoritePlacesList.count;
                    }
                }

                delegate: ListItem {
                    id: placeItem
                    propagateComposedEvents: true
                    _backgroundColor: "transparent" //does not flash - listviews highlight is enough
                    ListView.onRemove: animateRemoval(placeItem)
                    onClicked: {
                        placeField.text = place
                        favoritePlacesView.currentIndex = favoritePlacesView.indexAt(mouseX, y + mouseY)
                    }
                    onPressAndHold: {
                        favoritePlacesView.currentIndex = favoritePlacesView.indexAt(mouseX, y + mouseY)
                    }

                    menu: ContextMenu {
                        MenuItem {
                            text: qsTr("delete")
                            onClicked: {
                                var i=favoritePlacesView.currentIndex
                                remorseAction(qsTr("deleting"), function() {
                                    favoritePlacesList.remove(i)
                                    savePlaces()
                                })
                            }
                        }
                        MenuItem {
                            text: qsTr("modify")
                            onClicked: {
                                var i = favoritePlacesView.currentIndex, address = placeField.text
                                remorseAction(qsTr("modifying" + " " + i + " " + address), function() {
                                    modifyPlace(i, address)
                                    return
                                })
                            }
                        }
                    }

                    Label {
                        color: Theme.secondaryColor
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        width: parent.width - 2*x
                        x: Theme.horizontalPageMargin
                        text: place
                        font.italic: index === 0 ? true : false
                    }
                }

                property int minHeight: 8*Theme.fontSizeMedium

                VerticalScrollDecorator {}
            }
        }
    }

    function addPlace(address) {
        favoritePlacesList.add(address);
        savePlaces();
        return;
    }

    function modifyPlace(ind, address) {
        var i = 0, list = [];

        while ( i < favoritePlacesList.count ) {
            if (i === ind) {
                favoritePlacesList.set(ind, {"place": address});
                list[i] = address;
            } else {
                list[i] = favoritePlacesList.get(i).place;
            }

            i++
        }
        favoritePlaces.value = list;
        favoritePlaces.sync();

        return list.length;
    }

    function showPlaces() {
        var i = 0;
        if ( Array.isArray(favoritePlaces.value) ) {
            favoritePlacesList.clear();
            while ( i < favoritePlaces.value.length ) {
                favoritePlacesList.add(favoritePlaces.value[i]);
                i++;
            }
        }
        favoritePlacesView.currentIndex = -1;

        return;
    }

    function savePlaces() {
        var i = 0, list = [];

        while (i < favoritePlacesList.count) {
            list.push(favoritePlacesList.get(i).place);
            i++;
        }
        favoritePlaces.value = list;
        favoritePlaces.sync();

        return favoritePlaces.value.length;
    }
}

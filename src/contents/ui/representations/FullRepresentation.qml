import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.draganddrop as DragDrop
import org.kde.kirigami as Kirigami
import "../components"
import "../lib/Translations.js" as Tr
import "../lib/UiStyle.js" as UiStyle
import "../lib/ItemsManager.js" as ItemsManager
import "../lib/AppResolver.js" as AppResolver

DragDrop.DropArea {
    id: fullRoot

    property var rawItems: []
    property var systemAppsList: []
    property string groupTitle: "Applications"
    property bool showHeader: true
    property bool enableFilter: true
    property string viewMode: "grid"
    property string columnsMode: "auto"
    property int gridColumns: 4
    property string iconSize: "medium"
    property string backgroundStyle: "card"
    property real backgroundOpacity: 0.85
    property int borderRadius: 16
    property bool showLabels: true
    property int fontSizeDelta: 0
    property string sortBy: "manual"
    property bool singleClickLaunch: true
    property string lang: "en"
    property bool isPinned: false
    property bool inPanel: Plasmoid.formFactor !== PlasmaCore.Types.Planar

    property int dragSourceIndex: -1
    property int dragTargetIndex: -1

    signal itemLaunchRequested(var item)
    signal itemAdded(var item)
    signal itemUpdated(var item, int index)
    signal itemRemoved(var item, int index)
    signal itemMoved(int fromIndex, int toIndex)
    signal pinToggled()
    signal settingsRequested()

    function reorderItems(fromIdx, toIdx) {
        if (fromIdx < 0 || toIdx < 0 || fromIdx === toIdx) return;
        var src = visibleItems[fromIdx];
        var dst = visibleItems[toIdx];
        if (!src || !dst) return;
        var rawFrom = -1;
        var rawTo = -1;
        for (var i = 0; i < rawItems.length; i++) {
            if (rawItems[i].id === src.id) rawFrom = i;
            if (rawItems[i].id === dst.id) rawTo = i;
        }
        if (rawFrom >= 0 && rawTo >= 0 && rawFrom !== rawTo) {
            fullRoot.itemMoved(rawFrom, rawTo);
        }
    }

    Layout.minimumWidth: Kirigami.Units.gridUnit * 10
    Layout.minimumHeight: Kirigami.Units.gridUnit * 8
    implicitWidth: inPanel ? Kirigami.Units.gridUnit * 21 : Kirigami.Units.gridUnit * 20
    implicitHeight: inPanel ? Kirigami.Units.gridUnit * 24 : Kirigami.Units.gridUnit * 18

    preventStealing: true

    property string searchQuery: ""
    property string activeTypeFilter: "all"

    readonly property var visibleItems: ItemsManager.filterAndSortItems(rawItems, searchQuery, activeTypeFilter, sortBy)
    readonly property int iconPixels: UiStyle.getIconPixelSize(iconSize)

    Rectangle {
        id: bgContainer
        anchors.fill: parent
        radius: fullRoot.borderRadius
        color: {
            if (fullRoot.backgroundStyle === "flat") return "transparent";
            if (fullRoot.backgroundStyle === "glass") return Kirigami.Theme.backgroundColor;
            if (fullRoot.backgroundStyle === "outline") return "transparent";
            return Kirigami.Theme.backgroundColor;
        }
        opacity: {
            if (fullRoot.backgroundStyle === "flat") return 1.0;
            if (fullRoot.backgroundStyle === "glass") return Math.min(0.65, fullRoot.backgroundOpacity);
            if (fullRoot.backgroundStyle === "outline") return 1.0;
            return fullRoot.backgroundOpacity;
        }
        border.color: {
            if (fullRoot.backgroundStyle === "outline") return Kirigami.Theme.highlightColor;
            if (fullRoot.backgroundStyle === "flat") return "transparent";
            return Kirigami.Theme.hoverColor;
        }
        border.width: fullRoot.backgroundStyle === "flat" ? 0 : 1

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            radius: fullRoot.borderRadius
            color: "white"
            opacity: fullRoot.backgroundStyle === "flat" ? 0 : 0.08
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            onClicked: mouse => bgContextMenu.popup(this, mouse.x, mouse.y)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing + 2
        spacing: 4

        GroupHeader {
            id: header
            visible: fullRoot.showHeader
            Layout.fillWidth: true
            title: fullRoot.groupTitle
            itemsCount: fullRoot.rawItems.length
            lang: fullRoot.lang
            isPinned: fullRoot.isPinned
            showPinButton: fullRoot.inPanel
            enableFilter: fullRoot.enableFilter
            onSearchChanged: query => fullRoot.searchQuery = query
            onPinToggled: fullRoot.pinToggled()
            onAddClicked: addItemModal.open()
            onSettingsClicked: fullRoot.settingsRequested()
        }

        Flickable {
            id: pillsFlickable
            visible: fullRoot.rawItems.length > 5 && !header.searchActive
            Layout.fillWidth: true
            implicitHeight: Kirigami.Units.gridUnit * 1.5
            contentWidth: pillsRow.implicitWidth
            contentHeight: pillsRow.implicitHeight
            flickableDirection: Flickable.HorizontalFlick
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Row {
                id: pillsRow
                spacing: 4

                Repeater {
                    model: [
                        { key: "all",   label: Tr.t(fullRoot.lang, "allTypes") },
                        { key: "apps",  label: Tr.t(fullRoot.lang, "typeApps") },
                        { key: "dirs",  label: Tr.t(fullRoot.lang, "typeDirs") },
                        { key: "files", label: Tr.t(fullRoot.lang, "typeFiles") }
                    ]

                    Rectangle {
                        implicitWidth: pillText.implicitWidth + 12
                        implicitHeight: Kirigami.Units.gridUnit * 1.3
                        radius: height / 2
                        color: fullRoot.activeTypeFilter === modelData.key
                            ? Kirigami.Theme.highlightColor
                            : (pillMouse.containsMouse ? Kirigami.Theme.hoverColor : "transparent")
                        opacity: fullRoot.activeTypeFilter === modelData.key ? 0.9 : 0.6
                        border.color: fullRoot.activeTypeFilter === modelData.key ? "transparent" : Kirigami.Theme.hoverColor
                        border.width: 1

                        QQC2.Label {
                            id: pillText
                            anchors.centerIn: parent
                            text: modelData.label
                            font.pointSize: Kirigami.Theme.smallFont.pointSize - 1
                            font.bold: fullRoot.activeTypeFilter === modelData.key
                            color: fullRoot.activeTypeFilter === modelData.key
                                ? Kirigami.Theme.highlightedTextColor
                                : Kirigami.Theme.textColor
                        }

                        MouseArea {
                            id: pillMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: fullRoot.activeTypeFilter = modelData.key
                        }
                    }
                }
            }
        }

        Rectangle {
            visible: fullRoot.showHeader
            Layout.fillWidth: true
            height: 1
            color: Kirigami.Theme.hoverColor
            opacity: 0.5
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            EmptyPlaceholder {
                anchors.centerIn: parent
                visible: fullRoot.visibleItems.length === 0
                lang: fullRoot.lang
                isSearchEmpty: fullRoot.searchQuery.length > 0 && fullRoot.rawItems.length > 0
                onAddClicked: addItemModal.open()
            }

            GridView {
                id: gridView
                visible: fullRoot.viewMode === "grid" && fullRoot.visibleItems.length > 0
                anchors.fill: parent
                clip: true

                readonly property int effectiveCols: {
                    if (fullRoot.columnsMode === "fixed" && fullRoot.gridColumns > 0) {
                        var maxFit = Math.max(1, Math.floor(width / Math.max(32, fullRoot.iconPixels)));
                        return Math.min(Math.max(1, fullRoot.gridColumns), maxFit);
                    }
                    var colWidth = fullRoot.iconPixels + Kirigami.Units.gridUnit * 2.5;
                    return Math.max(1, Math.floor(width / Math.max(1, colWidth)));
                }

                cellWidth: Math.floor(width / Math.max(1, effectiveCols))
                cellHeight: fullRoot.iconPixels + (fullRoot.showLabels ? Kirigami.Units.gridUnit * 2.2 : Kirigami.Units.smallSpacing * 2)

                model: fullRoot.visibleItems

                delegate: ItemCard {
                    width: gridView.cellWidth
                    height: gridView.cellHeight
                    itemData: modelData
                    itemIndex: index
                    totalCount: fullRoot.visibleItems.length
                    lang: fullRoot.lang
                    viewMode: "grid"
                    iconPixelSize: fullRoot.iconPixels
                    showLabels: fullRoot.showLabels
                    fontSizeDelta: fullRoot.fontSizeDelta
                    singleClickLaunch: fullRoot.singleClickLaunch

                    onLaunched: item => fullRoot.itemLaunchRequested(item)
                    onContextMenuRequested: (item, idx, mx, my) => {
                        contextMenu.itemData = item;
                        contextMenu.itemIndex = idx;
                        contextMenu.totalCount = fullRoot.visibleItems.length;
                        contextMenu.popup(this, mx, my);
                    }
                    onDeleteRequested: (item, idx) => fullRoot.itemRemoved(item, idx)
                    onReorderRequested: (fromIdx, toIdx) => fullRoot.reorderItems(fromIdx, toIdx)
                }
            }

            ListView {
                id: listView
                visible: fullRoot.viewMode === "list" && fullRoot.visibleItems.length > 0
                anchors.fill: parent
                clip: true
                spacing: 4

                model: fullRoot.visibleItems

                delegate: ItemCard {
                    width: listView.width
                    itemData: modelData
                    itemIndex: index
                    totalCount: fullRoot.visibleItems.length
                    lang: fullRoot.lang
                    viewMode: "list"
                    iconPixelSize: fullRoot.iconPixels
                    showLabels: fullRoot.showLabels
                    fontSizeDelta: fullRoot.fontSizeDelta
                    singleClickLaunch: fullRoot.singleClickLaunch

                    onLaunched: item => fullRoot.itemLaunchRequested(item)
                    onContextMenuRequested: (item, idx, mx, my) => {
                        contextMenu.itemData = item;
                        contextMenu.itemIndex = idx;
                        contextMenu.totalCount = fullRoot.visibleItems.length;
                        contextMenu.popup(this, mx, my);
                    }
                    onDeleteRequested: (item, idx) => fullRoot.itemRemoved(item, idx)
                    onReorderRequested: (fromIdx, toIdx) => fullRoot.reorderItems(fromIdx, toIdx)
                }
            }

            DropHighlight {
                id: dropOverlay
                visible: fullRoot.containsDrag
                lang: fullRoot.lang
            }
        }
    }

    onDrop: event => {
        if (event.mimeData && event.mimeData.urls && event.mimeData.urls.length > 0) {
            for (var i = 0; i < event.mimeData.urls.length; i++) {
                var resolved = AppResolver.resolveFromUrl(event.mimeData.urls[i], fullRoot.systemAppsList);
                if (resolved) {
                    fullRoot.itemAdded(resolved);
                }
            }
        } else if (event.mimeData && event.mimeData.text) {
            var lines = event.mimeData.text.split("\n");
            for (var j = 0; j < lines.length; j++) {
                var line = lines[j].trim();
                if (line.length > 0) {
                    var item = AppResolver.resolveFromUrl(line, fullRoot.systemAppsList);
                    if (item) {
                        fullRoot.itemAdded(item);
                    }
                }
            }
        }
    }

    ItemContextMenu {
        id: contextMenu
        lang: fullRoot.lang
        inPanel: fullRoot.inPanel
        isPinned: fullRoot.isPinned
        onPinToggled: fullRoot.pinToggled()
        onLaunchRequested: item => fullRoot.itemLaunchRequested(item)
        onOpenFolderRequested: item => {
            if (!item || !item.url) return;
            var u = item.url;
            if (u.indexOf("file://") === 0) {
                var p = u.substring(7);
                var lastSlash = p.lastIndexOf("/");
                if (lastSlash > 0) {
                    fullRoot.itemLaunchRequested({ url: "file://" + p.substring(0, lastSlash), type: "directory" });
                }
            } else if (u.indexOf("applications:") === 0) {
                fullRoot.itemLaunchRequested({ url: "file:///usr/share/applications", type: "directory" });
            }
        }
        onEditRequested: (item, idx) => {
            editItemModal.itemData = item;
            editItemModal.itemIndex = idx;
            editItemModal.open();
        }
        onRemoveRequested: (item, idx) => fullRoot.itemRemoved(item, idx)
        onMoveRequested: (fromIdx, toIdx) => fullRoot.reorderItems(fromIdx, toIdx)
    }

    PlasmaComponents3.Menu {
        id: bgContextMenu

        PlasmaComponents3.MenuItem {
            text: fullRoot.isPinned ? Tr.t(fullRoot.lang, "unpinPopup") : Tr.t(fullRoot.lang, "pinPopup")
            icon.name: "window-pin"
            visible: fullRoot.inPanel
            onTriggered: fullRoot.pinToggled()
        }

        PlasmaComponents3.MenuItem {
            text: Tr.t(fullRoot.lang, "addItem")
            icon.name: "list-add"
            onTriggered: addItemModal.open()
        }

        PlasmaComponents3.MenuSeparator {}

        PlasmaComponents3.MenuItem {
            text: Tr.t(fullRoot.lang, "openSettings")
            icon.name: "configure"
            onTriggered: fullRoot.settingsRequested()
        }
    }

    AddItemModal {
        id: addItemModal
        lang: fullRoot.lang
        systemApps: fullRoot.systemAppsList
        onItemAdded: item => fullRoot.itemAdded(item)
    }

    ItemEditModal {
        id: editItemModal
        lang: fullRoot.lang
        onItemSaved: (item, idx) => fullRoot.itemUpdated(item, idx)
        onItemDeleted: (item, idx) => fullRoot.itemRemoved(item, idx)
    }
}

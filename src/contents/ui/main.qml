import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.private.desktopcontainment.folder as Folder
import org.kde.plasma.private.kicker as Kicker
import org.kde.plasma.plasma5support as Plasma5Support
import "representations"
import "lib/Translations.js" as Tr
import "lib/ItemsManager.js" as ItemsManager
import "lib/AppResolver.js" as AppResolver

PlasmoidItem {
    id: root

    readonly property bool configuring: Plasmoid.userConfiguring === true

    // Same object every time there is nothing to preview, so bindings stay quiet.
    readonly property var _emptyPreview: ({})

    readonly property var previewValues: {
        if (!root.configuring) {
            return root._emptyPreview;
        }
        var raw = Plasmoid.configuration.livePreview;
        if (!raw) {
            return root._emptyPreview;
        }
        try {
            var parsed = JSON.parse(String(raw));
            if (parsed && parsed.values && typeof parsed.values === "object") {
                return parsed.values;
            }
        } catch (e) {
        }
        return root._emptyPreview;
    }

    // Preview wins when the key is present, including false and 0.
    // Reads previewValues and configuration[key] so callers re-evaluate.
    function cfg(key) {
        var values = root.previewValues;
        var saved = Plasmoid.configuration[key];
        if (values !== undefined && values !== null && values[key] !== undefined) {
            return values[key];
        }
        return saved;
    }

    readonly property string lang: {
        var cfgLang = root.cfg("language");
        if (cfgLang === "fa" || cfgLang === "en") {
            return cfgLang;
        }
        return Qt.locale().name.indexOf("fa") === 0 ? "fa" : "en";
    }

    LayoutMirroring.enabled: root.lang === "fa"
    LayoutMirroring.childrenInherit: true

    property bool isPinned: false

    hideOnWindowDeactivate: !root.isPinned && !root.configuring

    onConfiguringChanged: {
        if (root.configuring) {
            if (Plasmoid.formFactor !== PlasmaCore.Types.Planar) {
                root.expanded = true;
            }
        } else {
            if (Plasmoid.configuration.livePreview) {
                Plasmoid.configuration.livePreview = "";
            }
            if (!root.isPinned) {
                root.expanded = false;
            }
        }
    }

    Component.onCompleted: {
        if (!root.configuring && Plasmoid.configuration.livePreview) {
            Plasmoid.configuration.livePreview = "";
        }
    }

    property var itemsList: ItemsManager.parseItems(Plasmoid.configuration.items)

    readonly property var displayedItems: {
        var preview = root.previewValues;
        var saved = root.itemsList;
        if (preview && preview.items !== undefined) {
            return ItemsManager.parseItems(preview.items);
        }
        return saved;
    }

    readonly property Kicker.AppsModel appsModel: Kicker.AppsModel {
        id: internalAppsModel
        autoPopulate: true
        appletInterface: root
        Component.onCompleted: refresh()
    }

    property var cachedSystemApps: []

    function refreshSystemApps() {
        var seen = {};
        var list = [];
        for (var i = 0; i < internalAppsModel.count; i++) {
            var cat = internalAppsModel.labelForRow(i);
            var sub = internalAppsModel.modelForRow(i);
            if (!sub) continue;
            for (var j = 0; j < sub.count; j++) {
                var idx = sub.index(j, 0);
                var desktopFile = sub.data(idx, 259);
                var name = sub.labelForRow(j);
                var icon = sub.data(idx, Qt.DecorationRole) || "application-x-executable";
                var desc = sub.data(idx, 257) || "";
                if (desktopFile && !seen[desktopFile]) {
                    seen[desktopFile] = true;
                    list.push({
                        name: name,
                        icon: String(icon),
                        desktopFile: String(desktopFile),
                        desc: String(desc),
                        category: String(cat)
                    });
                }
            }
        }
        list.sort(function(a, b) {
            return String(a.name).localeCompare(String(b.name));
        });
        root.cachedSystemApps = list;
        return list;
    }

    Connections {
        target: internalAppsModel
        function onCountChanged() {
            root.refreshSystemApps();
        }
    }

    Timer {
        id: appsRefreshTimer
        interval: 800
        running: true
        onTriggered: root.refreshSystemApps()
    }

    Connections {
        target: Plasmoid.configuration
        function onItemsChanged() {
            root.itemsList = ItemsManager.parseItems(Plasmoid.configuration.items);
        }
    }

    function saveItems(newList) {
        root.itemsList = newList;
        Plasmoid.configuration.items = ItemsManager.stringifyItems(newList);
    }

    function addItem(newItem) {
        var updated = ItemsManager.addItem(root.itemsList, newItem);
        saveItems(updated);
    }

    function updateItem(updatedItem, index) {
        var updated = ItemsManager.updateItem(root.itemsList, updatedItem);
        saveItems(updated);
    }

    function removeItem(item, index) {
        var idToRemove = item ? item.id : (root.itemsList[index] ? root.itemsList[index].id : "");
        var updated = ItemsManager.removeItem(root.itemsList, idToRemove);
        saveItems(updated);
    }

    function moveItem(fromIdx, toIdx) {
        var updated = ItemsManager.moveItem(root.itemsList, fromIdx, toIdx);
        saveItems(updated);
    }

    Plasma5Support.DataSource {
        id: execEngine
        engine: "executable"
        connectedSources: []
        onNewData: function(sourceName, data) {
            disconnectSource(sourceName);
        }
    }

    function executeDesktop(target) {
        var clean = String(target || "").trim();
        if (clean.indexOf("file://") === 0) {
            clean = decodeURIComponent(clean.substring(7));
        } else if (clean.indexOf("applications:") === 0) {
            clean = clean.substring(13);
        }

        var slash = clean.lastIndexOf("/");
        var desktopId = slash !== -1 ? clean.substring(slash + 1) : clean;
        var safeId = desktopId.replace(/'/g, "'\\''");

        var cmd = "";
        if (clean.indexOf("/") === 0) {
            var safePath = clean.replace(/'/g, "'\\''");
            cmd = "kioclient exec '" + safePath + "' 2>/dev/null || gio launch '" + safePath + "' 2>/dev/null || gtk-launch '" + safeId + "' 2>/dev/null";
        } else {
            cmd = "gtk-launch '" + safeId + "' 2>/dev/null || kioclient exec '/usr/share/applications/" + safeId + "' 2>/dev/null || gio launch '/usr/share/applications/" + safeId + "' 2>/dev/null";
        }

        execEngine.connectSource(cmd);
    }

    function launchUrl(item) {
        if (!item || !item.url) return;
        var urlStr = String(item.url).trim();

        if (item.id) {
            var updated = ItemsManager.incrementLaunch(root.itemsList, item.id);
            saveItems(updated);
        }

        if (urlStr.indexOf("http://") === 0 || urlStr.indexOf("https://") === 0) {
            try {
                Qt.openUrlExternally(urlStr);
            } catch (e) {}
            return;
        }

        var isApp = (item.type === "application")
            || (urlStr.indexOf("applications:") === 0)
            || (/\.desktop($|\?|#)/i.test(urlStr));

        if (isApp) {
            executeDesktop(urlStr);
            return;
        }

        if (item.type === "directory" || urlStr.charAt(urlStr.length - 1) === "/") {
            try {
                if (typeof Folder !== "undefined" && Folder.AppLauncher && typeof Folder.AppLauncher.openUrl === "function") {
                    Folder.AppLauncher.openUrl(urlStr);
                    return;
                }
            } catch (eDir) {}
            try {
                Qt.openUrlExternally(urlStr);
            } catch (eDir2) {}
            return;
        }

        try {
            if (typeof Folder !== "undefined" && Folder.AppLauncher && typeof Folder.AppLauncher.openUrl === "function") {
                Folder.AppLauncher.openUrl(urlStr);
                return;
            }
        } catch (eFile) {}

        try {
            Qt.openUrlExternally(urlStr);
        } catch (eFile2) {}
    }

    Plasmoid.title: root.cfg("groupTitle") || Tr.t(root.lang, "appName")
    toolTipMainText: root.cfg("groupTitle") || Tr.t(root.lang, "appName")
    toolTipSubText: Tr.t(root.lang, "itemsCount", root.displayedItems.length)

    preferredRepresentation: Plasmoid.formFactor === PlasmaCore.Types.Planar
        ? fullRepresentation
        : compactRepresentation

    switchWidth: Kirigami.Units.gridUnit * 15
    switchHeight: Kirigami.Units.gridUnit * 15

    compactRepresentation: CompactRepresentation {
        itemsCount: root.displayedItems.length
        panelIcon: root.cfg("panelIcon")
        showBadge: root.cfg("showBadge")
        lang: root.lang

        onToggleRequested: root.expanded = !root.expanded
        onDropReceived: event => {
            if (event.mimeData && event.mimeData.urls && event.mimeData.urls.length > 0) {
                for (var i = 0; i < event.mimeData.urls.length; i++) {
                    var resolved = AppResolver.resolveFromUrl(event.mimeData.urls[i], root.cachedSystemApps);
                    if (resolved) {
                        root.addItem(resolved);
                    }
                }
            }
        }
    }

    fullRepresentation: FullRepresentation {
        rawItems: root.displayedItems
        systemAppsList: root.cachedSystemApps
        groupTitle: root.cfg("groupTitle")
        showHeader: root.cfg("showHeader")
        enableFilter: root.cfg("enableFilter")
        viewMode: root.cfg("viewMode")
        columnsMode: root.cfg("columnsMode")
        gridColumns: root.cfg("gridColumns")
        iconSize: root.cfg("iconSize")
        backgroundStyle: root.cfg("backgroundStyle")
        backgroundOpacity: root.cfg("backgroundOpacity")
        borderRadius: root.cfg("borderRadius")
        showLabels: root.cfg("showLabels")
        fontSizeDelta: root.cfg("fontSizeDelta")
        sortBy: root.cfg("sortBy")
        singleClickLaunch: root.cfg("singleClickLaunch")
        lang: root.lang
        isPinned: root.isPinned

        onItemLaunchRequested: item => root.launchUrl(item)
        onItemAdded: item => root.addItem(item)
        onItemUpdated: (item, idx) => root.updateItem(item, idx)
        onItemRemoved: (item, idx) => root.removeItem(item, idx)
        onItemMoved: (fromIdx, toIdx) => root.moveItem(fromIdx, toIdx)
        onPinToggled: root.isPinned = !root.isPinned
        onSettingsRequested: {
            if (Plasmoid.internalAction("configure")) {
                Plasmoid.internalAction("configure").trigger();
            } else if (Plasmoid.action("configure")) {
                Plasmoid.action("configure").trigger();
            }
        }
    }

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: root.isPinned ? Tr.t(root.lang, "unpinPopup") : Tr.t(root.lang, "pinPopup")
            icon.name: "window-pin"
            visible: Plasmoid.formFactor !== PlasmaCore.Types.Planar
            checkable: true
            checked: root.isPinned
            onTriggered: root.isPinned = !root.isPinned
        },
        PlasmaCore.Action {
            text: Tr.t(root.lang, "addItem")
            icon.name: "list-add"
            onTriggered: {
                if (!root.expanded && Plasmoid.formFactor !== PlasmaCore.Types.Planar) {
                    root.expanded = true;
                }
            }
        }
    ]
}

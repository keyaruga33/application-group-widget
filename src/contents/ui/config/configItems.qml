import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.plasma.private.kicker as Kicker
import "../lib/Translations.js" as Tr
import "../lib/ItemsManager.js" as ItemsManager
import "../components"

KCM.SimpleKCM {
    id: page

    property string cfg_items: "[]"
    property string cfg_itemsDefault: "[]"
    property string cfg_language: "auto"
    // Declared so the dialog can set them. LivePreview keeps cfg_livePreview empty.
    property string cfg_livePreview: ""
    property string cfg_livePreviewDefault: ""

    readonly property string lang: {
        if (cfg_language === "fa" || cfg_language === "en")
            return cfg_language;
        return Qt.locale().name.indexOf("fa") === 0 ? "fa" : "en";
    }

    function tr(key, args) { return Tr.t(lang, key, args); }

    LayoutMirroring.enabled: page.lang === "fa"
    LayoutMirroring.childrenInherit: true

    LivePreview {
        page: page
        tag: "items"
    }

    property var parsedList: ItemsManager.parseItems(page.cfg_items)

    function syncItems(list) {
        page.parsedList = list;
        page.cfg_items = ItemsManager.stringifyItems(list);
    }

    Kicker.AppsModel {
        id: kcmAppsModel
        autoPopulate: true
        appletInterface: typeof plasmoid !== "undefined" ? plasmoid : null
        Component.onCompleted: refresh()
    }

    property var kcmSystemApps: []

    function refreshKcmApps() {
        var seen = {};
        var list = [];
        for (var i = 0; i < kcmAppsModel.count; i++) {
            var cat = kcmAppsModel.labelForRow(i);
            var sub = kcmAppsModel.modelForRow(i);
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
        page.kcmSystemApps = list;
        return list;
    }

    Connections {
        target: kcmAppsModel
        function onCountChanged() {
            page.refreshKcmApps();
        }
    }

    Timer {
        interval: 500
        running: true
        onTriggered: page.refreshKcmApps()
    }

    header: RowLayout {
        spacing: Kirigami.Units.smallSpacing

        QQC2.Label {
            text: page.tr("cfgItemsHint")
            color: Kirigami.Theme.disabledTextColor
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        QQC2.Button {
            text: page.tr("cfgAddItemBtn")
            icon.name: "list-add"
            onClicked: {
                if (page.kcmSystemApps.length === 0) {
                    page.refreshKcmApps();
                }
                addItemModal.open();
            }
        }

        QQC2.Button {
            text: page.tr("cfgClearAll")
            icon.name: "edit-clear-all"
            enabled: page.parsedList.length > 0
            onClicked: page.syncItems([])
        }
    }

    ListView {
        id: itemsView
        anchors.fill: parent
        clip: true
        spacing: 4
        model: page.parsedList

        delegate: Rectangle {
            id: rowDelegate
            width: itemsView.width
            implicitHeight: Kirigami.Units.gridUnit * 2.8
            radius: 8
            color: Kirigami.Theme.backgroundColor
            border.color: Kirigami.Theme.hoverColor
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Kirigami.Units.smallSpacing
                anchors.rightMargin: Kirigami.Units.smallSpacing
                spacing: Kirigami.Units.mediumSpacing

                Kirigami.Icon {
                    implicitWidth: Kirigami.Units.iconSizes.medium
                    implicitHeight: Kirigami.Units.iconSizes.medium
                    source: modelData.icon || "application-x-executable"
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    QQC2.Label {
                        text: modelData.title || ""
                        font.bold: true
                        color: Kirigami.Theme.textColor
                    }

                    QQC2.Label {
                        text: modelData.url || ""
                        font.pointSize: Kirigami.Theme.smallFont.pointSize - 1
                        color: Kirigami.Theme.disabledTextColor
                        elide: Text.ElideMiddle
                        Layout.fillWidth: true
                    }
                }

                QQC2.ToolButton {
                    icon.name: "go-up"
                    enabled: index > 0
                    onClicked: {
                        var updated = ItemsManager.moveItem(page.parsedList, index, index - 1);
                        page.syncItems(updated);
                    }
                }

                QQC2.ToolButton {
                    icon.name: "go-down"
                    enabled: index < page.parsedList.length - 1
                    onClicked: {
                        var updated = ItemsManager.moveItem(page.parsedList, index, index + 1);
                        page.syncItems(updated);
                    }
                }

                QQC2.ToolButton {
                    icon.name: "document-edit"
                    onClicked: {
                        editItemModal.itemData = modelData;
                        editItemModal.itemIndex = index;
                        editItemModal.open();
                    }
                }

                QQC2.ToolButton {
                    icon.name: "edit-delete"
                    onClicked: {
                        var updated = ItemsManager.removeItem(page.parsedList, modelData.id);
                        page.syncItems(updated);
                    }
                }
            }
        }
    }

    AddItemModal {
        id: addItemModal
        lang: page.lang
        systemApps: page.kcmSystemApps
        onItemAdded: item => {
            var updated = ItemsManager.addItem(page.parsedList, item);
            page.syncItems(updated);
        }
    }

    ItemEditModal {
        id: editItemModal
        lang: page.lang
        onItemSaved: (item, idx) => {
            var updated = ItemsManager.updateItem(page.parsedList, item);
            page.syncItems(updated);
        }
        onItemDeleted: (item, idx) => {
            var updated = ItemsManager.removeItem(page.parsedList, item.id);
            page.syncItems(updated);
        }
    }
}

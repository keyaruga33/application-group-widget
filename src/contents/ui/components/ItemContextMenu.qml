import QtQuick
import QtQuick.Controls as QQC2
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami
import "../lib/Translations.js" as Tr

PlasmaComponents3.Menu {
    id: root

    property var itemData: null
    property int itemIndex: -1
    property int totalCount: 0
    property string lang: "en"
    property bool inPanel: false
    property bool isPinned: false

    signal launchRequested(var item)
    signal openFolderRequested(var item)
    signal editRequested(var item, int index)
    signal removeRequested(var item, int index)
    signal moveRequested(int fromIndex, int toIndex)
    signal pinToggled()

    PlasmaComponents3.MenuItem {
        text: Tr.t(root.lang, "launch")
        icon.name: "media-playback-start"
        onTriggered: root.launchRequested(root.itemData)
    }

    PlasmaComponents3.MenuItem {
        text: Tr.t(root.lang, "openFolder")
        icon.name: "folder-open"
        visible: root.itemData && (root.itemData.type === "directory" || root.itemData.type === "file" || (root.itemData.url && root.itemData.url.indexOf("file://") === 0))
        onTriggered: root.openFolderRequested(root.itemData)
    }

    PlasmaComponents3.MenuSeparator {}

    PlasmaComponents3.MenuItem {
        text: Tr.t(root.lang, "editItem")
        icon.name: "document-edit"
        onTriggered: root.editRequested(root.itemData, root.itemIndex)
    }

    PlasmaComponents3.MenuItem {
        text: Tr.t(root.lang, "moveLeft")
        icon.name: "go-previous"
        enabled: root.itemIndex > 0
        onTriggered: root.moveRequested(root.itemIndex, root.itemIndex - 1)
    }

    PlasmaComponents3.MenuItem {
        text: Tr.t(root.lang, "moveRight")
        icon.name: "go-next"
        enabled: root.itemIndex < root.totalCount - 1
        onTriggered: root.moveRequested(root.itemIndex, root.itemIndex + 1)
    }

    PlasmaComponents3.MenuItem {
        text: root.isPinned ? Tr.t(root.lang, "unpinPopup") : Tr.t(root.lang, "pinPopup")
        icon.name: "window-pin"
        visible: root.inPanel
        onTriggered: root.pinToggled()
    }

    PlasmaComponents3.MenuSeparator {}

    PlasmaComponents3.MenuItem {
        text: Tr.t(root.lang, "removeItem")
        icon.name: "list-remove"
        onTriggered: root.removeRequested(root.itemData, root.itemIndex)
    }
}

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

    // Plasma 6.3 always paints a theme dialog frame on applet popups, and there
    // is no NoBackground hint. When that frame can be hidden, the widget's own
    // background is extended to the window edge so the square frame no longer
    // shows behind the rounded corners. Colors, opacity, and borders stay as they
    // were; only the frame and its blur region change.
    property var popupWindow: Window.window
    property bool _themeFrameHidden: false
    property bool _applyingFrame: false
    readonly property bool customFrame: fullRoot.inPanel && fullRoot._themeFrameHidden

    // Rectangle per-corner radii exist on Qt 6.7+. A declarative binding would
    // stop this file from loading on Plasma 6.0 (Qt 6.6).
    property bool _cornerProbed: false
    property bool perCornerSupported: false

    function probeCornerSupport() {
        if (fullRoot._cornerProbed || !bgContainer)
            return;
        var supported = false;
        try {
            supported = bgContainer.topLeftRadius !== undefined;
        } catch (e) {
            supported = false;
        }
        fullRoot._cornerProbed = true;
        if (fullRoot.perCornerSupported !== supported)
            fullRoot.perCornerSupported = supported;
    }

    function isPopupSeparator(item) {
        if (!item || item === fullRoot)
            return false;
        try {
            if (item.imagePath === "widgets/line")
                return true;
            if (item.elementId === "horizontal-line" || item.elementId === "vertical-line")
                return true;
            if (item.z === 999)
                return true;
        } catch (e) {
            return false;
        }
        return false;
    }

    function hideSeparatorsIn(host) {
        if (!host)
            return;
        try {
            var kids = host.children;
            if (!kids)
                return;
            for (var i = 0; i < kids.length; i++) {
                var child = kids[i];
                if (!fullRoot.isPopupSeparator(child))
                    continue;
                try {
                    child.opacity = 0;
                    child.visible = false;
                } catch (e1) {
                }
            }
        } catch (e) {
        }
    }

    function finishCustomPopupFrame() {
        fullRoot.applyCornerRadii();
        fullRoot.applyRoundedMask();
        fullRoot._applyingFrame = false;
    }

    function applyCustomPopupFrame() {
        // Swapping the mask changes padding, which calls back in here.
        if (fullRoot._applyingFrame)
            return;
        fullRoot._applyingFrame = true;
        if (!fullRoot.inPanel) {
            fullRoot._themeFrameHidden = false;
            fullRoot.finishCustomPopupFrame();
            return;
        }
        var win = fullRoot.popupWindow;
        if (!win) {
            fullRoot._themeFrameHidden = false;
            fullRoot.finishCustomPopupFrame();
            return;
        }
        try {
            if (win.mainItem === undefined || win.leftPadding === undefined) {
                fullRoot._themeFrameHidden = false;
                fullRoot.finishCustomPopupFrame();
                return;
            }
            var content = win.contentItem;
            var main = win.mainItem;
            if (!content || !main) {
                fullRoot._themeFrameHidden = false;
                fullRoot.finishCustomPopupFrame();
                return;
            }
            var hidden = false;
            var kids = content.children;
            for (var i = 0; i < kids.length; i++) {
                var child = kids[i];
                if (!child || child === main)
                    continue;
                try {
                    child.opacity = 0;
                    child.visible = false;
                    hidden = true;
                } catch (e1) {
                }
            }
            fullRoot.hideSeparatorsIn(main);
            if (fullRoot.parent && fullRoot.parent !== main)
                fullRoot.hideSeparatorsIn(fullRoot.parent);
            fullRoot._themeFrameHidden = hidden;
        } catch (err) {
            fullRoot._themeFrameHidden = false;
        }
        fullRoot.finishCustomPopupFrame();
    }

    // KWin's blur/contrast region follows the alpha mask of the popup's (now
    // hidden) theme FrameSvgItem. Point that item at a rounded mask of the
    // same radius so the backdrop matches the widget background.
    property var _maskFrame: null
    property string _origMaskImagePath: ""
    readonly property int maskRadius: Math.max(0, Math.min(32, Math.round(fullRoot.borderRadius / 2) * 2))

    // AppletPopup restores the window as the saved size plus the theme frame's
    // fixed margins, then on hide saves the window minus whatever margins are
    // current. The rounded mask's hint margins are its own, so leaving the
    // window alone makes the saved size drift by that difference on every
    // plasmashell restart. Remember the theme padding and window size before
    // the first swap, then apply the difference once.
    property bool _themePadKnown: false
    property real _themePadH: 0
    property real _themePadV: 0
    property int _baseWindowW: 0
    property int _baseWindowH: 0
    property bool _sizeCompensated: false
    property real _appliedDw: 0
    property real _appliedDh: 0

    function findThemeFrameSvg(win) {
        try {
            var content = win.contentItem;
            var main = win.mainItem;
            var kids = content.children;
            for (var i = 0; i < kids.length; i++) {
                var bg = kids[i];
                if (!bg || bg === main)
                    continue;
                var inner = bg.children;
                for (var j = 0; j < inner.length; j++) {
                    var f = inner[j];
                    if (f && f.imagePath !== undefined && f.enabledBorders !== undefined)
                        return f;
                }
            }
        } catch (e) {
        }
        return null;
    }

    function roundedMaskPath(r) {
        var url = String(Qt.resolvedUrl("../../frames/rounded-" + r + ".svg"));
        return decodeURIComponent(url.replace(/^file:\/\//, ""));
    }

    function framePadding(f) {
        var m = f ? f.fixedMargins : null;
        if (!m)
            return null;
        return {
            h: m.horizontal,
            v: m.vertical
        };
    }

    // Call before imagePath changes, while the frame still has the theme's margins.
    function rememberPopupSize(f) {
        if (fullRoot._themePadKnown || fullRoot._sizeCompensated)
            return false;
        if (String(f.imagePath).indexOf("/frames/rounded-") >= 0)
            return false;
        var pad = fullRoot.framePadding(f);
        var win = fullRoot.popupWindow;
        // The window is sized from this padding. Wait until that size exists
        // so a later swap cannot lose the theme's margins.
        if (!pad || !win || win.width <= 0 || win.height <= 0)
            return false;
        fullRoot._themePadH = pad.h;
        fullRoot._themePadV = pad.v;
        fullRoot._baseWindowW = win.width;
        fullRoot._baseWindowH = win.height;
        fullRoot._themePadKnown = true;
        return true;
    }

    function compensatePopupSize() {
        if (fullRoot._sizeCompensated || !fullRoot._themePadKnown)
            return;
        var f = fullRoot._maskFrame;
        var win = fullRoot.popupWindow;
        if (!f || !win || String(f.imagePath).indexOf("/frames/rounded-") < 0)
            return;
        var pad = fullRoot.framePadding(f);
        if (!pad)
            return;
        var dw = pad.h - fullRoot._themePadH;
        var dh = pad.v - fullRoot._themePadV;
        // Sub-pixel noise is not a real theme/mask difference.
        if (Math.abs(dw) < 0.5)
            dw = 0;
        if (Math.abs(dh) < 0.5)
            dh = 0;
        fullRoot._appliedDw = dw;
        fullRoot._appliedDh = dh;
        fullRoot._sizeCompensated = true;
        if (dw === 0 && dh === 0)
            return;
        // Absolute, not incremental: with no saved size Plasma has already
        // grown the window by this same difference, and with a saved size it
        // has not. Both land on the pre-swap window plus the padding delta.
        // Stay inside the min/max that paddingChanged just applied.
        var targetW = Math.round(fullRoot._baseWindowW + dw);
        var targetH = Math.round(fullRoot._baseWindowH + dh);
        targetW = Math.max(targetW, win.minimumWidth);
        targetH = Math.max(targetH, win.minimumHeight);
        if (win.maximumWidth > 0)
            targetW = Math.min(targetW, win.maximumWidth);
        if (win.maximumHeight > 0)
            targetH = Math.min(targetH, win.maximumHeight);
        win.width = targetW;
        win.height = targetH;
    }

    function restoreThemeFrame() {
        var f = fullRoot._maskFrame;
        if (!f || fullRoot._origMaskImagePath === "")
            return;
        var win = fullRoot.popupWindow;
        var beforeW = win ? win.width : 0;
        var beforeH = win ? win.height : 0;
        var changed = false;
        try {
            if (String(f.imagePath) !== fullRoot._origMaskImagePath) {
                f.imagePath = fullRoot._origMaskImagePath;
                changed = true;
            }
        } catch (e0) {
            return;
        }
        if (!changed || !fullRoot._sizeCompensated || !win)
            return;
        var dw = fullRoot._appliedDw;
        var dh = fullRoot._appliedDh;
        fullRoot._sizeCompensated = false;
        fullRoot._themePadKnown = false;
        if (dw === 0 && dh === 0)
            return;
        // A saved size keeps the window still across the padding change.
        // No saved size and Plasma has already resized it back.
        if (win.width === beforeW && win.height === beforeH) {
            win.width = Math.round(beforeW - dw);
            win.height = Math.round(beforeH - dh);
        }
    }

    function applyRoundedMask() {
        fullRoot.probeCornerSupport();
        var win = fullRoot.popupWindow;
        if (!fullRoot.customFrame || !win) {
            fullRoot.restoreThemeFrame();
            return;
        }
        var f = fullRoot.findThemeFrameSvg(win);
        if (!f)
            return;
        if (fullRoot._maskFrame !== f) {
            fullRoot._maskFrame = f;
            fullRoot._origMaskImagePath = String(f.imagePath).indexOf("/frames/rounded-") >= 0 ? "dialogs/background" : String(f.imagePath);
        }
        // Don't swap until the theme padding and the current window size are
        // recorded. A later show or padding change calls this again.
        if (!fullRoot._themePadKnown && String(f.imagePath).indexOf("/frames/rounded-") < 0 && !fullRoot.rememberPopupSize(f))
            return;
        var path = fullRoot.roundedMaskPath(fullRoot.maskRadius);
        try {
            if (String(f.imagePath) !== path)
                f.imagePath = path;
            // Keep every side of the mask except the panel side, so corners
            // that sit against the screen edge stay rounded too. On Qt < 6.7
            // the background itself cannot square individual corners, so the
            // mask stays fully rounded to match.
            var want = fullRoot.wantedFrameBorders();
            if (Number(f.enabledBorders) !== want)
                f.enabledBorders = want;
        } catch (e1) {
        }
        // imagePath updates fixed margins before it returns, and the popup's
        // own padding handler runs before this line. Compensate here so a
        // re-entered applyCustomPopupFrame cannot swallow the correction.
        fullRoot.compensatePopupSize();
    }

    // KSvg.FrameSvg.EnabledBorders: Top=1, Bottom=2, Left=4, Right=8.
    function wantedFrameBorders() {
        if (!fullRoot.perCornerSupported)
            return 15;
        switch (Plasmoid.location) {
        case PlasmaCore.Types.TopEdge: return 2 | 4 | 8;
        case PlasmaCore.Types.BottomEdge: return 1 | 4 | 8;
        case PlasmaCore.Types.LeftEdge: return 1 | 2 | 8;
        case PlasmaCore.Types.RightEdge: return 1 | 2 | 4;
        default: return 15;
        }
    }

    onMaskRadiusChanged: applyRoundedMask()
    onCustomFrameChanged: applyRoundedMask()

    // Square off the corners that touch the panel, matching the blur mask.
    // Qt.Edges: Top=1, Left=2, Right=4, Bottom=8. These are not the same bits
    // as FrameSvg.EnabledBorders.
    readonly property int popupEdges: {
        if (!fullRoot.customFrame || !fullRoot.perCornerSupported)
            return 15;
        switch (Plasmoid.location) {
        case PlasmaCore.Types.TopEdge: return 2 | 4 | 8;
        case PlasmaCore.Types.BottomEdge: return 1 | 2 | 4;
        case PlasmaCore.Types.LeftEdge: return 1 | 4 | 8;
        case PlasmaCore.Types.RightEdge: return 1 | 2 | 8;
        default: return 15;
        }
    }

    function cornerRadius(e1, e2) {
        return ((fullRoot.popupEdges & e1) && (fullRoot.popupEdges & e2)) ? fullRoot.borderRadius : 0;
    }

    function applyCornerRadii() {
        fullRoot.probeCornerSupport();
        if (!fullRoot.perCornerSupported || !bgContainer)
            return;
        bgContainer.topLeftRadius = fullRoot.cornerRadius(1, 2);
        bgContainer.topRightRadius = fullRoot.cornerRadius(1, 4);
        bgContainer.bottomLeftRadius = fullRoot.cornerRadius(8, 2);
        bgContainer.bottomRightRadius = fullRoot.cornerRadius(8, 4);
    }

    onPopupEdgesChanged: {
        applyCornerRadii();
        applyRoundedMask();
    }
    onBorderRadiusChanged: applyCornerRadii()

    onPopupWindowChanged: {
        applyCustomPopupFrame();
        Qt.callLater(applyCustomPopupFrame);
    }
    onVisibleChanged: {
        applyCustomPopupFrame();
        if (visible)
            Qt.callLater(applyCustomPopupFrame);
    }
    Component.onCompleted: {
        applyCornerRadii();
        applyCustomPopupFrame();
        Qt.callLater(applyCustomPopupFrame);
    }

    Connections {
        target: fullRoot.popupWindow
        ignoreUnknownSignals: true
        function onPaddingChanged() {
            fullRoot.applyCustomPopupFrame();
        }
        function onBordersChanged() {
            // PopupPlasmaWindow resets the frame borders when it repositions.
            fullRoot.applyRoundedMask();
            Qt.callLater(fullRoot.applyRoundedMask);
        }
        function onVisibleChanged() {
            fullRoot.applyCustomPopupFrame();
            if (fullRoot.popupWindow && fullRoot.popupWindow.visible)
                Qt.callLater(fullRoot.applyCustomPopupFrame);
        }
    }

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
        anchors.leftMargin: fullRoot.customFrame && fullRoot.popupWindow ? -fullRoot.popupWindow.leftPadding : 0
        anchors.rightMargin: fullRoot.customFrame && fullRoot.popupWindow ? -fullRoot.popupWindow.rightPadding : 0
        anchors.topMargin: fullRoot.customFrame && fullRoot.popupWindow ? -fullRoot.popupWindow.topPadding : 0
        anchors.bottomMargin: fullRoot.customFrame && fullRoot.popupWindow ? -fullRoot.popupWindow.bottomPadding : 0
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
            anchors.leftMargin: fullRoot.customFrame ? fullRoot.cornerRadius(1, 2) : 0
            anchors.rightMargin: fullRoot.customFrame ? fullRoot.cornerRadius(1, 4) : 0
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

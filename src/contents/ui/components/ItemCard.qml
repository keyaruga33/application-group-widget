import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import "../lib/Translations.js" as Tr

Item {
    id: root

    property var itemData: null
    property int itemIndex: -1
    property int totalCount: 0
    property string lang: "en"
    property string viewMode: "grid"
    property int iconPixelSize: 48
    property bool showLabels: true
    property int fontSizeDelta: 0
    property bool singleClickLaunch: true

    signal launched(var item)
    signal contextMenuRequested(var item, int index, real x, real y)
    signal deleteRequested(var item, int index)
    signal reorderRequested(int fromIndex, int toIndex)

    readonly property bool isDragSource: typeof fullRoot !== "undefined" && fullRoot.dragSourceIndex === root.itemIndex
    readonly property bool isDragTarget: typeof fullRoot !== "undefined" && fullRoot.dragTargetIndex === root.itemIndex && fullRoot.dragSourceIndex >= 0 && fullRoot.dragSourceIndex !== root.itemIndex

    z: isDragSource ? 100 : 1

    implicitWidth: viewMode === "grid"
        ? Math.max(iconPixelSize + Kirigami.Units.gridUnit * 2, Kirigami.Units.gridUnit * 5.5)
        : parent ? parent.width : Kirigami.Units.gridUnit * 15
    implicitHeight: viewMode === "grid"
        ? (iconPixelSize + (showLabels ? Kirigami.Units.gridUnit * 2.2 : Kirigami.Units.smallSpacing * 2))
        : Math.max(iconPixelSize + Kirigami.Units.smallSpacing * 2, Kirigami.Units.gridUnit * 2.8)

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: Kirigami.Units.smallSpacing + 4
        color: root.isDragTarget
            ? Kirigami.Theme.highlightColor
            : (mouseArea.containsMouse ? (mouseArea.pressed ? Kirigami.Theme.highlightColor : Kirigami.Theme.hoverColor) : "transparent")
        opacity: root.isDragTarget ? 0.35 : (mouseArea.containsMouse ? (mouseArea.pressed ? 0.35 : 0.7) : 0)
        border.color: (root.isDragTarget || mouseArea.containsMouse) ? Kirigami.Theme.highlightColor : "transparent"
        border.width: root.isDragTarget ? 2 : 1

        Behavior on opacity {
            NumberAnimation { duration: Kirigami.Units.shortDuration }
        }
    }

    Item {
        id: contentContainer
        width: root.width
        height: root.height
        x: 0
        y: 0
        opacity: root.isDragSource ? 0.75 : 1.0

        ColumnLayout {
            id: gridLayout
            visible: root.viewMode === "grid"
            anchors.fill: parent
            anchors.margins: 4
            spacing: 2

            Item {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: root.iconPixelSize
                Layout.preferredHeight: root.iconPixelSize

                Kirigami.Icon {
                    id: gridIcon
                    anchors.fill: parent
                    source: (root.itemData && root.itemData.icon) ? root.itemData.icon : "application-x-executable"
                    active: mouseArea.containsMouse

                    scale: mouseArea.containsMouse ? 1.05 : 1.0
                    Behavior on scale {
                        NumberAnimation { duration: Kirigami.Units.shortDuration; easing.type: Easing.OutQuad }
                    }
                }
            }

            QQC2.Label {
                visible: root.showLabels
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                text: (root.itemData && root.itemData.title) ? root.itemData.title : ""
                font.pointSize: Math.max(7, Kirigami.Theme.smallFont.pointSize + root.fontSizeDelta)
                color: Kirigami.Theme.textColor
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                maximumLineCount: 2
                wrapMode: Text.WrapAnywhere
            }
        }

        RowLayout {
            id: listLayout
            visible: root.viewMode === "list"
            anchors.fill: parent
            anchors.leftMargin: Kirigami.Units.smallSpacing
            anchors.rightMargin: Kirigami.Units.smallSpacing
            spacing: Kirigami.Units.mediumSpacing

            Kirigami.Icon {
                Layout.preferredWidth: Math.min(root.iconPixelSize, Kirigami.Units.iconSizes.medium)
                Layout.preferredHeight: Math.min(root.iconPixelSize, Kirigami.Units.iconSizes.medium)
                Layout.alignment: Qt.AlignVCenter
                source: (root.itemData && root.itemData.icon) ? root.itemData.icon : "application-x-executable"
                active: mouseArea.containsMouse
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 2

                QQC2.Label {
                    Layout.fillWidth: true
                    text: (root.itemData && root.itemData.title) ? root.itemData.title : ""
                    font.pointSize: Math.max(8, Kirigami.Theme.defaultFont.pointSize + root.fontSizeDelta)
                    font.bold: true
                    color: Kirigami.Theme.textColor
                    elide: Text.ElideRight
                }

                QQC2.Label {
                    Layout.fillWidth: true
                    text: (root.itemData && root.itemData.url) ? root.itemData.url : ""
                    font.pointSize: Kirigami.Theme.smallFont.pointSize - 1
                    color: Kirigami.Theme.disabledTextColor
                    elide: Text.ElideMiddle
                }
            }

            Rectangle {
                id: listMenuBtn
                visible: mouseArea.containsMouse
                Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
                Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
                radius: width / 2
                color: menuMouse.containsMouse ? Kirigami.Theme.highlightColor : Kirigami.Theme.hoverColor

                Kirigami.Icon {
                    anchors.centerIn: parent
                    width: Kirigami.Units.iconSizes.small
                    height: Kirigami.Units.iconSizes.small
                    source: "view-more-symbolic"
                    color: menuMouse.containsMouse ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                }

                MouseArea {
                    id: menuMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var pt = mapToItem(root, mouseX, mouseY);
                        root.contextMenuRequested(root.itemData, root.itemIndex, pt.x, pt.y);
                    }
                }
            }
        }

        Rectangle {
            id: quickMenuBadge
            visible: root.viewMode === "grid" && mouseArea.containsMouse
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 2
            width: Kirigami.Units.iconSizes.small
            height: Kirigami.Units.iconSizes.small
            radius: width / 2
            color: badgeMouse.containsMouse ? Kirigami.Theme.highlightColor : Kirigami.Theme.hoverColor
            border.color: Kirigami.Theme.backgroundColor
            border.width: 1

            Kirigami.Icon {
                anchors.centerIn: parent
                width: Kirigami.Units.iconSizes.small * 0.7
                height: Kirigami.Units.iconSizes.small * 0.7
                source: "view-more-symbolic"
                color: badgeMouse.containsMouse ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
            }

            MouseArea {
                id: badgeMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    var pt = mapToItem(root, mouseX, mouseY);
                    root.contextMenuRequested(root.itemData, root.itemIndex, pt.x, pt.y);
                }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: dragged ? Qt.ClosedHandCursor : Qt.PointingHandCursor

        property real startX: 0
        property real startY: 0
        property bool dragged: false

        preventStealing: dragged

        onPressed: mouse => {
            if (mouse.button === Qt.LeftButton) {
                startX = mouse.x;
                startY = mouse.y;
                dragged = false;
            }
        }

        onPositionChanged: mouse => {
            if (mouse.buttons & Qt.LeftButton) {
                var dx = mouse.x - startX;
                var dy = mouse.y - startY;
                if (!dragged && (Math.abs(dx) > 6 || Math.abs(dy) > 6)) {
                    dragged = true;
                    if (typeof fullRoot !== "undefined") {
                        fullRoot.dragSourceIndex = root.itemIndex;
                    }
                }
                if (dragged) {
                    contentContainer.x = dx;
                    contentContainer.y = dy;

                    var view = root.GridView.view || root.ListView.view;
                    if (view && typeof fullRoot !== "undefined") {
                        var pt = mapToItem(view, mouse.x, mouse.y);
                        var targetIdx = view.indexAt(pt.x, pt.y);
                        fullRoot.dragTargetIndex = targetIdx;
                    }
                }
            }
        }

        onReleased: mouse => {
            if (dragged) {
                if (typeof fullRoot !== "undefined"
                        && fullRoot.dragSourceIndex >= 0
                        && fullRoot.dragTargetIndex >= 0
                        && fullRoot.dragSourceIndex !== fullRoot.dragTargetIndex) {
                    root.reorderRequested(fullRoot.dragSourceIndex, fullRoot.dragTargetIndex);
                }
                dragged = false;
                if (typeof fullRoot !== "undefined") {
                    fullRoot.dragSourceIndex = -1;
                    fullRoot.dragTargetIndex = -1;
                }
                contentContainer.x = 0;
                contentContainer.y = 0;
            }
        }

        onCanceled: {
            if (dragged) {
                dragged = false;
                if (typeof fullRoot !== "undefined") {
                    fullRoot.dragSourceIndex = -1;
                    fullRoot.dragTargetIndex = -1;
                }
                contentContainer.x = 0;
                contentContainer.y = 0;
            }
        }

        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                root.contextMenuRequested(root.itemData, root.itemIndex, mouse.x, mouse.y);
            } else if (mouse.button === Qt.LeftButton) {
                if (!dragged && root.singleClickLaunch) {
                    root.launched(root.itemData);
                }
            }
        }

        onDoubleClicked: mouse => {
            if (mouse.button === Qt.LeftButton && !dragged && !root.singleClickLaunch) {
                root.launched(root.itemData);
            }
        }
    }

    QQC2.ToolTip {
        visible: mouseArea.containsMouse && !badgeMouse.containsMouse && !mouseArea.dragged
        delay: Kirigami.Units.toolTipDelay * 2
        text: {
            if (!root.itemData) return "";
            var str = root.itemData.title || "";
            if (root.itemData.url) str += "\n" + root.itemData.url;
            if (root.itemData.launchCount) {
                str += "\n" + Tr.t(root.lang, "launchCount", root.itemData.launchCount);
            }
            return str;
        }
    }
}

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.draganddrop as DragDrop
import org.kde.kirigami as Kirigami
import "../lib/Translations.js" as Tr

DragDrop.DropArea {
    id: compactRoot

    property int itemsCount: 0
    property string panelIcon: "folder-apps"
    property bool showBadge: true
    property string lang: "en"

    signal toggleRequested()
    signal dropReceived(var event)

    Layout.minimumWidth: Plasmoid.formFactor === PlasmaCore.Types.Horizontal ? height : Kirigami.Units.iconSizes.small
    Layout.minimumHeight: Plasmoid.formFactor === PlasmaCore.Types.Vertical ? width : Kirigami.Units.iconSizes.small
    Layout.preferredWidth: Plasmoid.formFactor === PlasmaCore.Types.Horizontal ? height : Kirigami.Units.iconSizes.medium
    Layout.preferredHeight: Plasmoid.formFactor === PlasmaCore.Types.Vertical ? width : Kirigami.Units.iconSizes.medium

    preventStealing: true

    onContainsDragChanged: contained => {
        if (containsDrag) {
            hoverExpandTimer.restart();
        } else {
            hoverExpandTimer.stop();
        }
    }

    onDrop: event => {
        compactRoot.dropReceived(event);
    }

    Timer {
        id: hoverExpandTimer
        interval: 350
        onTriggered: {
            compactRoot.toggleRequested();
        }
    }

    Rectangle {
        id: hoverBg
        anchors.fill: parent
        anchors.margins: 2
        radius: width / 2
        color: mouseArea.containsMouse || compactRoot.containsDrag
            ? Kirigami.Theme.hoverColor
            : "transparent"
        opacity: compactRoot.containsDrag ? 0.8 : 0.5
        border.color: compactRoot.containsDrag ? Kirigami.Theme.highlightColor : "transparent"
        border.width: compactRoot.containsDrag ? 2 : 0

        Behavior on color { ColorAnimation { duration: Kirigami.Units.shortDuration } }
    }

    Kirigami.Icon {
        id: iconItem
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing
        source: {
            if (compactRoot.panelIcon && compactRoot.panelIcon !== "com.keyaruga.applicationgroup" && compactRoot.panelIcon !== "folder-apps") {
                return compactRoot.panelIcon;
            }
            return Qt.resolvedUrl("../../icons/logo.png");
        }
        active: mouseArea.containsMouse || compactRoot.containsDrag
    }

    Rectangle {
        id: badge
        visible: compactRoot.showBadge && compactRoot.itemsCount > 0
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 1
        width: Math.max(badgeText.implicitWidth + 6, height)
        height: Kirigami.Units.iconSizes.small * 0.75
        radius: height / 2
        color: Kirigami.Theme.highlightColor

        QQC2.Label {
            id: badgeText
            anchors.centerIn: parent
            text: compactRoot.itemsCount > 99 ? "99+" : compactRoot.itemsCount
            font.pointSize: Math.max(6, Kirigami.Theme.smallFont.pointSize - 3)
            font.bold: true
            color: Kirigami.Theme.highlightedTextColor
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: compactRoot.toggleRequested()
    }
}

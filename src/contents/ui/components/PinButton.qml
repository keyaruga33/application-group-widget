import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import "../lib/Translations.js" as Tr

Item {
    id: root

    property bool pinned: false
    property string lang: "en"

    signal clicked()

    implicitWidth: Kirigami.Units.iconSizes.medium
    implicitHeight: Kirigami.Units.iconSizes.medium

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: Kirigami.Units.smallSpacing + 2
        color: root.pinned
            ? Kirigami.Theme.highlightColor
            : (mouseArea.containsMouse ? Kirigami.Theme.hoverColor : "transparent")
        opacity: root.pinned ? 0.9 : 0.6
        Behavior on color { ColorAnimation { duration: Kirigami.Units.shortDuration } }
    }

    Kirigami.Icon {
        id: iconItem
        anchors.centerIn: parent
        width: Kirigami.Units.iconSizes.small
        height: Kirigami.Units.iconSizes.small
        source: "window-pin"
        color: root.pinned ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor

        transform: Rotation {
            origin.x: iconItem.width / 2
            origin.y: iconItem.height / 2
            angle: root.pinned ? 45 : 0
            Behavior on angle { NumberAnimation { duration: Kirigami.Units.shortDuration; easing.type: Easing.OutQuad } }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    QQC2.ToolTip {
        visible: mouseArea.containsMouse
        text: root.pinned ? Tr.t(root.lang, "unpinPopup") : Tr.t(root.lang, "pinPopup")
        delay: Kirigami.Units.toolTipDelay
    }
}

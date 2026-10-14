import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import "../lib/Translations.js" as Tr

Rectangle {
    id: root

    property string lang: "en"

    anchors.fill: parent
    radius: 12
    color: Kirigami.Theme.highlightColor
    opacity: 0.22
    border.color: Kirigami.Theme.highlightColor
    border.width: 2

    Behavior on opacity {
        NumberAnimation { duration: Kirigami.Units.shortDuration }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: Kirigami.Units.smallSpacing

        Kirigami.Icon {
            Layout.alignment: Qt.AlignHCenter
            width: Kirigami.Units.iconSizes.large
            height: Kirigami.Units.iconSizes.large
            source: "list-add"
            color: Kirigami.Theme.highlightColor

            SequentialAnimation on scale {
                loops: Animation.Infinite
                running: root.visible
                PropertyAnimation { to: 1.15; duration: 600; easing.type: Easing.InOutQuad }
                PropertyAnimation { to: 1.0; duration: 600; easing.type: Easing.InOutQuad }
            }
        }

        QQC2.Label {
            Layout.alignment: Qt.AlignHCenter
            text: Tr.t(root.lang, "dropToAdd")
            font.bold: true
            font.pointSize: Kirigami.Theme.defaultFont.pointSize + 1
            color: Kirigami.Theme.textColor
        }

        QQC2.Label {
            Layout.alignment: Qt.AlignHCenter
            text: Tr.t(root.lang, "dropHint")
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            color: Kirigami.Theme.disabledTextColor
        }
    }
}

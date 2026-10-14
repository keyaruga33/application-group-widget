import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import "../lib/Translations.js" as Tr

Item {
    id: root

    property string lang: "en"
    property bool isSearchEmpty: false

    signal addClicked()

    implicitWidth: Kirigami.Units.gridUnit * 18
    implicitHeight: Kirigami.Units.gridUnit * 12

    ColumnLayout {
        anchors.centerIn: parent
        spacing: Kirigami.Units.largeSpacing
        Layout.alignment: Qt.AlignCenter

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: Kirigami.Units.iconSizes.huge
            implicitHeight: Kirigami.Units.iconSizes.huge
            radius: width / 2
            color: Kirigami.Theme.hoverColor
            opacity: 0.8

            Kirigami.Icon {
                anchors.centerIn: parent
                width: Kirigami.Units.iconSizes.large
                height: Kirigami.Units.iconSizes.large
                source: root.isSearchEmpty ? "edit-find" : "folder-open"
                color: Kirigami.Theme.highlightColor
            }
        }

        ColumnLayout {
            spacing: Kirigami.Units.smallSpacing
            Layout.alignment: Qt.AlignHCenter

            Kirigami.Heading {
                level: 4
                Layout.alignment: Qt.AlignHCenter
                text: root.isSearchEmpty ? Tr.t(root.lang, "noSearchResults") : Tr.t(root.lang, "emptyTitle")
                color: Kirigami.Theme.textColor
                font.bold: true
            }

            QQC2.Label {
                Layout.alignment: Qt.AlignHCenter
                text: root.isSearchEmpty ? "" : Tr.t(root.lang, "emptySubtitle")
                color: Kirigami.Theme.disabledTextColor
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                Layout.maximumWidth: Kirigami.Units.gridUnit * 16
            }
        }

        QQC2.Button {
            visible: !root.isSearchEmpty
            Layout.alignment: Qt.AlignHCenter
            text: Tr.t(root.lang, "addFirstItem")
            icon.name: "list-add"
            onClicked: root.addClicked()
        }
    }
}

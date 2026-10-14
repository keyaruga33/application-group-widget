import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.iconthemes as KIconThemes
import "../lib/Translations.js" as Tr
import "../lib/UiStyle.js" as UiStyle

QQC2.Popup {
    id: root

    property string lang: "en"
    property var itemData: null
    property int itemIndex: -1

    signal itemSaved(var item, int index)
    signal itemDeleted(var item, int index)

    modal: true
    focus: true
    dim: true
    closePolicy: QQC2.Popup.CloseOnEscape | QQC2.Popup.CloseOnPressOutside

    implicitWidth: Math.min(parent ? parent.width * 0.95 : 440, Kirigami.Units.gridUnit * 25)
    implicitHeight: Math.min(parent ? parent.height * 0.90 : 450, Kirigami.Units.gridUnit * 24)
    anchors.centerIn: parent

    background: Rectangle {
        radius: 16
        color: Kirigami.Theme.backgroundColor
        border.color: Kirigami.Theme.highlightColor
        border.width: 1
    }

    KIconThemes.IconDialog {
        id: editIconDialog
        title: Tr.t(root.lang, "chooseIconKde")
        onIconNameChanged: iconName => {
            if (iconName && iconName.length > 0) {
                editIconField.text = iconName;
            }
        }
    }

    onOpened: {
        if (itemData) {
            editTitleField.text = itemData.title || "";
            editIconField.text = itemData.icon || "";
            editUrlField.text = itemData.url || "";
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.smallSpacing

        RowLayout {
            Layout.fillWidth: true

            Kirigami.Heading {
                level: 3
                text: Tr.t(root.lang, "modalEditTitle")
                color: Kirigami.Theme.textColor
                font.bold: true
                Layout.fillWidth: true
            }

            Rectangle {
                implicitWidth: Kirigami.Units.iconSizes.smallMedium
                implicitHeight: Kirigami.Units.iconSizes.smallMedium
                radius: width / 2
                color: closeMouse.containsMouse ? Kirigami.Theme.hoverColor : "transparent"

                Kirigami.Icon {
                    anchors.centerIn: parent
                    width: Kirigami.Units.iconSizes.small
                    height: Kirigami.Units.iconSizes.small
                    source: "dialog-close"
                    color: Kirigami.Theme.textColor
                }

                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.close()
                }
            }
        }

        QQC2.Label {
            text: Tr.t(root.lang, "fieldName")
            font.bold: true
        }
        QQC2.TextField {
            id: editTitleField
            Layout.fillWidth: true
        }

        QQC2.Label {
            text: Tr.t(root.lang, "fieldIcon")
            font.bold: true
        }
        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            QQC2.TextField {
                id: editIconField
                Layout.fillWidth: true
            }

            Kirigami.Icon {
                implicitWidth: Kirigami.Units.iconSizes.medium
                implicitHeight: Kirigami.Units.iconSizes.medium
                source: editIconField.text || "application-x-executable"
            }

            QQC2.Button {
                icon.name: "preferences-desktop-icons"
                text: Tr.t(root.lang, "chooseIconKde")
                onClicked: editIconDialog.open()
            }
        }

        QQC2.Label {
            text: Tr.t(root.lang, "fieldUrl")
            font.bold: true
        }
        QQC2.TextField {
            id: editUrlField
            Layout.fillWidth: true
        }


        Item { Layout.fillHeight: true }

        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            QQC2.Button {
                text: Tr.t(root.lang, "delete")
                icon.name: "edit-delete"
                onClicked: {
                    root.itemDeleted(root.itemData, root.itemIndex);
                    root.close();
                }
            }

            Item { Layout.fillWidth: true }

            QQC2.Button {
                text: Tr.t(root.lang, "cancel")
                onClicked: root.close()
            }

            QQC2.Button {
                text: Tr.t(root.lang, "save")
                icon.name: "dialog-ok"
                enabled: editTitleField.text.trim().length > 0
                onClicked: {
                    var updated = Object.assign({}, root.itemData, {
                        title: editTitleField.text.trim(),
                        icon: editIconField.text.trim(),
                        url: editUrlField.text.trim()
                    });
                    root.itemSaved(updated, root.itemIndex);
                    root.close();
                }
            }
        }
    }
}

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
    property var systemApps: []

    signal itemAdded(var item)

    modal: true
    focus: true
    dim: true
    closePolicy: QQC2.Popup.CloseOnEscape | QQC2.Popup.CloseOnPressOutside

    implicitWidth: Math.min(parent ? parent.width * 0.95 : 440, Kirigami.Units.gridUnit * 25)
    implicitHeight: Math.min(parent ? parent.height * 0.90 : 500, Kirigami.Units.gridUnit * 27)

    anchors.centerIn: parent

    background: Rectangle {
        radius: 16
        color: Kirigami.Theme.backgroundColor
        border.color: Kirigami.Theme.highlightColor
        border.width: 1
    }

    KIconThemes.IconDialog {
        id: nativeIconDialog
        title: Tr.t(root.lang, "chooseIconKde")
        onIconNameChanged: iconName => {
            if (iconName && iconName.length > 0) {
                customIconField.text = iconName;
            }
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
                text: Tr.t(root.lang, "modalAddTitle")
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

        QQC2.TabBar {
            id: tabBar
            Layout.fillWidth: true

            QQC2.TabButton {
                text: Tr.t(root.lang, "tabSystemApps")
            }

            QQC2.TabButton {
                text: Tr.t(root.lang, "tabCustomItem")
            }
        }

        ColumnLayout {
            visible: tabBar.currentIndex === 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Kirigami.Units.smallSpacing

            Kirigami.SearchField {
                id: appSearchField
                Layout.fillWidth: true
                placeholderText: Tr.t(root.lang, "searchAppsPlaceholder")
            }

            readonly property var filteredApps: {
                var query = appSearchField.text.trim().toLowerCase();
                var apps = root.systemApps || [];
                if (query.length === 0) return apps;
                return apps.filter(function(a) {
                    var n = String(a.name || "").toLowerCase();
                    var d = String(a.desc || "").toLowerCase();
                    var c = String(a.category || "").toLowerCase();
                    return n.indexOf(query) !== -1 || d.indexOf(query) !== -1 || c.indexOf(query) !== -1;
                });
            }

            QQC2.ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                ListView {
                    id: appsListView
                    model: parent.parent.filteredApps
                    spacing: 4

                    delegate: Rectangle {
                        id: appDelegate
                        width: appsListView.width
                        implicitHeight: Kirigami.Units.gridUnit * 2.8
                        radius: 8
                        color: appDelegateMouse.containsMouse ? Kirigami.Theme.hoverColor : "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Kirigami.Units.smallSpacing
                            anchors.rightMargin: Kirigami.Units.smallSpacing
                            spacing: Kirigami.Units.mediumSpacing

                            Kirigami.Icon {
                                Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                                source: modelData.icon || "application-x-executable"
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1

                                QQC2.Label {
                                    Layout.fillWidth: true
                                    text: modelData.name
                                    font.bold: true
                                    color: Kirigami.Theme.textColor
                                    elide: Text.ElideRight
                                }

                                QQC2.Label {
                                    Layout.fillWidth: true
                                    text: modelData.desc || modelData.category || ""
                                    font.pointSize: Kirigami.Theme.smallFont.pointSize - 1
                                    color: Kirigami.Theme.disabledTextColor
                                    elide: Text.ElideRight
                                    visible: text.length > 0
                                }
                            }

                            Kirigami.Icon {
                                source: "list-add"
                                implicitWidth: Kirigami.Units.iconSizes.small
                                implicitHeight: Kirigami.Units.iconSizes.small
                                color: Kirigami.Theme.highlightColor
                                visible: appDelegateMouse.containsMouse
                            }
                        }

                        MouseArea {
                            id: appDelegateMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var appUrl = String(modelData.desktopFile || "");
                                if (appUrl.indexOf("applications:") !== 0 && appUrl.indexOf("file:") !== 0 && appUrl.indexOf("/") !== 0) {
                                    appUrl = "applications:" + (appUrl.length > 0 ? appUrl : (modelData.name.toLowerCase() + ".desktop"));
                                }
                                root.itemAdded({
                                    id: "app-" + Date.now() + "-" + Math.floor(Math.random() * 1000),
                                    title: modelData.name,
                                    icon: String(modelData.icon || "application-x-executable"),
                                    url: appUrl,
                                    type: "application",
                                    launchCount: 0
                                });
                                root.close();
                            }
                        }
                    }
                }
            }
        }

        QQC2.ScrollView {
            visible: tabBar.currentIndex === 1
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: Kirigami.Units.smallSpacing

                QQC2.Label {
                    text: Tr.t(root.lang, "fieldName")
                    font.bold: true
                }
                QQC2.TextField {
                    id: customTitleField
                    Layout.fillWidth: true
                    placeholderText: "e.g. Work Documents"
                }

                QQC2.Label {
                    text: Tr.t(root.lang, "fieldUrl")
                    font.bold: true
                }
                QQC2.TextField {
                    id: customUrlField
                    Layout.fillWidth: true
                    placeholderText: Tr.t(root.lang, "fieldUrlHint")
                }

                QQC2.Label {
                    text: Tr.t(root.lang, "fieldIcon")
                    font.bold: true
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing

                    QQC2.TextField {
                        id: customIconField
                        Layout.fillWidth: true
                        placeholderText: "e.g. folder-documents"
                    }

                    Kirigami.Icon {
                        implicitWidth: Kirigami.Units.iconSizes.medium
                        implicitHeight: Kirigami.Units.iconSizes.medium
                        source: customIconField.text || "folder"
                    }

                    QQC2.Button {
                        icon.name: "preferences-desktop-icons"
                        text: Tr.t(root.lang, "chooseIconKde")
                        onClicked: nativeIconDialog.open()
                    }
                }

                QQC2.Label {
                    text: Tr.t(root.lang, "presetIcons")
                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                    color: Kirigami.Theme.disabledTextColor
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: 6

                    Repeater {
                        model: ["folder", "folder-documents", "folder-download", "utilities-terminal", "internet-web-browser", "system-file-manager"]

                        Rectangle {
                            implicitWidth: Kirigami.Units.iconSizes.medium
                            implicitHeight: Kirigami.Units.iconSizes.medium
                            radius: 6
                            color: presetMouse.containsMouse ? Kirigami.Theme.hoverColor : Kirigami.Theme.backgroundColor
                            border.color: customIconField.text === modelData ? Kirigami.Theme.highlightColor : Kirigami.Theme.hoverColor
                            border.width: 1

                            Kirigami.Icon {
                                anchors.centerIn: parent
                                width: Kirigami.Units.iconSizes.small
                                height: Kirigami.Units.iconSizes.small
                                source: modelData
                            }

                            MouseArea {
                                id: presetMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: customIconField.text = modelData
                            }
                        }
                    }
                }

                Item { Layout.preferredHeight: Kirigami.Units.largeSpacing }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing

                    Item { Layout.fillWidth: true }

                    QQC2.Button {
                        text: Tr.t(root.lang, "cancel")
                        onClicked: root.close()
                    }

                    QQC2.Button {
                        text: Tr.t(root.lang, "save")
                        icon.name: "dialog-ok"
                        enabled: customTitleField.text.trim().length > 0 && customUrlField.text.trim().length > 0
                        onClicked: {
                            var isDir = customUrlField.text.indexOf("http") !== 0 && customUrlField.text.indexOf(".") === -1;
                            root.itemAdded({
                                id: "item-" + Date.now() + "-" + Math.floor(Math.random() * 1000),
                                title: customTitleField.text.trim(),
                                icon: customIconField.text.trim() || (isDir ? "folder" : "application-x-executable"),
                                url: customUrlField.text.trim(),
                                type: isDir ? "directory" : "file",
                                launchCount: 0
                            });
                            customTitleField.text = "";
                            customUrlField.text = "";
                            customIconField.text = "";
                            root.close();
                        }
                    }
                }
            }
        }
    }
}

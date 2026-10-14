import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import "../lib/Translations.js" as Tr

Item {
    id: root

    property string title: "Applications"
    property int itemsCount: 0
    property string lang: "en"
    property bool isPinned: false
    property bool showPinButton: false
    property bool enableFilter: true
    property string searchQuery: ""
    property string activeTypeFilter: "all"

    signal pinToggled()
    signal addClicked()
    signal settingsClicked()
    signal searchChanged(string query)
    signal typeFilterChanged(string type)

    property bool searchActive: false

    implicitHeight: Math.max(Kirigami.Units.gridUnit * 2.4, 38)
    clip: true

    RowLayout {
        id: searchModeLayout
        anchors.fill: parent
        anchors.leftMargin: 4
        anchors.rightMargin: 4
        visible: root.searchActive
        spacing: 6

        Rectangle {
            implicitWidth: Kirigami.Units.iconSizes.smallMedium
            implicitHeight: Kirigami.Units.iconSizes.smallMedium
            radius: width / 2
            color: closeSearchMouse.containsMouse ? Kirigami.Theme.hoverColor : "transparent"

            Kirigami.Icon {
                anchors.centerIn: parent
                width: Kirigami.Units.iconSizes.small
                height: Kirigami.Units.iconSizes.small
                source: "go-previous"
                color: Kirigami.Theme.textColor
            }

            MouseArea {
                id: closeSearchMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    searchField.text = "";
                    root.searchActive = false;
                    root.searchQuery = "";
                    root.searchChanged("");
                }
            }

            QQC2.ToolTip {
                visible: closeSearchMouse.containsMouse
                text: Tr.t(root.lang, "closeSearch")
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Kirigami.Units.gridUnit * 2.0
            radius: height / 2
            color: Kirigami.Theme.backgroundColor
            border.color: Kirigami.Theme.highlightColor
            border.width: 1.5

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 6

                Kirigami.Icon {
                    source: "edit-find"
                    implicitWidth: Kirigami.Units.iconSizes.small * 0.8
                    implicitHeight: Kirigami.Units.iconSizes.small * 0.8
                    color: Kirigami.Theme.highlightColor
                }

                QQC2.TextField {
                    id: searchField
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumWidth: 0
                    background: null
                    padding: 0
                    placeholderText: Tr.t(root.lang, "searchPlaceholder")
                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                    color: Kirigami.Theme.textColor

                    onTextChanged: {
                        root.searchQuery = text;
                        root.searchChanged(text);
                    }

                    Keys.onEscapePressed: {
                        text = "";
                        root.searchActive = false;
                        root.searchQuery = "";
                        root.searchChanged("");
                    }
                }

                Kirigami.Icon {
                    visible: root.searchQuery.length > 0
                    source: "edit-clear"
                    implicitWidth: Kirigami.Units.iconSizes.small * 0.8
                    implicitHeight: Kirigami.Units.iconSizes.small * 0.8
                    color: clearMouse.containsMouse ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor

                    MouseArea {
                        id: clearMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            searchField.text = "";
                            searchField.forceActiveFocus();
                        }
                    }
                }
            }
        }
    }

    RowLayout {
        id: normalHeaderLayout
        anchors.fill: parent
        anchors.leftMargin: 4
        anchors.rightMargin: 4
        visible: !root.searchActive
        spacing: 4

        RowLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            Layout.alignment: Qt.AlignVCenter
            spacing: 6

            QQC2.Label {
                text: root.title
                font.bold: true
                font.weight: Font.Bold
                font.pointSize: Kirigami.Theme.defaultFont.pointSize + 2
                color: Kirigami.Theme.textColor
                elide: Text.ElideRight
                Layout.fillWidth: true
                Layout.minimumWidth: 0
            }

            Rectangle {
                visible: root.width > Kirigami.Units.gridUnit * 12
                implicitWidth: countText.implicitWidth + 12
                implicitHeight: Kirigami.Units.gridUnit * 1.25
                radius: height / 2
                color: Kirigami.Theme.highlightColor

                QQC2.Label {
                    id: countText
                    anchors.centerIn: parent
                    text: root.itemsCount
                    font.pointSize: Math.max(7, Kirigami.Theme.smallFont.pointSize - 1)
                    font.bold: true
                    font.weight: Font.Bold
                    color: Kirigami.Theme.highlightedTextColor
                }
            }
        }

        RowLayout {
            spacing: 3
            Layout.alignment: Qt.AlignVCenter

            Rectangle {
                visible: root.enableFilter
                implicitWidth: Kirigami.Units.gridUnit * 1.8
                implicitHeight: Kirigami.Units.gridUnit * 1.8
                radius: height / 2
                color: searchTriggerMouse.containsMouse ? Kirigami.Theme.hoverColor : "transparent"

                Kirigami.Icon {
                    anchors.centerIn: parent
                    width: Kirigami.Units.iconSizes.small * 0.9
                    height: Kirigami.Units.iconSizes.small * 0.9
                    source: "edit-find"
                    color: Kirigami.Theme.textColor
                }

                MouseArea {
                    id: searchTriggerMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.searchActive = true;
                        searchField.forceActiveFocus();
                    }
                }

                QQC2.ToolTip {
                    visible: searchTriggerMouse.containsMouse
                    text: Tr.t(root.lang, "search")
                    delay: Kirigami.Units.toolTipDelay
                }
            }

            Rectangle {
                implicitWidth: Kirigami.Units.gridUnit * 1.8
                implicitHeight: Kirigami.Units.gridUnit * 1.8
                radius: height / 2
                color: addMouse.containsMouse ? Kirigami.Theme.hoverColor : "transparent"
                border.color: addMouse.containsMouse ? Kirigami.Theme.highlightColor : Kirigami.Theme.hoverColor
                border.width: 1

                Kirigami.Icon {
                    anchors.centerIn: parent
                    width: Kirigami.Units.iconSizes.small * 0.9
                    height: Kirigami.Units.iconSizes.small * 0.9
                    source: "list-add"
                    color: Kirigami.Theme.textColor
                }

                MouseArea {
                    id: addMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.addClicked()
                }

                QQC2.ToolTip {
                    visible: addMouse.containsMouse
                    text: Tr.t(root.lang, "addItem")
                    delay: Kirigami.Units.toolTipDelay
                }
            }

            PinButton {
                id: pinBtn
                visible: root.showPinButton
                pinned: root.isPinned
                lang: root.lang
                implicitWidth: Kirigami.Units.gridUnit * 1.8
                implicitHeight: Kirigami.Units.gridUnit * 1.8
                onClicked: root.pinToggled()
            }

            Rectangle {
                implicitWidth: Kirigami.Units.gridUnit * 1.8
                implicitHeight: Kirigami.Units.gridUnit * 1.8
                radius: height / 2
                color: settingsMouse.containsMouse ? Kirigami.Theme.hoverColor : "transparent"

                Kirigami.Icon {
                    anchors.centerIn: parent
                    width: Kirigami.Units.iconSizes.small * 0.9
                    height: Kirigami.Units.iconSizes.small * 0.9
                    source: "configure"
                    color: Kirigami.Theme.disabledTextColor
                }

                MouseArea {
                    id: settingsMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.settingsClicked()
                }

                QQC2.ToolTip {
                    visible: settingsMouse.containsMouse
                    text: Tr.t(root.lang, "openSettings")
                    delay: Kirigami.Units.toolTipDelay
                }
            }
        }
    }
}

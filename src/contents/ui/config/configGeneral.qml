import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.iconthemes as KIconThemes
import "../lib/Translations.js" as Tr
import "../lib/UiStyle.js" as UiStyle

KCM.SimpleKCM {
    id: page

    property string cfg_groupTitle: "Applications"
    property string cfg_groupTitleDefault: "Applications"
    property alias cfg_showHeader: showHeaderCheck.checked
    property bool cfg_showHeaderDefault: true
    property string cfg_panelIcon: "com.keyaruga.applicationgroup"
    property string cfg_panelIconDefault: "com.keyaruga.applicationgroup"
    property alias cfg_showBadge: showBadgeCheck.checked
    property bool cfg_showBadgeDefault: true
    property alias cfg_enableFilter: enableFilterCheck.checked
    property bool cfg_enableFilterDefault: true
    property string cfg_language: "auto"
    property string cfg_languageDefault: "auto"
    property alias cfg_singleClickLaunch: singleClickCheck.checked
    property bool cfg_singleClickLaunchDefault: true
    property string cfg_sortBy: "manual"
    property string cfg_sortByDefault: "manual"

    readonly property string lang: {
        if (cfg_language === "fa" || cfg_language === "en")
            return cfg_language;
        return Qt.locale().name.indexOf("fa") === 0 ? "fa" : "en";
    }

    function tr(key, args) { return Tr.t(lang, key, args); }

    LayoutMirroring.enabled: page.lang === "fa"
    LayoutMirroring.childrenInherit: true

    KIconThemes.IconDialog {
        id: panelIconDialog
        title: page.tr("cfgChoosePanelIcon")
        onIconNameChanged: iconName => {
            if (iconName && iconName.length > 0) {
                page.cfg_panelIcon = iconName;
            }
        }
    }

    Kirigami.FormLayout {

        QQC2.ComboBox {
            Kirigami.FormData.label: page.tr("cfgLanguage")
            textRole: "label"
            valueRole: "value"
            model: [
                { value: "auto", label: page.tr("cfgLangAuto") },
                { value: "fa",   label: page.tr("cfgLangFa") },
                { value: "en",   label: page.tr("cfgLangEn") }
            ]
            Component.onCompleted: currentIndex = indexOfValue(page.cfg_language)
            onActivated: page.cfg_language = currentValue
        }

        Item { Kirigami.FormData.isSection: true }

        QQC2.TextField {
            Kirigami.FormData.label: page.tr("cfgGroupTitle")
            text: page.cfg_groupTitle
            onTextChanged: page.cfg_groupTitle = text
        }

        QQC2.CheckBox {
            id: showHeaderCheck
            Kirigami.FormData.label: page.tr("cfgShowHeader")
            checked: true
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: page.tr("sortBy")
            textRole: "label"
            valueRole: "value"
            model: [
                { value: "manual", label: page.tr("sortManual") },
                { value: "name",   label: page.tr("sortName") },
                { value: "usage",  label: page.tr("sortUsage") }
            ]
            Component.onCompleted: currentIndex = indexOfValue(page.cfg_sortBy)
            onActivated: page.cfg_sortBy = currentValue
        }

        Item { Kirigami.FormData.isSection: true }

        RowLayout {
            Kirigami.FormData.label: page.tr("cfgPanelIcon")
            spacing: Kirigami.Units.smallSpacing

            QQC2.TextField {
                id: panelIconField
                Layout.preferredWidth: Kirigami.Units.gridUnit * 8
                text: page.cfg_panelIcon
                onTextChanged: page.cfg_panelIcon = text
            }

            Kirigami.Icon {
                implicitWidth: Kirigami.Units.iconSizes.medium
                implicitHeight: Kirigami.Units.iconSizes.medium
                source: {
                    if (page.cfg_panelIcon && page.cfg_panelIcon !== "com.keyaruga.applicationgroup" && page.cfg_panelIcon !== "folder-apps") {
                        return page.cfg_panelIcon;
                    }
                    return Qt.resolvedUrl("../../icons/logo.png");
                }
            }

            QQC2.Button {
                icon.name: "preferences-desktop-icons"
                text: page.tr("chooseIconKde")
                onClicked: panelIconDialog.open()
            }
        }

        QQC2.CheckBox {
            id: showBadgeCheck
            Kirigami.FormData.label: page.tr("cfgShowBadge")
            checked: true
        }

        QQC2.CheckBox {
            id: enableFilterCheck
            Kirigami.FormData.label: page.tr("cfgEnableFilter")
            checked: true
        }

        QQC2.CheckBox {
            id: singleClickCheck
            Kirigami.FormData.label: page.tr("cfgSingleClick")
            checked: true
        }
    }
}

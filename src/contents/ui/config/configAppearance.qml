import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import "../lib/Translations.js" as Tr
import "../lib/UiStyle.js" as UiStyle

KCM.SimpleKCM {
    id: page

    property string cfg_viewMode: "grid"
    property string cfg_viewModeDefault: "grid"
    property string cfg_columnsMode: "auto"
    property string cfg_columnsModeDefault: "auto"
    property int cfg_gridColumns: 4
    property int cfg_gridColumnsDefault: 4
    property string cfg_iconSize: "medium"
    property string cfg_iconSizeDefault: "medium"
    property string cfg_backgroundStyle: "card"
    property string cfg_backgroundStyleDefault: "card"
    property real cfg_backgroundOpacity: 0.85
    property real cfg_backgroundOpacityDefault: 0.85
    property int cfg_borderRadius: 16
    property int cfg_borderRadiusDefault: 16
    property alias cfg_showLabels: showLabelsCheck.checked
    property bool cfg_showLabelsDefault: true
    property int cfg_fontSizeDelta: 0
    property int cfg_fontSizeDeltaDefault: 0
    property string cfg_language: "auto"

    readonly property string lang: {
        if (cfg_language === "fa" || cfg_language === "en")
            return cfg_language;
        return Qt.locale().name.indexOf("fa") === 0 ? "fa" : "en";
    }

    function tr(key, args) { return Tr.t(lang, key, args); }

    LayoutMirroring.enabled: page.lang === "fa"
    LayoutMirroring.childrenInherit: true

    Kirigami.FormLayout {

        QQC2.ComboBox {
            Kirigami.FormData.label: page.tr("cfgViewMode")
            textRole: "label"
            valueRole: "value"
            model: [
                { value: "grid", label: page.tr("cfgGrid") },
                { value: "list", label: page.tr("cfgList") }
            ]
            Component.onCompleted: currentIndex = indexOfValue(page.cfg_viewMode)
            onActivated: page.cfg_viewMode = currentValue
        }

        QQC2.ComboBox {
            visible: page.cfg_viewMode === "grid"
            Kirigami.FormData.label: page.tr("cfgColumnsMode")
            textRole: "label"
            valueRole: "value"
            model: [
                { value: "auto",  label: page.tr("cfgColumnsAuto") },
                { value: "fixed", label: page.tr("cfgColumnsFixed") }
            ]
            Component.onCompleted: currentIndex = indexOfValue(page.cfg_columnsMode)
            onActivated: page.cfg_columnsMode = currentValue
        }

        QQC2.ComboBox {
            visible: page.cfg_viewMode === "grid" && page.cfg_columnsMode === "fixed"
            Kirigami.FormData.label: page.tr("cfgGridColumns")
            textRole: "label"
            valueRole: "value"
            model: [
                { value: 2, label: "2" },
                { value: 3, label: "3" },
                { value: 4, label: "4" },
                { value: 5, label: "5" },
                { value: 6, label: "6" },
                { value: 7, label: "7" },
                { value: 8, label: "8" }
            ]
            Component.onCompleted: currentIndex = indexOfValue(page.cfg_gridColumns)
            onActivated: page.cfg_gridColumns = currentValue
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: page.tr("cfgIconSize")
            textRole: "label"
            valueRole: "value"
            model: [
                { value: "small",  label: page.tr("cfgSizeSmall") },
                { value: "medium", label: page.tr("cfgSizeMedium") },
                { value: "large",  label: page.tr("cfgSizeLarge") },
                { value: "huge",   label: page.tr("cfgSizeHuge") }
            ]
            Component.onCompleted: currentIndex = indexOfValue(page.cfg_iconSize)
            onActivated: page.cfg_iconSize = currentValue
        }

        QQC2.CheckBox {
            id: showLabelsCheck
            Kirigami.FormData.label: page.tr("cfgShowLabels")
            checked: true
        }

        Item { Kirigami.FormData.isSection: true }

        QQC2.ComboBox {
            Kirigami.FormData.label: page.tr("cfgBackgroundStyle")
            textRole: "label"
            valueRole: "value"
            model: [
                { value: "card",    label: page.tr("cfgStyleCard") },
                { value: "glass",   label: page.tr("cfgStyleGlass") },
                { value: "flat",    label: page.tr("cfgStyleFlat") },
                { value: "outline", label: page.tr("cfgStyleOutline") }
            ]
            Component.onCompleted: currentIndex = indexOfValue(page.cfg_backgroundStyle)
            onActivated: page.cfg_backgroundStyle = currentValue
        }

        RowLayout {
            visible: page.cfg_backgroundStyle !== "flat"
            Kirigami.FormData.label: page.tr("cfgBackgroundOpacity")
            spacing: Kirigami.Units.smallSpacing

            QQC2.Slider {
                Layout.preferredWidth: Kirigami.Units.gridUnit * 10
                from: 0.1
                to: 1.0
                stepSize: 0.05
                value: page.cfg_backgroundOpacity
                onMoved: page.cfg_backgroundOpacity = Math.round(value * 100) / 100
            }

            QQC2.Label {
                text: Math.round(page.cfg_backgroundOpacity * 100) + "%"
            }
        }

        RowLayout {
            visible: page.cfg_backgroundStyle !== "flat"
            Kirigami.FormData.label: page.tr("cfgBorderRadius")
            spacing: Kirigami.Units.smallSpacing

            QQC2.Slider {
                Layout.preferredWidth: Kirigami.Units.gridUnit * 10
                from: 0
                to: 32
                stepSize: 2
                value: page.cfg_borderRadius
                onMoved: page.cfg_borderRadius = Math.round(value)
            }

            QQC2.Label {
                text: page.cfg_borderRadius + "px"
            }
        }

        QQC2.SpinBox {
            Kirigami.FormData.label: page.tr("cfgFontSizeDelta")
            from: -2
            to: 6
            value: page.cfg_fontSizeDelta
            onValueModified: page.cfg_fontSizeDelta = value
        }
    }
}

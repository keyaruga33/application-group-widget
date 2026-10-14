import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18n("General")
        icon: "configure"
        source: "config/configGeneral.qml"
    }

    ConfigCategory {
        name: i18n("Appearance")
        icon: "preferences-desktop-theme"
        source: "config/configAppearance.qml"
    }

    ConfigCategory {
        name: i18n("Items")
        icon: "view-list-details"
        source: "config/configItems.qml"
    }
}

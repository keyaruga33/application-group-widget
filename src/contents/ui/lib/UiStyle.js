.pragma library

var ICON_SIZES = {
    small:  32,
    medium: 48,
    large:  64,
    huge:   96
};

function getIconPixelSize(sizeName) {
    if (ICON_SIZES[sizeName]) {
        return ICON_SIZES[sizeName];
    }
    return ICON_SIZES.medium;
}

var PRESET_PANEL_ICONS = [
    { value: "folder-apps",          label: "Apps Folder" },
    { value: "applications-other",   label: "Applications" },
    { value: "folder-favorites",     label: "Favorites Folder" },
    { value: "applications-system",  label: "System Apps" },
    { value: "folder",               label: "Default Folder" },
    { value: "start-here-kde",       label: "KDE Logo" },
    { value: "favorite",             label: "Star" },
    { value: "view-grid",            label: "Grid" },
    { value: "package-x-generic",    label: "Package" },
    { value: "user-desktop",         label: "Desktop" }
];

var PRESET_ITEM_ICONS = [
    "system-file-manager",
    "utilities-terminal",
    "systemsettings",
    "internet-web-browser",
    "firefox",
    "google-chrome",
    "com.visualstudio.code",
    "kate",
    "folder",
    "folder-documents",
    "folder-download",
    "folder-pictures",
    "folder-music",
    "folder-videos",
    "folder-favorites",
    "applications-games",
    "multimedia-player",
    "vlc",
    "accessories-calculator",
    "accessories-text-editor",
    "application-pdf",
    "document-edit",
    "starred-symbolic"
];

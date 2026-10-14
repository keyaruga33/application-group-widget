.pragma library

var APP_DICTIONARY = {
    "org.kde.dolphin":              { name: "Dolphin", icon: "system-file-manager" },
    "org.kde.konsole":              { name: "Konsole", icon: "utilities-terminal" },
    "org.kde.kate":                 { name: "Kate", icon: "kate" },
    "org.kde.kwrite":               { name: "KWrite", icon: "kwrite" },
    "org.kde.ark":                  { name: "Ark", icon: "ark" },
    "org.kde.gwenview":             { name: "Gwenview", icon: "gwenview" },
    "org.kde.okular":               { name: "Okular", icon: "okular" },
    "org.kde.spectacle":            { name: "Spectacle", icon: "spectacle" },
    "org.kde.kcalc":                { name: "KCalc", icon: "accessories-calculator" },
    "systemsettings":               { name: "System Settings", icon: "systemsettings" },
    "org.kde.systemsettings":       { name: "System Settings", icon: "systemsettings" },
    "org.kde.plasma-systemmonitor": { name: "System Monitor", icon: "utilities-system-monitor" },
    "org.kde.discover":             { name: "Discover", icon: "plasmagtk" },
    "firefox":                      { name: "Firefox", icon: "firefox" },
    "google-chrome":                { name: "Google Chrome", icon: "google-chrome" },
    "chromium":                     { name: "Chromium", icon: "chromium" },
    "brave-browser":                { name: "Brave", icon: "brave-browser" },
    "com.visualstudio.code":        { name: "VS Code", icon: "com.visualstudio.code" },
    "code":                         { name: "VS Code", icon: "com.visualstudio.code" },
    "vlc":                          { name: "VLC", icon: "vlc" },
    "mpv":                          { name: "MPV", icon: "mpv" },
    "org.telegram.desktop":         { name: "Telegram", icon: "telegram" },
    "telegram-desktop":             { name: "Telegram", icon: "telegram" },
    "discord":                      { name: "Discord", icon: "discord" },
    "com.discordapp.Discord":       { name: "Discord", icon: "discord" },
    "spotify":                      { name: "Spotify", icon: "spotify" },
    "com.spotify.Client":           { name: "Spotify", icon: "spotify" },
    "steam":                        { name: "Steam", icon: "steam" },
    "org.gimp.GIMP":                { name: "GIMP", icon: "gimp" },
    "gimp":                         { name: "GIMP", icon: "gimp" },
    "org.inkscape.Inkscape":        { name: "Inkscape", icon: "inkscape" },
    "inkscape":                     { name: "Inkscape", icon: "inkscape" },
    "org.blender.Blender":          { name: "Blender", icon: "blender" },
    "blender":                      { name: "Blender", icon: "blender" },
    "com.obsproject.Studio":        { name: "OBS Studio", icon: "obs" }
};

var KNOWN_FOLDERS = {
    "desktop":    "user-desktop",
    "documents":  "folder-documents",
    "downloads":  "folder-download",
    "download":   "folder-download",
    "pictures":   "folder-pictures",
    "music":      "folder-music",
    "videos":     "folder-videos",
    "public":     "folder-publicshare",
    "templates":  "folder-templates",
    "home":       "user-home"
};

var EXTENSION_ICONS = {
    "pdf":  "application-pdf",
    "txt":  "text-plain",
    "md":   "text-markdown",
    "doc":  "application-msword",
    "docx": "application-msword",
    "xls":  "application-vnd.ms-excel",
    "xlsx": "application-vnd.ms-excel",
    "ppt":  "application-vnd.ms-powerpoint",
    "pptx": "application-vnd.ms-powerpoint",
    "png":  "image-x-generic",
    "jpg":  "image-x-generic",
    "jpeg": "image-x-generic",
    "svg":  "image-x-generic",
    "gif":  "image-x-generic",
    "mp3":  "audio-x-generic",
    "flac": "audio-x-generic",
    "wav":  "audio-x-generic",
    "mp4":  "video-x-generic",
    "mkv":  "video-x-generic",
    "avi":  "video-x-generic",
    "zip":  "application-zip",
    "tar":  "application-x-tar",
    "gz":   "application-gzip",
    "7z":   "application-x-7z-compressed",
    "sh":   "application-x-shellscript",
    "py":   "text-x-python",
    "js":   "text-x-javascript",
    "json": "application-json",
    "html": "text-html"
};

function cleanTitle(str) {
    if (!str) return "Item";
    str = str.replace(/\.desktop$/ig, "");
    str = str.replace(/\.desktop$/ig, "");
    var parts = str.split(".");
    if (parts.length > 2) {
        var last = parts[parts.length - 1].toLowerCase();
        if ((last === "desktop" || last === "client" || last === "app") && parts.length > 2) {
            str = parts[parts.length - 2];
        } else {
            str = parts[parts.length - 1];
        }
    }
    str = str.replace(/[-_]+/g, " ");
    return str.split(" ").map(function(w) {
        return w.charAt(0).toUpperCase() + w.slice(1);
    }).join(" ");
}

function resolveFromUrl(rawUrl, systemApps) {
    if (!rawUrl) return null;

    var urlStr = String(rawUrl).trim();
    if (urlStr.length === 0) return null;

    var id = "item-" + Date.now() + "-" + Math.floor(Math.random() * 1000);
    var title = "";
    var icon = "application-x-executable";
    var type = "application";

    if (urlStr.indexOf("applications:") === 0) {
        var appFile = urlStr.replace("applications:", "");
        urlStr = "file:///usr/share/applications/" + appFile;
    }

    if (urlStr.indexOf("http://") === 0 || urlStr.indexOf("https://") === 0) {
        type = "url";
        icon = "internet-web-browser";
        try {
            var domain = urlStr.replace(/^https?:\/\//i, "").split("/")[0];
            title = domain.replace(/^www\./i, "");
        } catch (e) {
            title = urlStr;
        }
        return {
            id: id,
            title: title || "Web Link",
            icon: icon,
            url: urlStr,
            type: type
        };
    }

    var path = urlStr;
    if (path.indexOf("file://") === 0) {
        path = decodeURIComponent(path.substring(7));
    }

    while (path.length > 1 && path.charAt(path.length - 1) === "/") {
        path = path.slice(0, -1);
    }

    var segments = path.split("/");
    var fileName = segments[segments.length - 1] || "Item";

    if (fileName.toLowerCase().indexOf(".desktop") !== -1) {
        type = "application";
        var baseKey = fileName.replace(/\.desktop$/ig, "");
        if (baseKey.toLowerCase().indexOf(".desktop") !== -1) {
            baseKey = baseKey.replace(/\.desktop$/ig, "");
        }

        var matchedInApps = false;
        if (systemApps && systemApps.length > 0) {
            var needle = fileName.toLowerCase().replace(/\.desktop$/ig, "");
            for (var k = 0; k < systemApps.length; k++) {
                var sa = systemApps[k];
                var df = String(sa.desktopFile || "").toLowerCase().replace(/\.desktop$/ig, "");
                var lastSlash = df.lastIndexOf("/");
                if (lastSlash !== -1) df = df.substring(lastSlash + 1);
                if (df === needle || df === baseKey.toLowerCase() || (sa.name && sa.name.toLowerCase() === needle)) {
                    title = sa.name;
                    icon = sa.icon;
                    matchedInApps = true;
                    break;
                }
            }
        }

        if (!matchedInApps) {
            if (APP_DICTIONARY[baseKey]) {
                title = APP_DICTIONARY[baseKey].name;
                icon = APP_DICTIONARY[baseKey].icon;
            } else if (APP_DICTIONARY[baseKey.toLowerCase()]) {
                title = APP_DICTIONARY[baseKey.toLowerCase()].name;
                icon = APP_DICTIONARY[baseKey.toLowerCase()].icon;
            } else {
                title = cleanTitle(fileName);
                icon = baseKey;
            }
        }
    } else {
        var dotIdx = fileName.lastIndexOf(".");
        var lowerName = fileName.toLowerCase();

        if (KNOWN_FOLDERS[lowerName]) {
            type = "directory";
            title = cleanTitle(fileName);
            icon = KNOWN_FOLDERS[lowerName];
        } else if (dotIdx === -1 || dotIdx === 0) {
            type = "directory";
            title = cleanTitle(fileName);
            icon = "folder";
        } else {
            type = "file";
            title = fileName;
            var ext = fileName.substring(dotIdx + 1).toLowerCase();
            icon = EXTENSION_ICONS[ext] || "unknown";
        }
    }

    return {
        id: id,
        title: title,
        icon: icon,
        url: urlStr,
        type: type
    };
}

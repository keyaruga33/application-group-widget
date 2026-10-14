.pragma library

function parseItems(jsonString) {
    if (!jsonString || typeof jsonString !== "string") {
        return [];
    }
    try {
        var parsed = JSON.parse(jsonString);
        if (Array.isArray(parsed)) {
            return parsed.map(function(item) {
                if (item.launchCount === undefined || item.launchCount === null) {
                    item.launchCount = 0;
                }
                return item;
            });
        }
    } catch (e) {
        console.warn("Failed to parse items JSON:", e);
    }
    return [];
}

function stringifyItems(itemsArray) {
    if (!Array.isArray(itemsArray)) {
        return "[]";
    }
    return JSON.stringify(itemsArray);
}

function addItem(items, newItem) {
    var list = (items || []).slice(0);
    if (!newItem || !newItem.url) return list;

    if (!newItem.id) {
        newItem.id = "item-" + Date.now() + "-" + Math.floor(Math.random() * 1000);
    }
    if (newItem.launchCount === undefined) {
        newItem.launchCount = 0;
    }

    list.push(newItem);
    return list;
}

function updateItem(items, updatedItem) {
    var list = (items || []).slice(0);
    for (var i = 0; i < list.length; i++) {
        if (list[i].id === updatedItem.id) {
            list[i] = Object.assign({}, list[i], updatedItem);
            break;
        }
    }
    return list;
}

function removeItem(items, itemId) {
    var list = (items || []).slice(0);
    return list.filter(function(item) {
        return item.id !== itemId;
    });
}

function moveItem(items, fromIndex, toIndex) {
    var list = (items || []).slice(0);
    if (fromIndex < 0 || fromIndex >= list.length || toIndex < 0 || toIndex >= list.length) {
        return list;
    }
    var element = list.splice(fromIndex, 1)[0];
    list.splice(toIndex, 0, element);
    return list;
}

function incrementLaunch(items, itemId) {
    var list = (items || []).slice(0);
    for (var i = 0; i < list.length; i++) {
        if (list[i].id === itemId) {
            list[i] = Object.assign({}, list[i], {
                launchCount: ((list[i].launchCount || 0) + 1)
            });
            break;
        }
    }
    return list;
}

function filterAndSortItems(items, query, filterType, sortBy) {
    var list = (items || []).slice(0);

    if (filterType && filterType !== "all") {
        list = list.filter(function(item) {
            if (filterType === "apps") return item.type === "application";
            if (filterType === "dirs") return item.type === "directory";
            if (filterType === "files") return item.type === "file";
            if (filterType === "urls") return item.type === "url";
            return true;
        });
    }

    if (query && query.trim().length > 0) {
        var q = query.toLowerCase().trim();
        list = list.filter(function(item) {
            var titleMatch = item.title && item.title.toLowerCase().indexOf(q) !== -1;
            var urlMatch = item.url && item.url.toLowerCase().indexOf(q) !== -1;
            return titleMatch || urlMatch;
        });
    }

    if (sortBy === "name") {
        list.sort(function(a, b) {
            return String(a.title || "").localeCompare(String(b.title || ""));
        });
    } else if (sortBy === "usage") {
        list.sort(function(a, b) {
            return (b.launchCount || 0) - (a.launchCount || 0);
        });
    }

    return list;
}

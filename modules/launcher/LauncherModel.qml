import QtQuick
import Quickshell
import qs.services.config
import qs.services.desktop
import qs.style

// what the launcher lists for each mode, and what activating an entry does
QtObject {
    id: root

    property string mode: "apps"
    property string query: ""

    readonly property var modes: [
        {
            id: "apps",
            label: "Apps"
        },
        {
            id: "themes",
            label: "Themes"
        },
        {
            id: "fonts",
            label: "Fonts"
        },
        {
            id: "wallpapers",
            label: "Wallpapers"
        },
        {
            id: "session",
            label: "Session"
        }
    ]

    readonly property var sessionItems: [
        {
            name: "Lock",
            icon: "󰌾",
            sub: "Keep everything running",
            tone: "calm",
            command: []
        },
        {
            name: "Suspend",
            icon: "󰤄",
            sub: "Sleep to memory",
            tone: "calm",
            command: ["systemctl", "suspend"]
        },
        {
            name: "Hibernate",
            icon: "󰋊",
            sub: "Sleep to disk",
            tone: "calm",
            command: ["systemctl", "hibernate"]
        },
        {
            name: "Logout",
            icon: "󰍃",
            sub: "End this session",
            tone: "warn",
            command: ["hyprctl", "dispatch", "exit"]
        },
        {
            name: "Reboot",
            icon: "󰑓",
            sub: "Restart now",
            tone: "warn",
            command: ["systemctl", "reboot"]
        },
        {
            name: "Shutdown",
            icon: "󰐥",
            sub: "Power off",
            tone: "danger",
            command: ["systemctl", "poweroff"]
        }
    ]

    readonly property var results: {
        const q = query.trim().toLowerCase();
        const matches = name => !q || name.toLowerCase().includes(q);

        if (mode === "apps")
            return DesktopEntries.applications.values.filter(a => !a.noDisplay && (matches(a.name) || matches(a.comment ?? ""))).map(a => ({
                        kind: "app",
                        name: a.name,
                        sub: a.genericName || a.comment || "",
                        icon: Quickshell.iconPath(a.icon, true),
                        entry: a
                    })).sort((a, b) => (a.icon === "") - (b.icon === "") || a.name.localeCompare(b.name)).slice(0, 60);

        if (mode === "themes")
            return Appearance.themes.filter(t => matches(t.name)).map(t => {
                const light = t.name.endsWith("-light");
                return {
                    kind: "theme",
                    name: t.name,
                    base: light ? t.name.slice(0, -6) : t.name,
                    label: titled(light ? t.name.slice(0, -6) : t.name),
                    light,
                    theme: t.colours,
                    current: t.name === Config.theme
                };
            }).sort((a, b) => a.base.localeCompare(b.base) || a.light - b.light);

        if (mode === "fonts")
            return Appearance.fonts.filter(matches).map(family => ({
                        kind: "font",
                        name: family,
                        current: family === Theme.fontMono
                    }));

        if (mode === "wallpapers")
            return Appearance.wallpapers.filter(w => matches(w.name) || matches(w.label)).map(w => ({
                        kind: "wallpaper",
                        name: w.name,
                        label: w.label,
                        thumb: w.thumb,
                        current: w.name === Config.wallpaper
                    }));

        if (mode === "session")
            return sessionItems.filter(s => matches(s.name)).map(s => Object.assign({
                    kind: "session"
                }, s));

        return [];
    }

    function titled(name: string): string {
        return name.split("-").map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(" ");
    }

    function nextMode(): string {
        const i = modes.findIndex(m => m.id === mode);
        return modes[(i + 1) % modes.length].id;
    }

    function activate(item: var): bool {
        if (!item)
            return false;
        if (item.kind === "app")
            item.entry.execute();
        else if (item.kind === "theme")
            Appearance.setTheme(item.name);
        else if (item.kind === "font")
            Appearance.setFont(item.name);
        else if (item.kind === "wallpaper") {
            Appearance.setWallpaper(item.name);
            Notices.show("Wallpaper", item.label, "󰸉");
        } else if (item.command.length === 0)
            Lock.lock();
        else
            Quickshell.execDetached(item.command);
        return true;
    }
}

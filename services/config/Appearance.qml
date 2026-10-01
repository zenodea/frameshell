pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.services.config
import qs.services.desktop

Singleton {
    id: root

    property var themes: []
    property var fonts: []
    property var wallpapers: []

    function hook(kind: string, value: string): bool {
        const command = Config.hooks[kind];
        if (command)
            Quickshell.execDetached(["sh", "-c", command, "sh", value]);
        return Boolean(command);
    }

    function setTheme(name: string): void {
        Config.set("theme", name);
        hook("theme", name);
        Notices.show("Theme", name, "󰏘");
    }

    function setFont(family: string): void {
        Config.set("font", family);
        hook("font", family);
        Notices.show("Font", family, "󰛖");
    }

    function setWallpaper(name: string): void {
        const path = `${Config.wallpaperDir}/${name}`;
        Config.set("wallpaper", name);
        if (!hook("wallpaper", path))
            Quickshell.execDetached(["bash", `${Quickshell.shellDir}/scripts/config/wallpaper.sh`, path]);
    }

    function refreshThemes(): void {
        themeList.running = true;
    }

    function refreshWallpapers(): void {
        wallpaperList.running = true;
    }

    Process {
        id: themeList

        running: true
        command: ["bash", `${Quickshell.shellDir}/scripts/config/themes.sh`, `${Quickshell.shellDir}/themes`, `${Config.dir}/themes`]

        stdout: StdioCollector {
            onStreamFinished: {
                const found = {};
                for (const theme of JSON.parse(text))
                    found[theme.name] = theme;
                root.themes = Object.values(found);
            }
        }
    }

    Process {
        running: true
        command: ["bash", `${Quickshell.shellDir}/scripts/config/fonts.sh`]

        stdout: StdioCollector {
            onStreamFinished: root.fonts = text.split("\n").filter(family => family !== "")
        }
    }

    Process {
        id: wallpaperList

        running: true
        command: ["bash", `${Quickshell.shellDir}/scripts/config/wallpapers.sh`, Config.wallpaperDir, `${Config.cacheDir}/wallpapers`]

        stdout: StdioCollector {
            onStreamFinished: root.wallpapers = text.split("\n").filter(line => line.includes("\t")).map(line => {
                const [name, thumb] = line.split("\t");
                return {
                    name,
                    label: name.replace(/\.[^.]+$/, "").replace(/^\d+[-_ ]*/, "").replace(/[-_]+/g, " "),
                    thumb: `file://${thumb}`
                };
            })
        }
    }
}

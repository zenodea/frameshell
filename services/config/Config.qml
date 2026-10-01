pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string dir: `${Quickshell.env("XDG_CONFIG_HOME") || `${home}/.config`}/frameshell`
    readonly property string stateDir: `${Quickshell.env("XDG_STATE_HOME") || `${home}/.local/state`}/frameshell`
    readonly property string cacheDir: `${Quickshell.env("XDG_CACHE_HOME") || `${home}/.cache`}/frameshell`

    property bool ready: false
    property string theme: "gruvbox"
    property string font: ""
    property string wallpaper: ""
    property string wallpaperDir: `${home}/Pictures/Wallpapers`
    property string weather: ""
    property var hooks: ({})

    function set(key: string, value: string): void {
        root[key] = value;
        save.restart();
    }

    Process {
        running: true
        command: ["mkdir", "-p", root.dir, root.stateDir, root.cacheDir]
    }

    Timer {
        id: save

        interval: 50
        onTriggered: {
            if (!root.ready)
                return;
            adapter.theme = root.theme;
            adapter.font = root.font;
            adapter.wallpaper = root.wallpaper;
            file.writeAdapter();
        }
    }

    FileView {
        id: file

        path: `${root.dir}/config.json`
        printErrors: false
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            root.ready = true;
            if (save.running)
                return;
            root.theme = adapter.theme;
            root.font = adapter.font;
            root.wallpaper = adapter.wallpaper;
            root.wallpaperDir = adapter.wallpaperDir.replace(/^~/, root.home);
            root.weather = adapter.weather;
            root.hooks = adapter.hooks ?? {};
        }
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound)
                root.ready = true;
        }

        JsonAdapter {
            id: adapter

            property string theme: "gruvbox"
            property string font: ""
            property string wallpaper: ""
            property string wallpaperDir: "~/Pictures/Wallpapers"
            property string weather: ""
            property var hooks: ({})
        }
    }
}

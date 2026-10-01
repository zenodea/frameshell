pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.services.config

Singleton {
    id: root

    property color bg: "#282828"
    property color surface: "#3c3836"
    property color muted: "#928374"
    property color fg: "#ebdbb2"
    property color fgBright: "#fbf1c7"
    property color accent: "#83a598"
    property color blue: "#458588"
    property color red: "#fb4934"
    property color green: "#b8bb26"
    property color yellow: "#fabd2f"
    property color orange: "#fe8019"
    property color purple: "#d3869b"

    property string customFor: ""

    readonly property string monoRequested: Config.font
    readonly property var monoFallbacks: ["JetBrains Mono", "Hack", "Adwaita Mono", "Noto Sans Mono", "DejaVu Sans Mono"]

    readonly property string fontMono: {
        const installed = Qt.fontFamilies();
        if (monoRequested && installed.includes(monoRequested))
            return monoRequested;
        for (const family of monoFallbacks)
            if (installed.includes(family))
                return family;
        return "monospace";
    }

    function alpha(c: color, a: real): color {
        return Qt.rgba(c.r, c.g, c.b, a);
    }

    function load(data: string): void {
        let c;
        try {
            c = JSON.parse(data);
        } catch (e) {
            return;
        }

        root.bg = c.bg;
        root.surface = c.surface;
        root.muted = c.muted;
        root.fg = c.fg;
        root.fgBright = c.fgBright;
        root.accent = c.accent;
        root.blue = c.blue;
        root.red = c.red;
        root.green = c.green;
        root.yellow = c.yellow;
        root.orange = c.orange;
        root.purple = c.purple;
    }

    FileView {
        path: `${Config.dir}/themes/${Config.theme}.json`
        printErrors: false
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            root.customFor = Config.theme;
            root.load(text());
        }
    }

    FileView {
        path: `${Quickshell.shellDir}/themes/${Config.theme}.json`
        printErrors: false
        onLoaded: {
            if (root.customFor !== Config.theme)
                root.load(text());
        }
    }
}

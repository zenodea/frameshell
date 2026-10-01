pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.services.desktop

Singleton {
    id: root

    readonly property int warm: 4000
    readonly property int neutral: 6500

    property int temperature: 0
    property bool available: true

    readonly property bool on: temperature === warm

    function toggle(): void {
        Quickshell.execDetached(["sh", "-c", 'pgrep -x hyprsunset > /dev/null || { hyprsunset & sleep 0.3; }; hyprctl hyprsunset temperature "$0" > /dev/null', String(on ? neutral : warm)]);
        soon.restart();
    }

    Process {
        id: probe

        command: ["hyprctl", "hyprsunset", "temperature"]

        stdout: StdioCollector {
            onStreamFinished: {
                const value = parseInt(text.trim());
                root.available = !isNaN(value);
                root.temperature = root.available ? value : 0;
            }
        }
    }

    Timer {
        running: Panels.drawer
        interval: 2000
        repeat: true
        triggeredOnStart: true
        onTriggered: probe.running = true
    }

    Timer {
        id: soon

        interval: 500
        onTriggered: probe.running = true
    }
}

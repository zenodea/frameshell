//@ pragma UseQApplication

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.modules.frame
import qs.modules.lock
import qs.services.config
import qs.services.desktop

ShellRoot {
    QtObject {
        Component.onCompleted: {
            Appearance.themes;
            ClipboardHistory.available;
            Notifs.count;
        }
    }

    IpcHandler {
        target: "shell"

        function drawer(tab: string): void {
            Panels.toggleDrawer(tab);
        }

        function controls(): void {
            Panels.toggleControls("controls");
        }

        function agent(): void {
            Panels.toggleControls("agent");
        }

        function launcher(mode: string): void {
            Panels.openLauncher(mode);
        }

        function close(): void {
            Panels.close();
        }

        function screenshot(mode: string): void {
            Screenshot.take(mode);
        }

        function lock(): void {
            Lock.lock();
        }

        function theme(name: string): void {
            Config.set("theme", name);
        }

        function font(family: string): void {
            Config.set("font", family);
        }
    }

    WlSessionLock {
        locked: Lock.locked

        LockSurface {}
    }

    Variants {
        model: Quickshell.screens

        Scope {
            id: scope

            required property ShellScreen modelData

            Exclusions {
                screen: scope.modelData
            }

            Frame {
                modelData: scope.modelData
            }
        }
    }
}

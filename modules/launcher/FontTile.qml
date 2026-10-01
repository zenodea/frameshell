import QtQuick
import qs.style
import qs.widgets

Rectangle {
    id: root

    required property var item
    required property bool selected
    required property bool hovered

    function span(c: color, s: string): string {
        return `<font color="${c}">${s}</font>`;
    }

    color: selected ? Theme.alpha(Theme.accent, 0.1) : hovered ? Theme.alpha(Theme.fg, 0.08) : Theme.alpha(Theme.fg, 0.045)

    Behavior on color {
        ColorAnimation {
            duration: Metrics.shortAnim
        }
    }

    Column {
        x: 14
        y: 10
        width: parent.width - 28
        spacing: 6

        Text {
            width: parent.width - 24
            text: root.item.name
            color: root.selected ? Theme.accent : Theme.fgBright
            font.family: root.item.name
            font.pixelSize: 16
            elide: Text.ElideRight
            renderType: Text.NativeRendering
        }

        Text {
            width: parent.width
            textFormat: Text.StyledText
            text: [`${root.span(Theme.purple, "const")} ${root.span(Theme.blue, "ok")} = (x) => x != ${root.span(Theme.orange, "0")};`, `0O oO l1I| {}[] -> => ===`].join("<br>")
            color: Theme.fg
            font.family: root.item.name
            font.pixelSize: 12
            lineHeight: 1.2
            elide: Text.ElideRight
            renderType: Text.NativeRendering
        }
    }

    Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 6
        width: 20
        height: 20
        color: Theme.accent
        visible: root.item.current ?? false

        Icon {
            anchors.centerIn: parent
            text: "󰄬"
            color: Theme.bg
            font.pixelSize: 13
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.width: 2
        border.color: Theme.accent
        visible: root.selected
    }
}

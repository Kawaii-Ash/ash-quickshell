import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Item {
    id: root
    implicitHeight: contentRow.implicitHeight
    implicitWidth: contentRow.implicitWidth

    property real usagePercent: 0
    property real usedGiB: 0
    property real totalGiB: 0

    FileView {
        id: meminfo
        path: "/proc/meminfo"
        preload: false
        watchChanges: false
    }

    function parseValue(key, lines) {
        const line = lines.find(l => l.startsWith(key))
        if (!line) return undefined
        const parts = line.trim().split(/\s+/)
        // parts: ["Key:", "value", "kB"]
        return parts.length >= 2 ? Number(parts[1]) : undefined
    }

    function sample() {
        meminfo.reload()
        const lines = meminfo.text().trim().split("\n")
        if (lines.length === 0) return

        const totalKb = parseValue("MemTotal:", lines)
        const availKb = parseValue("MemAvailable:", lines)
        if (!totalKb || !availKb) return

        const usedKb = Math.max(0, totalKb - availKb)
        totalGiB = totalKb / 1024 / 1024
        usedGiB = usedKb / 1024 / 1024
        usagePercent = (usedKb / totalKb) * 100
    }

    Timer {
        interval: 2000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: sample()
    }

    Row {
        id: contentRow
        spacing: 6

        FontAwesome {
            unicode: "\uf538" // server-stack/memory chip
            size: 20
            color: "#bbb"
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: usedGiB.toFixed(1) + "/" + totalGiB.toFixed(1) + "G"
            color: "#bbb"
            font.family: "Dudu Calligraphy"
            font.pixelSize: 22
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: usagePercent.toFixed(0) + "%"
            color: "#888"
            font.family: "Dudu Calligraphy"
            font.pixelSize: 18
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}

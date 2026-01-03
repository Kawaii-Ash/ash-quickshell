import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Item {
    id: root
    property string filesystemPath: "/"

    property real totalGiB: 0
    property real usedGiB: 0
    property real usagePercent: 0
    property real decimals: 0

    implicitHeight: contentRow.implicitHeight
    implicitWidth: contentRow.implicitWidth

    function formatGiB(bytes) {
        return (bytes / 1024 / 1024 / 1024).toFixed(decimals)
    }

    function parseDf(output) {
        const lines = output.trim().split("\n")
        if (lines.length < 2) return

        const parts = lines[1].trim().split(/\s+/)
        if (parts.length < 3) return

        const totalBytes = Number(parts[1])
        const usedBytes = Number(parts[2])
        if (!totalBytes || totalBytes <= 0) return

        totalGiB = formatGiB(totalBytes)
        usedGiB = formatGiB(usedBytes)
        usagePercent = (usedBytes / totalBytes * 100).toFixed(decimals)
    }

    Process {
        id: dfProc
        command: [ "df", "-B1", filesystemPath ]
        stdout: StdioCollector {
            onStreamFinished: parseDf(this.text)
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: dfProc.running = true
    }

    Row {
        id: contentRow
        spacing: 6

        FontAwesome {
            unicode: "\uf0a0" // database / drive
            size: 20
            color: "#bbb"
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: usedGiB + "/" + totalGiB + "G"
            color: "#bbb"
            font.family: "Dudu Calligraphy"
            font.pixelSize: 22
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: usagePercent + "%"
            color: "#888"
            font.family: "Dudu Calligraphy"
            font.pixelSize: 18
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}

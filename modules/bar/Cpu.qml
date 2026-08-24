import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Item {
    id: root
    required property string fontFamily
    implicitHeight: contentRow.implicitHeight
    implicitWidth: contentRow.implicitWidth

    // tracked cpu times from previous sample
    property var _previous: null
    property real usagePercent: 0
    // optional thermal sensor path; override if your system uses a different zone/hwmon
    property string temperaturePath: "/sys/class/thermal/thermal_zone0/temp"
    property real temperatureC: NaN
    readonly property string usageTemplate: "100%"
    readonly property string tempTemplate: "99\u00b0C"

    FileView {
        id: statFile
        path: "/proc/stat"
        preload: false
        watchChanges: false
    }

    FileView {
        id: tempFile
        path: temperaturePath
        preload: false
        watchChanges: false
    }

    FontMetrics {
        id: usageMetrics
        font.family: root.fontFamily
        font.pixelSize: 22
    }

    FontMetrics {
        id: tempMetrics
        font.family: root.fontFamily
        font.pixelSize: 18
    }

    function sample() {
        statFile.reload()
        const lines = statFile.text().trim().split("\n")
        if (lines.length === 0) return

        const parts = lines[0].trim().split(/\s+/)
        if (parts[0] !== "cpu" || parts.length < 8) return

        const fields = parts.slice(1).map(x => Number(x))
        const idle = fields[3] + fields[4] // idle + iowait
        const total = fields.reduce((sum, v) => sum + v, 0)

        if (_previous) {
            const totalDelta = total - _previous.total
            const idleDelta = idle - _previous.idle
            if (totalDelta > 0) {
                const busy = Math.max(0, totalDelta - idleDelta)
                usagePercent = Math.min(100, (busy / totalDelta) * 100)
            }
        }

        _previous = { total, idle }

        // temperature (millideg C if > 200, else deg C)
        tempFile.reload()
        const tRaw = tempFile.text().trim()
        if (tRaw.length > 0) {
            const tVal = Number(tRaw)
            if (!isNaN(tVal)) {
                temperatureC = (tVal > 200 ? tVal / 1000 : tVal).toFixed(0)
            }
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: sample()
    }

    Row {
        id: contentRow
        spacing: 6

        FontAwesome {
            unicode: "\uf2db" // microchip
            size: 20
            color: "#bbb"
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: usagePercent.toFixed(0) + "%"
            color: "#bbb"
            font.family: root.fontFamily
            font.pixelSize: 22
            anchors.verticalCenter: parent.verticalCenter
            width: usageMetrics.boundingRect(usageTemplate).width
        }

        Text {
            text: isNaN(temperatureC) ? "--°C" : temperatureC + "\u00b0C"
            color: "#888"
            font.family: root.fontFamily
            font.pixelSize: 18
            anchors.verticalCenter: parent.verticalCenter
            width: tempMetrics.boundingRect(tempTemplate).width
        }
    }
}

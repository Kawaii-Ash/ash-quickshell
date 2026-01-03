import QtQuick
import Quickshell.Io

// Samples /proc/net/dev and exposes rx/tx rates plus the chosen interface.
Item {
    id: root

    // optional: override auto-picked interface
    property string interfaceName: ""
    property string activeInterface: ""
    property real rxRateBps: 0
    property real txRateBps: 0

    readonly property string rateTemplate: "↓ 999.9 MiB/s"

    FileView {
        id: netdev
        path: "/proc/net/dev"
        preload: false
        watchChanges: false
    }

    property var _previous: null

    function parseLines() {
        const lines = netdev.text().trim().split("\n").slice(2) // skip headers

        for (const line of lines) {
            const cleaned = line.trim().replace(/\s+/g, " ")
            const parts = cleaned.split(" ")
            if (parts.length < 17) continue

            // parts[0] is "iface:"
            const iface = parts[0].replace(":", "")
            const rxBytes = Number(parts[1])
            const txBytes = Number(parts[9])
            if (isNaN(rxBytes) || isNaN(txBytes)) continue

            if (interfaceName) {
                if (iface === interfaceName) {
                    return { iface, rxBytes, txBytes }
                }
            } else if (iface !== "lo") {
                return { iface, rxBytes, txBytes }
            }
        }
    }

    function sample() {
        netdev.reload()
        const entry = parseLines()
        if (!entry) {
            activeInterface = ""
            rxRateBps = 0
            txRateBps = 0
            _previous = null
            return
        }

        const now = Date.now()
        if (_previous && _previous.iface === entry.iface) {
            const dt = (now - _previous.time) / 1000
            if (dt > 0) {
                rxRateBps = Math.max(0, (entry.rxBytes - _previous.rxBytes) / dt)
                txRateBps = Math.max(0, (entry.txBytes - _previous.txBytes) / dt)
            }
        }

        activeInterface = entry.iface
        _previous = { iface: entry.iface, rxBytes: entry.rxBytes, txBytes: entry.txBytes, time: now }
    }

    function formatRateParts(bytesPerSec) {
        const units = ["KiB/s", "MiB/s", "GiB/s"]

        // Always show at least KiB, rounding small non-zero values up to 0.1 KiB/s
        // so that a single byte still appears as 0.1 KiB/s instead of 0.0.
        if (bytesPerSec <= 0) {
            return { value: "0.0", unit: units[0] }
        }

        let value = Math.max(0.1, bytesPerSec / 1024)
        let idx = 0
        while (value >= 1024 && idx < units.length - 1) {
            value /= 1024
            idx++
        }
        const digits = 1
        return { value: value.toFixed(digits), unit: units[idx] }
    }

    function formatRate(bytesPerSec) {
        const parts = formatRateParts(bytesPerSec)
        return parts.value + " " + parts.unit
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: sample()
    }
}

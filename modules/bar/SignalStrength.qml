import QtQuick
import Quickshell.Io

// Tracks link state and wifi quality for a given interface.
Item {
    id: root

    property string activeInterface: ""
    property bool linkUp: false
    property bool isWireless: false
    property real signalQuality: NaN // raw quality from /proc/net/wireless (0-70)

    // computed icon to display
    readonly property string netIcon: {
        if (!activeInterface || !linkUp) return "\uf05e" // ban / offline

        if (isWireless && !isNaN(signalQuality)) {
            //const pct = Math.max(0, Math.min(100, (signalQuality / 70) * 100))
            //if (pct >= 70) return "\uf1eb" // wifi strong
            //if (pct >= 40) return "\uf012" // signal bars medium
            // Weak

            return "\uf1eb" // warning for weak
        }

        return "\uf012" // network-wired
    }

    FileView {
        id: wirelessInfo
        path: "/proc/net/wireless"
        preload: false
        watchChanges: false
    }

    FileView {
        id: carrierFile
        path: activeInterface ? "/sys/class/net/" + activeInterface + "/carrier" : null
        preload: false
        watchChanges: false
    }

    FileView {
        id: operstateFile
        path: activeInterface ? "/sys/class/net/" + activeInterface + "/operstate" : null
        preload: false
        watchChanges: false
    }

    function readWirelessQuality(iface) {
        wirelessInfo.reload()
        const lines = wirelessInfo.text().trim().split("\n").slice(2) // skip headers
        for (const line of lines) {
            const cleaned = line.trim().replace(/\s+/g, " ")
            const parts = cleaned.split(" ")
            if (parts.length < 4) continue
            const name = parts[0].replace(":", "")

            if (name === iface) return Number(parts[2])
        }
        return NaN
    }

    function updateLinkState() {
        if (!activeInterface) {
            linkUp = false
            isWireless = false
            signalQuality = NaN
            return
        }

        carrierFile.reload()
        operstateFile.reload()

        const carrierVal = Number(carrierFile.text().trim())
        const oper = operstateFile.text().trim().toLowerCase()
        linkUp = carrierVal === 1 || oper === "up" || oper === "unknown" || oper === "dormant"

        const quality = readWirelessQuality(activeInterface)
        isWireless = !isNaN(quality)
        signalQuality = quality
    }

    onActiveInterfaceChanged: updateLinkState()

    Timer {
        interval: 2000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: updateLinkState()
    }
}

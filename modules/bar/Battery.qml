import QtQuick
import Quickshell.Io

Item {
    id: root
    required property string fontFamily
    property string batteryPath: "/sys/class/power_supply/BAT"
    property int percent: -1
    property string status: ""
    property bool available: false

    implicitHeight: contentRow.implicitHeight
    implicitWidth: contentRow.implicitWidth
    FileView {
        id: capacityFile
        path: batteryPath + "/capacity"
        preload: false
        watchChanges: false
    }

    FileView {
        id: statusFile
        path: batteryPath + "/status"
        preload: false
        watchChanges: false
    }

    function sample() {
        capacityFile.reload()
        statusFile.reload()

        const capRaw = capacityFile.text().trim()
        const statusRaw = statusFile.text().trim()
        if (!capRaw) {
            available = false
            percent = -1
            status = ""
            return
        }

        const value = Number(capRaw)
        if (isNaN(value)) {
            available = false
            percent = -1
            status = statusRaw
            return
        }

        percent = Math.max(0, Math.min(100, Math.round(value)))
        status = statusRaw
        available = true
    }

    Timer {
        interval: 5000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: sample()
    }

    readonly property bool isCharging: status === "Charging"
    readonly property bool isFull: status === "Full"
    readonly property string batteryIcon: {
        if (!available) return "\uf244" // battery-empty
        if (isCharging) return "\uf0e7" // battery-bolt
        if (isFull) return "\uf240" // battery-full
        if (percent >= 90) return "\uf240"
        if (percent >= 65) return "\uf241" // battery-three-quarters
        if (percent >= 40) return "\uf242" // battery-half
        if (percent >= 15) return "\uf243" // battery-quarter
        return "\uf244"
    }
    readonly property string percentText: available ? (percent + "%") : "--%"

    Row {
        id: contentRow
        spacing: 6

        FontAwesome {
            unicode: batteryIcon
            size: 20
            color: "#bbb"
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: percentText
            color: "#bbb"
            font.family: root.fontFamily
            font.pixelSize: 22
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}

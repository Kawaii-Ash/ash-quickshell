import QtQuick
import QtQuick.Layouts

Item {
    id: root
    required property string fontFamily

    // optional: override auto-picked interface
    property string interfaceName: ""

    // expose data from submodules for potential external use
    property alias activeInterface: stats.activeInterface
    property alias rxRateBps: stats.rxRateBps
    property alias txRateBps: stats.txRateBps
    property alias linkUp: signal.linkUp
    property alias isWireless: signal.isWireless
    property alias signalQuality: signal.signalQuality

    implicitHeight: contentRow.implicitHeight
    implicitWidth: contentRow.implicitWidth

    FontMetrics {
        id: rateMetrics
        font.family: root.fontFamily
        font.pixelSize: 18
    }

    NetworkStats {
        id: stats
        interfaceName: root.interfaceName
    }

    SignalStrength {
        id: signal
        activeInterface: stats.activeInterface
    }

    Row {
        id: contentRow

        FontAwesome {
            unicode: signal.netIcon
            size: 20
            color: "#bbb"
            anchors.verticalCenter: parent.verticalCenter
        }
        ColumnLayout {
            spacing: 0

            RowLayout {
                id: txRow
                Layout.minimumWidth: rateMetrics.boundingRect(stats.rateTemplate).width
                Layout.alignment: Qt.AlignLeft
                spacing: 4
                property var rate: stats.formatRateParts(stats.txRateBps)

                Text {
                    text: "↑ " + txRow.rate.value
                    color: "#bbb"
                    font.family: root.fontFamily
                    font.pixelSize: 18
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignLeft
                }

                Text {
                    text: txRow.rate.unit
                    color: "#bbb"
                    font.family: root.fontFamily
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignRight
                }
            }

            RowLayout {
                id: rxRow
                Layout.minimumWidth: rateMetrics.boundingRect(stats.rateTemplate).width
                Layout.alignment: Qt.AlignLeft
                spacing: 4
                property var rate: stats.formatRateParts(stats.rxRateBps)

                Text {
                    text: "↓ " + rxRow.rate.value
                    color: "#bbb"
                    font.family: root.fontFamily
                    font.pixelSize: 18
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignLeft
                }

                Text {
                    text: rxRow.rate.unit
                    color: "#bbb"
                    font.family: root.fontFamily
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignRight
                }
            }
        }
    }
}

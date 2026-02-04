import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    implicitWidth: contentRow.implicitWidth
    implicitHeight: contentRow.implicitHeight

    FontMetrics {
        id: rateMetrics
        font.family: "dudu calligraphy"
        font.pixelSize: 21
    }

    readonly property string rateTemplate: "100%"

    // Bind the default sink so PipeWire listeners are installed; without this
    // ready/volume signals never arrive and `ready` stays false.
    PwObjectTracker {
        id: sinkBinder
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
    }

    function getVolume(device) {
        if (!device || !device.ready || !device.audio) return 0
        return Math.round(device.audio.volume * 100)
    }

    function isMuted(device) {
        return device && device.ready && device.audio ? device.audio.muted : false
    }

    readonly property bool sinkIsMuted: {
        return isMuted(Pipewire.defaultAudioSink)
    }

    readonly property bool sourceIsMuted: {
        return isMuted(Pipewire.defaultAudioSource)
    }

    readonly property int sourceVolume: {
        return getVolume(Pipewire.defaultAudioSource)
    }

    readonly property int volumeValue: {
        return getVolume(Pipewire.defaultAudioSink)
    }

    readonly property string volumeIcon: {
        const sink = Pipewire.defaultAudioSink
        if (!sink || !sink.ready || !sink.audio) {
            return "\uf026" // volume-off when unavailable
        }
        if (sinkIsMuted) return "\uf6a9" // muted
        if (volumeValue === 0) return "\uf026" // volume-off
        if (volumeValue < 50) return "\uf027" // volume-low
        return "\uf028" // volume-high
    }

    readonly property string micIcon: {
        const source = Pipewire.defaultAudioSource
        if (!source || !source.ready || !source.audio) {
            return "\uf131"
        }
        if (sourceIsMuted) return "\uf131"
        return "\uf130"
    }

    Column {
        id: contentRow
        RowLayout {
            spacing: 5

            FontAwesome {
                unicode: volumeIcon
                color: "#ccc"
                size: 18
            }

            Text {
                text: volumeValue + "%"
                font.family: "dudu calligraphy"
                font.pixelSize: 21
                color: "#ccc"
                horizontalAlignment: Text.AlignRight
                Layout.minimumWidth: rateMetrics.boundingRect(rateTemplate).width
                Layout.preferredWidth: rateMetrics.boundingRect(rateTemplate).width
                Layout.maximumWidth: rateMetrics.boundingRect(rateTemplate).width
            }
        }
        RowLayout {
            spacing: 5

            FontAwesome {
                unicode: micIcon
                color: "#ccc"
                size: 18
            }
            Text {
                text: getVolume(Pipewire.defaultAudioSource) + "%"
                font.family: "dudu calligraphy"
                font.pixelSize: 21
                color: "#ccc"
                horizontalAlignment: Text.AlignRight
                Layout.minimumWidth: rateMetrics.boundingRect(rateTemplate).width
                Layout.preferredWidth: rateMetrics.boundingRect(rateTemplate).width
                Layout.maximumWidth: rateMetrics.boundingRect(rateTemplate).width
            }
        }
    }
}

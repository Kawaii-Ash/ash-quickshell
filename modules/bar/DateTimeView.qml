import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    implicitWidth: contentRow.implicitWidth
    implicitHeight: contentRow.implicitHeight

    property int fontSize: 21

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
    Column {
        id: contentRow
        // Make both lines share the same width so centering works visually
        width: Math.max(timeText.implicitWidth, dateText.implicitWidth)

        Text {
            id: timeText
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: Qt.formatDateTime(clock.date, "hh:mm")
            color: "#bbb"
            font.family: "Dudu Calligraphy"
            font.pixelSize: fontSize
        }
        Text {
            id: dateText
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: Qt.formatDateTime(clock.date, "dd/MM/yy")
            color: "#bbb"
            font.family: "Dudu Calligraphy"
            font.pixelSize: fontSize
        }
    }
}

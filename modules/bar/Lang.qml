import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root
    implicitHeight: contentRow.implicitHeight
    implicitWidth: contentRow.implicitWidth

    Row {
        id: contentRow
        spacing: 6
        FontAwesome { 
            unicode: "\uf11c"
            color: "#ccc"
            size: 21
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text: niri.current_layout
            color: "#bbb"
            font.family: "Dudu Calligraphy"
            font.pixelSize: 18
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}

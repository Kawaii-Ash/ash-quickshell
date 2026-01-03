import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root
    implicitHeight: usernameText.implicitHeight
    implicitWidth: usernameText.implicitWidth

    property string userName: Quickshell.env("USER")

    Text {
        id: usernameText
        text: userName || "?"
        color: "#bbb"
        font.family: "Dudu Calligraphy"
        font.pixelSize: 22
        Layout.alignment: Qt.AlignVCenter
    }
}

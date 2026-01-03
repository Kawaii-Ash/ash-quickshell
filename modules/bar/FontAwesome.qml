import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root
    required property string unicode
    property int size
    property string color
    implicitWidth: faIcon.contentWidth
    implicitHeight: faIcon.contentHeight
    Text {
        id: faIcon
        text: unicode
        font.family: "Font Awesome 7 Free Solid"
        font.pixelSize: size
        color: root.color
    }
}

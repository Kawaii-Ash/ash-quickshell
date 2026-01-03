import QtQuick
import QtQuick.Layouts

Item {
    id: root
    implicitWidth: list.contentWidth
    implicitHeight: (list.contentItem ? list.contentItem.childrenRect.height : 0)

    ListView {
        id: list
        anchors.fill: parent
        orientation: ListView.Horizontal
        spacing: 8
        interactive: false
        model: niri.workspaces

        delegate: Row {
            spacing: 4

            property string iconCode: nameToIcon(model.name)

            FontAwesome {
                unicode: iconCode
                size: 22
                color: model.isFocused ? "#fff" : "#888"
                visible: iconCode !== ""
            }

            Text {
                text: model.name && model.name.length ? model.name : model.index
                color: model.isFocused ? "#fff" : "#ccc"
                font.pixelSize: 22
                font.family: "Dudu Calligraphy"
                visible: iconCode === ""
            }
        }
    }

    function nameToIcon(ws_name) {
        const ws_icon = {
            main: "\uf120",
            chat: "\uf27a",
            web: "\uf0ac",
        }
        if (!ws_name)
            return ""

        return ws_icon[ws_name.toLowerCase()] || ""
    }
}

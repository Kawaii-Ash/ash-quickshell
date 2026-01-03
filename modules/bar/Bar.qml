import QtQuick
import QtQuick.Layouts
import Quickshell

PanelWindow {
    id: bar

    readonly property real border_radius: 10

    readonly property string ergo_icon: "assets/ergo.xpm"
    readonly property string liesofp_icon: "assets/lies_of_p.xpm"
    readonly property string gemini_icon: "assets/gemini.xpm"
    readonly property string bluebutterfly_icon: "assets/blue_butterfly.xpm"

    anchors {
        top: true
        left: true
        right: true
    }
    margins {
        top: 5
        left: 10
        right: 10
    }
    implicitHeight: 63
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: "#dd0f1016"
        topRightRadius: border_radius
        topLeftRadius: border_radius
        anchors.bottomMargin: 21

        // left
        RowLayout {
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: 5
            }
            Image { source: ergo_icon }
            Workspaces{}
            Image { source: ergo_icon }
        }
        // center
        RowLayout {
            anchors {
                horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
            }

            Image { source: liesofp_icon }
        }
        // right
        RowLayout {
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: 5
            }
            spacing: 7
            
            Network {}
            Volume {}
            DateTimeView {}
            Image { source: gemini_icon }
        }
    }

    // Bottom Bar
    Rectangle {
        anchors.fill: parent
        anchors.topMargin: 42
        bottomLeftRadius: border_radius
        bottomRightRadius: border_radius
        color: "#dd191b25"

        RowLayout {
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: 5
            }
            spacing: 8

            Image { source: bluebutterfly_icon }
            User {}
            Image { source: bluebutterfly_icon }
        }
        // center
        RowLayout {
            spacing: 8
            anchors {
                horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
            }

            Image { source: bluebutterfly_icon } 
            Cpu {}
            
            Image { source: bluebutterfly_icon }

            Memory {}

            Image { source: bluebutterfly_icon }
        }
        // right
        RowLayout {
            spacing: 8
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: 5
            }

            Image { source: bluebutterfly_icon }
            Lang {}
            Image { source: bluebutterfly_icon }
            Storage {}
            Image { source: bluebutterfly_icon }
        }
    }
}

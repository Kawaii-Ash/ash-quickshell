import QtQuick
import Quickshell
import Quickshell.Io
import Niri 0.1
import "./modules/bar/"
import "./modules/wallpaper/"


ShellRoot {
    id: root

    Niri {
        id: niri
        Component.onCompleted: connect()

        property var keyboard_layouts: {};
        property string current_layout: "";
        // Change background when workspace is changed
        property bool change_bg_per_workspace: false
        
        onConnected: console.log("Connected to niri")
        onErrorOccurred: function(error) {
            console.error("Error:", error)
        }
        onRawEventReceived: function(event) {
            if (change_bg_per_workspace && event.WorkspaceActivated) {
                wallpaper && wallpaper.item && wallpaper.item.switchWallpaper()
            } else if (event.KeyboardLayoutsChanged) {
                const kl_event = event.KeyboardLayoutsChanged.keyboard_layouts
                keyboard_layouts = kl_event.names
                current_layout = keyboard_layouts[kl_event.current_idx]
            } else if (event.KeyboardLayoutSwitched) {
                const new_idx = event.KeyboardLayoutSwitched.idx
                current_layout = keyboard_layouts[new_idx]
            }
        }
    }

    LazyLoader{ id: bar; active: true; component: Bar{} }
    LazyLoader{ id: wallpaper; active: true; component: Wallpaper{} }

    IpcHandler {
        target: "ash-quickshell"

        function toggleBar(): void { bar.active = !bar.active; }
        function changeWallpaper(): void { wallpaper && wallpaper.item && wallpaper.item.switchWallpaper() }
        function changeBackdrop(): void { wallpaper && wallpaper.item && wallpaper.item.switchBackdrop() }
    }
}

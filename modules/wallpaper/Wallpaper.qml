import QtQuick
import Qt.labs.folderlistmodel
import Quickshell.Io

Item {
    id: root

    // Transition duration passed to `awww -t`
    property string transition_type: "grow"
    property real lastChanged: 0

    readonly property string workspaceFolder: Qt.resolvedUrl("assets/workspace")
    readonly property string backdropFolder: Qt.resolvedUrl("assets/backdrop")

    FolderListModel {
        id: workspaceImages
        folder: workspaceFolder
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.bmp", "*.gif"]
        showDirs: false
        onStatusChanged: maybeStart()
        onCountChanged: maybeStart()
    }

    FolderListModel {
        id: backdropImages
        folder: backdropFolder
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.bmp", "*.gif"]
        showDirs: false
        onStatusChanged: maybeStart()
        onCountChanged: maybeStart()
    }

    // Remember the last images used so we can avoid immediate repeats.

    function pickDifferentIndex(model, lastIdx) {
      const n = model.count
      if (n === 0) return -1
      if (n === 1) return 0
      if (n === 2 && lastIdx >= 0 && lastIdx <= 1) return 1 >> lastIdx;

      // pick in 0..n-2, then skip over lastIdx
      let idx = ~~(Math.random() * (n - 1))
      if (idx >= lastIdx && lastIdx !== -1)
          idx += 1
      return idx
    }

    property int _lastBackdropIdx: -1

    function switchBackdrop() {
        const idx = pickDifferentIndex(backdropImages, _lastBackdropIdx)
        if (idx < 0) {
            console.warn("No backdrop wallpaper files found")
            return
        }

        const path = backdropImages.get(idx, "filePath")
        backdropProc.command = ["awww", "img", "-n", "backdrop", "-t", transition_type, path]
        backdropProc.running = true
        _lastBackdropIdx = idx
    }

    property int _lastWorkspaceIdx: -1

    function switchWallpaper() {
        const current_time = Date.now()
        if (current_time - lastChanged < 1000) return;
        lastChanged = current_time

        const idx = pickDifferentIndex(workspaceImages, _lastWorkspaceIdx)
        if (idx < 0) {
            console.warn("No workspace wallpaper files found")
            return
        }

        const path = workspaceImages.get(idx, "filePath")
        workspaceProc.command = ["awww", "img", "--transition-duration", 0.8, "-t", transition_type, path]
        workspaceProc.running = true
        _lastWorkspaceIdx = idx
    }

    property bool _initialized: false

    function maybeStart() {
        if (_initialized) return
        const workspaceReady = workspaceImages.status === FolderListModel.Ready
        const backdropReady = backdropImages.status === FolderListModel.Ready
        if (workspaceReady && backdropReady) {
            _initialized = true
            switchWallpaper()
            switchBackdrop()
            changeTimer.running = true
        }
    }

    Component.onCompleted: maybeStart()

    Timer {
        id: changeTimer
        interval: 600_000 // 10 mins
        repeat: true
        running: false
        triggeredOnStart: false
        onTriggered: {
            switchWallpaper()
            switchBackdrop()
        }
    }

    Process {
        id: workspaceProc
    }

    Process {
        id: backdropProc
    }
}

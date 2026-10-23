import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "io.github.juliolinarez.smart-workspaces"

  // A bar surface exists per monitor, so each instance can tell which screen
  // the person is looking at. Wayland output names (eDP-2, HDMI-A-1) are the
  // same names Hyprland reports for workspaces' monitors.
  readonly property var ownScreen: root.QsWindow.window ? root.QsWindow.window.screen : null
  readonly property string ownMonitor: ownScreen ? String(ownScreen.name || "") : ""

  // The ids shown in the bar: the usual five, plus any opened above 5.
  // Reading Hyprland.workspaces.values inside the binding keeps this list
  // updating as workspaces are created or destroyed.
  readonly property var workspaceIds: {
    var ids = [1, 2, 3, 4, 5]
    var values = Hyprland.workspaces.values

    for (var i = 0; i < values.length; i++) {
      var id = values[i].id
      if (id > 0 && id <= 10 && ids.indexOf(id) === -1) ids.push(id)
    }

    ids.sort(function(left, right) { return left - right })
    return ids
  }

  function focusWorkspace(id) {
    if (!root.bar) return
    root.bar.run("hyprctl dispatch " + Util.shellQuote("hl.dsp.focus({ workspace = \"" + id + "\" })"))
  }

  readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.5)

  // The number inside the filled focus box is painted with the bar background
  // colour, so it reads as a hole cut out of the box. Forced opaque: the bar
  // background can carry alpha, which would tint the digit instead.
  readonly property color focusInk: {
    var c = root.bar ? root.bar.background : Color.background
    return Qt.rgba(c.r, c.g, c.b, 1)
  }

  implicitWidth: grid.implicitWidth + trailingGap
  implicitHeight: grid.implicitHeight

  GridLayout {
    id: grid
    anchors.fill: parent
    anchors.rightMargin: root.trailingGap
    columns: root.vertical ? 1 : root.workspaceIds.length
    columnSpacing: root.vertical ? 0 : Style.space(1)
    rowSpacing: root.vertical ? Style.space(2) : 0

    Repeater {
      model: root.workspaceIds

      delegate: Item {
        id: cell
        required property int modelData

        // The lookup lives in the binding (instead of a helper function) so
        // the cell tracks the workspaces model itself.
        readonly property var workspace: {
          var values = Hyprland.workspaces.values
          for (var i = 0; i < values.length; i++) {
            if (values[i].id === cell.modelData) return values[i]
          }
          return null
        }

        readonly property bool occupied: workspace !== null && workspace.toplevels.values.length > 0
        // The focused workspace is only marked on the bar of the monitor that
        // is showing it; the other screen has no business highlighting it.
        readonly property bool focused: Hyprland.focusedWorkspace !== null &&
          Hyprland.focusedWorkspace.id === cell.modelData &&
          Hyprland.focusedMonitor !== null &&
          String(Hyprland.focusedMonitor.name || "") === root.ownMonitor
        readonly property string monitorName: workspace && workspace.monitor ? String(workspace.monitor.name || "") : ""
        // Workspaces that live on the screen this bar is drawn on. They are the
        // ones drawn bold, so a glance at either bar tells the two sets apart.
        readonly property bool mine: root.ownMonitor !== "" && cell.monitorName === root.ownMonitor

        implicitWidth: root.vertical ? root.barSize : Style.space(20)
        implicitHeight: root.barSize

        // The Omarchy focus indicator, but carrying the workspace number:
        // a filled rounded square with the digit knocked out of it.
        Rectangle {
          visible: cell.focused

          width: Math.max(16, Style.spaceReal(7.5))
          height: width
          radius: Style.spaceReal(2)

          color: root.bar ? root.bar.foreground : Color.foreground

          anchors.centerIn: parent
          anchors.verticalCenterOffset: -Style.spaceReal(0.6)
        }

        // WidgetButton keeps its label at a fixed weight, so the number is
        // drawn here to be able to bold the workspaces of this monitor.
        Text {
          anchors.centerIn: parent
          text: cell.modelData === 10 ? "0" : String(cell.modelData)
          renderType: Text.NativeRendering
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.body
          font.bold: cell.mine || cell.focused
          color: cell.focused
            ? root.focusInk
            : (root.bar ? root.bar.foreground : Color.foreground)
          // Only the workspaces of this screen get full strength. Anything
          // that lives on the other monitor stays dim: its weight and badge
          // say where it is and whether it has windows, nothing else.
          opacity: cell.mine ? (cell.occupied || cell.focused ? 1 : 0.8) : 0.4

          Behavior on color {
            enabled: !root.bar || root.bar.foregroundAnimationEnabled
            ColorAnimation { duration: 160 }
          }
        }

        // Badge: a small dot under every workspace that has windows, on either
        // screen. Kept separate from the bold weight so the two things never
        // get confused.
        Rectangle {
          visible: cell.occupied

          width: Math.max(3, Style.spaceReal(1.2))
          height: width
          radius: width / 2

          color: root.bar ? root.bar.foreground : Color.foreground
          opacity: cell.mine ? 0.75 : 0.4

          anchors.horizontalCenter: parent.horizontalCenter
          anchors.bottom: parent.bottom
          anchors.bottomMargin: Style.spaceReal(1.2)
        }

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: root.focusWorkspace(cell.modelData)
        }
      }
    }
  }
}

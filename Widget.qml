import QtQuick

Item {
  id: root
  property var bar
  property string moduleName
  property var settings

  implicitWidth: 34
  implicitHeight: bar ? bar.barSize : 26

  Rectangle {
    anchors.centerIn: parent
    width: 28
    height: 24
    radius: 8
    color: mouse.containsMouse ? Qt.rgba(1,1,1,0.10) : "transparent"

    Text {
      anchors.centerIn: parent
      text: "◉"
      color: bar ? bar.foreground : "white"
      font.pixelSize: 14
      font.weight: Font.DemiBold
    }
  }

  MouseArea {
    id: mouse
    anchors.fill: parent
    hoverEnabled: true
    onEntered: if (bar) bar.showTooltip(root, "OmaVision · inspect your machine")
    onExited: if (bar) bar.hideTooltip(root)
    onClicked: if (bar) bar.run("omarchy-shell shell toggle louistarwars.omavision '{}'")
  }
}

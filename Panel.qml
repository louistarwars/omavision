import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

Item {
  id: root

  property bool opened: false
  property string snapshotText: "{}"
  property var data: ({})
  property int selectedTab: 0
  property string selectedPid: ""
  property string scriptPath: ""

  function open(payloadJson) {
    opened = true
    refresh.running = true
  }

  function close() {
    opened = false
  }

  function toggle() {
    opened = !opened
    if (opened) refresh.running = true
  }

  Component.onCompleted: {
    scriptPath = manifest.__sourceDir + "/scripts/snapshot.sh"
  }

  Timer {
    id: refresh
    interval: 1200
    repeat: true
    running: root.opened
    onTriggered: snapshot.running = true
  }

  Process {
    id: snapshot
    command: ["bash", root.scriptPath]
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          root.snapshotText = text
          root.data = JSON.parse(text)
        } catch (e) {
          console.warn("OmaVision: invalid snapshot", e)
        }
      }
    }
  }

  PanelWindow {
    id: window
    visible: root.opened
    implicitWidth: Math.min(1500, screen ? screen.width - 80 : 1500)
    implicitHeight: Math.min(920, screen ? screen.height - 80 : 920)
    color: "transparent"
    WlrLayershell.namespace: "omavision"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    anchors {
      top: true
      bottom: true
      left: true
      right: true
    }

    Rectangle {
      anchors.fill: parent
      anchors.margins: 22
      radius: 22
      color: Qt.rgba(0.035, 0.04, 0.055, 0.97)
      border.width: 1
      border.color: Qt.rgba(1,1,1,0.11)

      Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: "transparent"
        border.width: 1
        border.color: Qt.rgba(0.35,0.8,1,0.10)
      }

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: 22
        spacing: 16

        RowLayout {
          Layout.fillWidth: true
          Layout.preferredHeight: 58

          ColumnLayout {
            spacing: 2
            Layout.fillWidth: true
            Text {
              text: "OMAVISION"
              color: "white"
              font.pixelSize: 25
              font.weight: Font.Bold
            }
            Text {
              text: "LIVE SYSTEM MAP  ·  " + (root.data.host || "your machine")
              color: Qt.rgba(1,1,1,0.48)
              font.pixelSize: 12
              font.letterSpacing: 1.2
            }
          }

          Repeater {
            model: [
              {label:"OVERVIEW", icon:"⌘"},
              {label:"PROCESSES", icon:"◉"},
              {label:"WINDOWS", icon:"▣"}
            ]
            delegate: Rectangle {
              Layout.preferredWidth: 115
              Layout.preferredHeight: 34
              radius: 10
              color: index === root.selectedTab ? Qt.rgba(0.2,0.65,1,0.18) : Qt.rgba(1,1,1,0.045)
              border.width: 1
              border.color: index === root.selectedTab ? Qt.rgba(0.3,0.75,1,0.35) : "transparent"
              Text {
                anchors.centerIn: parent
                text: modelData.icon + "  " + modelData.label
                color: index === root.selectedTab ? "white" : Qt.rgba(1,1,1,0.56)
                font.pixelSize: 10
                font.weight: Font.DemiBold
              }
              MouseArea { anchors.fill: parent; onClicked: root.selectedTab = index }
            }
          }

          Rectangle {
            Layout.preferredWidth: 38
            Layout.preferredHeight: 38
            radius: 12
            color: Qt.rgba(1,1,1,0.05)
            Text { anchors.centerIn: parent; text: "×"; color: Qt.rgba(1,1,1,0.68); font.pixelSize: 22 }
            MouseArea { anchors.fill: parent; onClicked: root.close() }
          }
        }

        StackLayout {
          id: pages
          Layout.fillWidth: true
          Layout.fillHeight: true
          currentIndex: root.selectedTab

          // OVERVIEW
          Item {
            ColumnLayout {
              anchors.fill: parent
              spacing: 14

              RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                spacing: 12
                Repeater {
                  model: [
                    {title:"CPU", value:(root.data.cpu || 0)+"%", sub:"system load"},
                    {title:"MEMORY", value:(root.data.memory?.pct || 0)+"%", sub:(root.data.memory?.usedMb || 0)+" MB used"},
                    {title:"SOCKETS", value:(root.data.network?.tcpSockets || 0), sub:"TCP endpoints"},
                    {title:"UPTIME", value:Math.floor((root.data.uptime || 0)/3600)+"h", sub:"kernel "+(root.data.kernel || "?")}
                  ]
                  delegate: Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 16
                    color: Qt.rgba(1,1,1,0.045)
                    border.width: 1
                    border.color: Qt.rgba(1,1,1,0.07)
                    ColumnLayout {
                      anchors.fill: parent; anchors.margins: 15; spacing: 4
                      Text { text: modelData.title; color: Qt.rgba(1,1,1,0.45); font.pixelSize: 10; font.weight: Font.DemiBold }
                      Text { text: modelData.value; color: "white"; font.pixelSize: 28; font.weight: Font.Bold; Layout.fillWidth: true }
                      Text { text: modelData.sub; color: Qt.rgba(1,1,1,0.4); font.pixelSize: 10 }
                    }
                  }
                }
              }

              RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 14

                Rectangle {
                  Layout.fillWidth: true; Layout.fillHeight: true
                  radius: 18; color: Qt.rgba(1,1,1,0.035); border.width: 1; border.color: Qt.rgba(1,1,1,0.06)
                  ColumnLayout {
                    anchors.fill: parent; anchors.margins: 16; spacing: 10
                    Text { text: "SYSTEM CONSTELLATION"; color: "white"; font.pixelSize: 12; font.weight: Font.Bold }
                    Text { text: "Workspaces → windows → processes"; color: Qt.rgba(1,1,1,0.4); font.pixelSize: 10 }
                    Item {
                      Layout.fillWidth: true; Layout.fillHeight: true
                      Rectangle { anchors.centerIn: parent; width: 150; height: 150; radius: 75; color: Qt.rgba(0.15,0.55,0.9,0.11); border.width: 1; border.color: Qt.rgba(0.3,0.75,1,0.3) }
                      Repeater {
                        model: Math.min((root.data.windows || []).length, 10)
                        delegate: Rectangle {
                          width: 13; height: 13; radius: 6.5
                          property real a: (index / Math.max(1, Math.min((root.data.windows || []).length,10))) * Math.PI * 2
                          property real r: 110
                          x: parent.width/2 + Math.cos(a)*r - width/2
                          y: parent.height/2 + Math.sin(a)*r - height/2
                          color: index % 2 === 0 ? Qt.rgba(0.3,0.8,1,0.9) : Qt.rgba(0.65,0.4,1,0.9)
                        }
                      }
                    }
                  }
                }

                Rectangle {
                  Layout.preferredWidth: 380; Layout.fillHeight: true
                  radius: 18; color: Qt.rgba(1,1,1,0.035); border.width: 1; border.color: Qt.rgba(1,1,1,0.06)
                  ColumnLayout {
                    anchors.fill: parent; anchors.margins: 16; spacing: 10
                    Text { text: "TOP ACTIVITY"; color: "white"; font.pixelSize: 12; font.weight: Font.Bold }
                    Repeater {
                      model: (root.data.processes || []).slice(0,7)
                      delegate: RowLayout {
                        Layout.fillWidth: true; spacing: 10
                        Text { text: modelData.name; color: Qt.rgba(1,1,1,0.75); font.pixelSize: 11; Layout.fillWidth: true; elide: Text.ElideRight }
                        Text { text: modelData.cpu.toFixed(1)+"%"; color: Qt.rgba(1,1,1,0.48); font.pixelSize: 10 }
                        Rectangle { Layout.preferredWidth: 72; Layout.preferredHeight: 5; radius: 2; color: Qt.rgba(1,1,1,0.06)
                          Rectangle { width: Math.min(1, modelData.cpu/100)*parent.width; height: parent.height; radius: 2; color: Qt.rgba(0.3,0.75,1,0.75) }
                        }
                      }
                    }
                    Item { Layout.fillHeight: true }
                    Text { text: "GPU  ·  "+(root.data.gpu || "Unknown"); color: Qt.rgba(1,1,1,0.38); font.pixelSize: 10; elide: Text.ElideRight; Layout.fillWidth: true }
                  }
                }
              }
            }
          }

          // PROCESSES
          Item {
            ColumnLayout {
              anchors.fill: parent; spacing: 10
              RowLayout {
                Layout.fillWidth: true; Layout.preferredHeight: 42
                Text { text: "PROCESS FIELD"; color: "white"; font.pixelSize: 16; font.weight: Font.Bold; Layout.fillWidth: true }
                Text { text: "sorted by CPU"; color: Qt.rgba(1,1,1,0.35); font.pixelSize: 10 }
              }
              Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true; radius: 16; color: Qt.rgba(1,1,1,0.035)
                ListView {
                  anchors.fill: parent; anchors.margins: 10; clip: true; spacing: 3
                  model: root.data.processes || []
                  delegate: Rectangle {
                    width: ListView.view.width; height: 44; radius: 10
                    color: index % 2 ? Qt.rgba(1,1,1,0.018) : "transparent"
                    RowLayout {
                      anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12; spacing: 10
                      Text { text: modelData.pid; color: Qt.rgba(1,1,1,0.3); font.pixelSize: 10; Layout.preferredWidth: 55 }
                      Text { text: modelData.name; color: "white"; font.pixelSize: 11; Layout.fillWidth: true; elide: Text.ElideRight }
                      Text { text: modelData.cpu.toFixed(1)+"%"; color: Qt.rgba(0.4,0.8,1,0.85); font.pixelSize: 11; Layout.preferredWidth: 60; horizontalAlignment: Text.AlignRight }
                      Text { text: modelData.mem.toFixed(1)+"%"; color: Qt.rgba(1,1,1,0.5); font.pixelSize: 11; Layout.preferredWidth: 60; horizontalAlignment: Text.AlignRight }
                      Text { text: modelData.etime; color: Qt.rgba(1,1,1,0.32); font.pixelSize: 10; Layout.preferredWidth: 70; horizontalAlignment: Text.AlignRight }
                    }
                  }
                }
              }
            }
          }

          // WINDOWS
          Item {
            ColumnLayout {
              anchors.fill: parent; spacing: 12
              Text { text: "WINDOW TOPOLOGY"; color: "white"; font.pixelSize: 16; font.weight: Font.Bold }
              Text { text: "Hyprland clients currently visible to the compositor"; color: Qt.rgba(1,1,1,0.38); font.pixelSize: 10 }
              GridView {
                Layout.fillWidth: true; Layout.fillHeight: true; cellWidth: 290; cellHeight: 120; model: root.data.windows || []
                delegate: Rectangle {
                  width: 270; height: 102; radius: 14
                  color: Qt.rgba(1,1,1,0.04); border.width: 1; border.color: Qt.rgba(1,1,1,0.07)
                  ColumnLayout { anchors.fill: parent; anchors.margins: 13; spacing: 4
                    RowLayout { Layout.fillWidth: true
                      Rectangle { Layout.preferredWidth: 8; Layout.preferredHeight: 8; radius: 4; color: modelData.fullscreen ? Qt.rgba(0.5,0.85,1,1) : Qt.rgba(0.7,0.5,1,1) }
                      Text { text: modelData.class || "Window"; color: "white"; font.pixelSize: 12; font.weight: Font.DemiBold; Layout.fillWidth: true; elide: Text.ElideRight }
                    }
                    Text { text: modelData.title || "No title"; color: Qt.rgba(1,1,1,0.42); font.pixelSize: 10; Layout.fillWidth: true; elide: Text.ElideRight }
                    Text { text: "WS "+modelData.workspace+"  ·  PID "+modelData.pid+"  ·  "+modelData.w+"×"+modelData.h; color: Qt.rgba(1,1,1,0.28); font.pixelSize: 9 }
                  }
                }
              }
            }
          }
        }

        RowLayout {
          Layout.fillWidth: true; Layout.preferredHeight: 24
          Text { text: "LIVE  •  refresh 1.2s  •  local only"; color: Qt.rgba(1,1,1,0.28); font.pixelSize: 9; Layout.fillWidth: true }
          Text { text: "ESC to close  ·  1/2/3 switch views"; color: Qt.rgba(1,1,1,0.28); font.pixelSize: 9 }
        }
      }

      Keys.onEscapePressed: root.close()
      Keys.onDigit1Pressed: root.selectedTab = 0
      Keys.onDigit2Pressed: root.selectedTab = 1
      Keys.onDigit3Pressed: root.selectedTab = 2
    }
  }
}

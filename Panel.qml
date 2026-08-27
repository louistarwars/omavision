import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

Item {
  id: root

  property bool opened: false
  property var data: ({})
  property int page: 0
  property string scriptPath: ""

  readonly property color ink: "#F4F7F5"
  readonly property color muted: "#87928D"
  readonly property color panel: "#111613"
  readonly property color panel2: "#151C18"
  readonly property color line: Qt.rgba(1,1,1,0.08)
  readonly property color accent: "#9BE7B0"
  readonly property color accentSoft: Qt.rgba(0.608,0.906,0.69,0.12)

  function open(payloadJson) {
    opened = true
    page = 0
    snapshot.running = true
  }

  function close() { opened = false }

  Component.onCompleted: scriptPath = manifest.__sourceDir + "/scripts/snapshot.sh"

  Timer {
    interval: 1500
    repeat: true
    running: root.opened
    onTriggered: snapshot.running = true
  }

  Process {
    id: snapshot
    command: ["bash", root.scriptPath]
    stdout: StdioCollector {
      onStreamFinished: {
        try { root.data = JSON.parse(text) }
        catch (e) { console.warn("OmaVision: invalid snapshot", e) }
      }
    }
  }

  PanelWindow {
    id: win
    visible: root.opened
    implicitWidth: Math.min(1240, screen ? screen.width - 90 : 1240)
    implicitHeight: Math.min(780, screen ? screen.height - 90 : 780)
    color: "transparent"
    WlrLayershell.namespace: "omavision"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    anchors { top: true; bottom: true; left: true; right: true }

    Item {
      anchors.fill: parent
      focus: true
      Keys.onEscapePressed: root.close()

      Rectangle {
        anchors.centerIn: parent
        width: Math.min(parent.width - 56, 1160)
        height: Math.min(parent.height - 56, 720)
        radius: 26
        color: Qt.rgba(0.035,0.045,0.04,0.985)
        border.width: 1
        border.color: Qt.rgba(1,1,1,0.10)

        Rectangle {
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.top: parent.top
          height: 2
          radius: 1
          color: root.accent
          opacity: 0.7
        }

        ColumnLayout {
          anchors.fill: parent
          anchors.margins: 28
          spacing: 20

          RowLayout {
            Layout.fillWidth: true
            spacing: 16

            ColumnLayout {
              Layout.fillWidth: true
              spacing: 2
              Text { text: "OMAVISION"; color: root.ink; font.pixelSize: 26; font.weight: Font.Bold }
              Text { text: "YOUR MACHINE, AT A GLANCE"; color: root.muted; font.pixelSize: 10; font.letterSpacing: 1.6 }
            }

            Repeater {
              model: ["OVERVIEW", "APPS", "SYSTEM"]
              delegate: Rectangle {
                implicitWidth: 88; implicitHeight: 34; radius: 10
                color: index === root.page ? root.accentSoft : "transparent"
                border.width: index === root.page ? 1 : 0
                border.color: Qt.rgba(0.608,0.906,0.69,0.22)
                Text { anchors.centerIn: parent; text: modelData; color: index === root.page ? root.ink : root.muted; font.pixelSize: 10; font.weight: Font.DemiBold }
                MouseArea { anchors.fill: parent; onClicked: root.page = index }
              }
            }

            Rectangle {
              width: 38; height: 38; radius: 12; color: Qt.rgba(1,1,1,0.05)
              Text { anchors.centerIn: parent; text: "×"; color: root.muted; font.pixelSize: 20 }
              MouseArea { anchors.fill: parent; onClicked: root.close() }
            }
          }

          // OVERVIEW
          Item {
            visible: root.page === 0
            Layout.fillWidth: true; Layout.fillHeight: true

            ColumnLayout {
              anchors.fill: parent; spacing: 16

              RowLayout {
                Layout.fillWidth: true; Layout.preferredHeight: 84; spacing: 12
                Repeater {
                  model: [
                    {label:"CPU", value:(root.data.cpu || 0)+"%"},
                    {label:"MEMORY", value:(root.data.memory?.pct || 0)+"%"},
                    {label:"NETWORK", value:(root.data.network?.tcpSockets || 0)+" sockets"},
                    {label:"UPTIME", value:Math.floor((root.data.uptime || 0)/3600)+"h"}
                  ]
                  delegate: Rectangle {
                    Layout.fillWidth: true; Layout.fillHeight: true; radius: 16
                    color: root.panel2; border.width: 1; border.color: root.line
                    ColumnLayout { anchors.fill: parent; anchors.margins: 14; spacing: 2
                      Text { text: modelData.label; color: root.muted; font.pixelSize: 9; font.weight: Font.DemiBold }
                      Text { text: modelData.value; color: root.ink; font.pixelSize: 23; font.weight: Font.Bold }
                    }
                  }
                }
              }

              RowLayout {
                Layout.fillWidth: true; Layout.fillHeight: true; spacing: 16

                Rectangle {
                  Layout.fillWidth: true; Layout.fillHeight: true; radius: 20
                  color: root.panel; border.width: 1; border.color: root.line

                  ColumnLayout { anchors.fill: parent; anchors.margins: 20; spacing: 6
                    Text { text: "MACHINE"; color: root.ink; font.pixelSize: 12; font.weight: Font.Bold }
                    Text { text: root.data.host || "Omarchy"; color: root.muted; font.pixelSize: 10 }

                    Item {
                      Layout.fillWidth: true; Layout.fillHeight: true

                      Rectangle {
                        id: core
                        anchors.centerIn: parent
                        width: 122; height: 122; radius: 61
                        color: root.accentSoft
                        border.width: 1; border.color: Qt.rgba(0.608,0.906,0.69,0.35)
                        Text { anchors.centerIn: parent; text: "OMARCHY"; color: root.ink; font.pixelSize: 12; font.weight: Font.Bold }
                      }

                      Repeater {
                        model: Math.min((root.data.windows || []).length, 8)
                        delegate: Rectangle {
                          width: 48; height: 48; radius: 16
                          property real angle: (index / Math.max(1, Math.min((root.data.windows || []).length,8))) * Math.PI * 2 - Math.PI/2
                          property real orbit: 150
                          x: parent.width/2 + Math.cos(angle)*orbit - width/2
                          y: parent.height/2 + Math.sin(angle)*orbit - height/2
                          color: root.panel2; border.width: 1; border.color: root.line
                          Text { anchors.centerIn: parent; text: "APP"; color: root.muted; font.pixelSize: 8; font.weight: Font.Bold }
                        }
                      }
                    }
                  }
                }

                Rectangle {
                  Layout.preferredWidth: 330; Layout.fillHeight: true; radius: 20
                  color: root.panel; border.width: 1; border.color: root.line
                  ColumnLayout { anchors.fill: parent; anchors.margins: 20; spacing: 12
                    Text { text: "TOP ACTIVITY"; color: root.ink; font.pixelSize: 12; font.weight: Font.Bold }
                    Repeater {
                      model: (root.data.processes || []).slice(0,6)
                      delegate: RowLayout { Layout.fillWidth: true; spacing: 10
                        Rectangle { width: 30; height: 30; radius: 10; color: root.accentSoft
                          Text { anchors.centerIn: parent; text: "•"; color: root.accent; font.pixelSize: 16 }
                        }
                        ColumnLayout { Layout.fillWidth: true; spacing: 1
                          Text { text: modelData.name; color: root.ink; font.pixelSize: 10; elide: Text.ElideRight; Layout.fillWidth: true }
                          Text { text: modelData.cpu.toFixed(1)+"% CPU"; color: root.muted; font.pixelSize: 9 }
                        }
                      }
                    }
                    Item { Layout.fillHeight: true }
                    Text { text: "ESC  close  ·  1 / 2 / 3  switch views"; color: root.muted; font.pixelSize: 9 }
                  }
                }
              }
            }
          }

          // APPS
          Item {
            visible: root.page === 1
            Layout.fillWidth: true; Layout.fillHeight: true
            ColumnLayout { anchors.fill: parent; spacing: 10
              Text { text: "RUNNING PROCESSES"; color: root.ink; font.pixelSize: 13; font.weight: Font.Bold }
              Text { text: "The busiest things on your machine right now."; color: root.muted; font.pixelSize: 10 }
              ListView {
                Layout.fillWidth: true; Layout.fillHeight: true; clip: true; spacing: 7
                model: root.data.processes || []
                delegate: Rectangle {
                  width: ListView.view.width; height: 54; radius: 14; color: root.panel2; border.width: 1; border.color: root.line
                  RowLayout { anchors.fill: parent; anchors.margins: 12; spacing: 12
                    Rectangle { width: 30; height: 30; radius: 9; color: root.accentSoft; Text { anchors.centerIn: parent; text: "•"; color: root.accent; font.pixelSize: 15 } }
                    ColumnLayout { Layout.fillWidth: true; spacing: 2
                      Text { text: modelData.name; color: root.ink; font.pixelSize: 11; font.weight: Font.DemiBold }
                      Text { text: "PID " + modelData.pid; color: root.muted; font.pixelSize: 9 }
                    }
                    Text { text: modelData.cpu.toFixed(1)+"%"; color: root.ink; font.pixelSize: 11 }
                    Text { text: Math.round(modelData.mem || 0)+" MB"; color: root.muted; font.pixelSize: 10 }
                  }
                }
              }
            }
          }

          // SYSTEM
          Item {
            visible: root.page === 2
            Layout.fillWidth: true; Layout.fillHeight: true
            GridLayout { anchors.fill: parent; columns: 2; rowSpacing: 12; columnSpacing: 12
              Repeater {
                model: [
                  {label:"CPU", value:root.data.cpu || 0, unit:"%"},
                  {label:"MEMORY", value:root.data.memory?.pct || 0, unit:"%"},
                  {label:"TCP SOCKETS", value:root.data.network?.tcpSockets || 0, unit:""},
                  {label:"UPTIME", value:Math.floor((root.data.uptime || 0)/3600), unit:" hours"}
                ]
                delegate: Rectangle {
                  Layout.fillWidth: true; Layout.fillHeight: true; radius: 18; color: root.panel; border.width: 1; border.color: root.line
                  ColumnLayout { anchors.fill: parent; anchors.margins: 20; spacing: 12
                    Text { text: modelData.label; color: root.muted; font.pixelSize: 10; font.weight: Font.DemiBold }
                    RowLayout { spacing: 5
                      Text { text: modelData.value; color: root.ink; font.pixelSize: 30; font.weight: Font.Bold }
                      Text { text: modelData.unit; color: root.muted; font.pixelSize: 11 }
                    }
                    Rectangle { Layout.fillWidth: true; height: 7; radius: 3; color: Qt.rgba(1,1,1,0.06)
                      Rectangle { width: Math.min(1, Number(modelData.value)/100)*parent.width; height: parent.height; radius: 3; color: root.accent }
                    }
                  }
                }
              }
              Rectangle { Layout.columnSpan: 2; Layout.fillWidth: true; Layout.fillHeight: true; radius: 18; color: root.panel; border.width: 1; border.color: root.line
                ColumnLayout { anchors.fill: parent; anchors.margins: 20; spacing: 6
                  Text { text: "SYSTEM"; color: root.ink; font.pixelSize: 12; font.weight: Font.Bold }
                  Text { text: "Kernel  ·  " + (root.data.kernel || "unknown"); color: root.muted; font.pixelSize: 10 }
                  Text { text: "GPU  ·  " + (root.data.gpu || "not detected"); color: root.muted; font.pixelSize: 10; elide: Text.ElideRight; Layout.fillWidth: true }
                  Text { text: "Network  ·  TCP endpoints " + (root.data.network?.tcpSockets || 0); color: root.muted; font.pixelSize: 10 }
                }
              }
            }
          }
        }
      }
    }
  }
}

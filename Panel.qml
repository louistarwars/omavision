import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: root

    implicitWidth: 1400
    implicitHeight: 850

    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    property real zoom: 1.0
    property string mode: "MACHINE"
    property string hoveredNode: ""

    property var nodes: [
        { name: "Firefox", type: "APP", x: 0.31, y: 0.32, size: 82 },
        { name: "VS Code", type: "APP", x: 0.68, y: 0.30, size: 92 },
        { name: "Terminal", type: "APP", x: 0.29, y: 0.66, size: 70 },
        { name: "Discord", type: "APP", x: 0.70, y: 0.65, size: 68 },
        { name: "CPU", type: "SYSTEM", x: 0.50, y: 0.20, size: 58 },
        { name: "RAM", type: "SYSTEM", x: 0.50, y: 0.80, size: 62 }
    ]

    Rectangle {
        anchors.fill: parent
        radius: 28
        color: "#090a0f"
        opacity: 0.97
        border.width: 1
        border.color: "#252833"
    }

    Rectangle {
        anchors.fill: parent
        radius: 28
        color: "transparent"
        border.width: 1
        border.color: "#ffffff10"
    }

    // Header
    Row {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 32
        height: 55
        spacing: 28

        Text {
            text: "OMAVISION"
            color: "white"
            font.pixelSize: 23
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: "YOUR MACHINE, VISUALIZED"
            color: "#737783"
            font.pixelSize: 11
            font.letterSpacing: 2
            anchors.verticalCenter: parent.verticalCenter
        }

        Item { width: 1; height: 1 }

        Row {
            spacing: 8
            anchors.verticalCenter: parent.verticalCenter

            Repeater {
                model: ["MACHINE", "NETWORK", "PROCESSES"]

                Rectangle {
                    width: modeText.implicitWidth + 28
                    height: 34
                    radius: 17
                    color: root.mode === modelData ? "#ffffff" : "#15171d"

                    Text {
                        id: modeText
                        anchors.centerIn: parent
                        text: modelData
                        color: root.mode === modelData ? "#090a0f" : "#777b86"
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 1
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.mode = modelData
                    }
                }
            }
        }
    }

    // Main visual field
    Item {
        id: scene
        anchors.top: header.bottom
        anchors.bottom: footer.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 20

        // connection lines
        Canvas {
            anchors.fill: parent

            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)

                ctx.lineWidth = 1

                function line(x1, y1, x2, y2) {
                    ctx.strokeStyle = "#30343e"
                    ctx.beginPath()
                    ctx.moveTo(x1, y1)
                    ctx.lineTo(x2, y2)
                    ctx.stroke()
                }

                var cx = width * 0.50
                var cy = height * 0.50

                line(cx, cy, width * 0.31, height * 0.32)
                line(cx, cy, width * 0.68, height * 0.30)
                line(cx, cy, width * 0.29, height * 0.66)
                line(cx, cy, width * 0.70, height * 0.65)
                line(cx, cy, width * 0.50, height * 0.20)
                line(cx, cy, width * 0.50, height * 0.80)
            }
        }

        // animated particles
        Repeater {
            model: 12

            Rectangle {
                width: 3
                height: 3
                radius: 2
                color: "#ffffff"
                opacity: 0.45

                x: scene.width * (0.25 + ((index * 37) % 55) / 100)
                y: scene.height * (0.20 + ((index * 61) % 60) / 100)

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.05; duration: 900 + index * 70 }
                    NumberAnimation { to: 0.55; duration: 900 + index * 70 }
                }
            }
        }

        // Central machine
        Item {
            id: machine
            x: scene.width / 2 - 75
            y: scene.height / 2 - 75
            width: 150
            height: 150

            Rectangle {
                anchors.centerIn: parent
                width: 150
                height: 150
                radius: 75
                color: "#12151c"
                border.width: 1
                border.color: "#4b515e"

                SequentialAnimation on scale {
                    loops: Animation.Infinite
                    NumberAnimation { to: 1.035; duration: 1800 }
                    NumberAnimation { to: 1.0; duration: 1800 }
                }
            }

            Rectangle {
                anchors.centerIn: parent
                width: 112
                height: 112
                radius: 56
                color: "#0d0f14"
                border.width: 1
                border.color: "#ffffff18"
            }

            Column {
                anchors.centerIn: parent
                spacing: 5

                Text {
                    text: "YOUR"
                    color: "#777c88"
                    font.pixelSize: 9
                    font.letterSpacing: 2
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: "MACHINE"
                    color: "white"
                    font.pixelSize: 17
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: "ONLINE"
                    color: "#9ca1ad"
                    font.pixelSize: 8
                    font.letterSpacing: 2
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }

        // Nodes
        Repeater {
            model: root.nodes

            Item {
                id: node
                width: modelData.size + 80
                height: modelData.size + 80

                x: scene.width * modelData.x - width / 2
                y: scene.height * modelData.y - height / 2

                property bool hovered: root.hoveredNode === modelData.name

                Rectangle {
                    anchors.centerIn: parent
                    width: modelData.size + (node.hovered ? 18 : 0)
                    height: width
                    radius: width / 2
                    color: "#10131a"
                    border.width: node.hovered ? 2 : 1
                    border.color: node.hovered ? "#ffffff" : "#3a3f4a"

                    Behavior on width {
                        NumberAnimation { duration: 180 }
                    }

                    Behavior on height {
                        NumberAnimation { duration: 180 }
                    }
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: 8
                    height: 8
                    radius: 4
                    color: "#ffffff"
                }

                Column {
                    anchors.top: parent.verticalCenter
                    anchors.topMargin: modelData.size / 2 + 12
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 3

                    Text {
                        text: modelData.name
                        color: node.hovered ? "white" : "#b9bdc7"
                        font.pixelSize: 12
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: modelData.type
                        color: "#5f6470"
                        font.pixelSize: 8
                        font.letterSpacing: 1.5
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true

                    onEntered: root.hoveredNode = modelData.name
                    onExited: root.hoveredNode = ""
                }

                Behavior on x {
                    NumberAnimation { duration: 350; easing.type: Easing.OutCubic }
                }

                Behavior on y {
                    NumberAnimation { duration: 350; easing.type: Easing.OutCubic }
                }
            }
        }
    }

    // Footer
    Row {
        id: footer
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 32
        height: 48
        spacing: 30

        Text {
            text: "CPU  27%"
            color: "#858a96"
            font.pixelSize: 11
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: "RAM  8.2 GB"
            color: "#858a96"
            font.pixelSize: 11
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: "NETWORK  16"
            color: "#858a96"
            font.pixelSize: 11
            anchors.verticalCenter: parent.verticalCenter
        }

        Item { Layout.fillWidth: true; width: 1 }

        Text {
            text: "ESC  CLOSE"
            color: "#555a65"
            font.pixelSize: 9
            font.letterSpacing: 1
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // ESC closes
    Shortcut {
        sequence: "Escape"
        onActivated: root.visible = false
    }

    // Zoom with wheel
    WheelHandler {
        onWheel: function(event) {
            root.zoom = Math.max(0.7, Math.min(1.5,
                root.zoom + event.angleDelta.y / 1200))
        }
    }

    // Close by clicking outside is intentionally disabled:
    // OmaVision behaves like a focused visual workspace.
}

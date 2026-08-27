import QtQuick
import Quickshell
import Quickshell.Wayland

Item {
    id: root

    property bool opened: false
    property string mode: "MACHINE"
    property string hoveredNode: ""

    width: 1400
    height: 850

    function open(payloadJson) {
        opened = true
    }

    function close() {
        opened = false
    }

    function toggle() {
        opened = !opened
    }

    visible: opened

    Rectangle {
        anchors.fill: parent
        radius: 28
        color: "#090a0f"
        opacity: 0.98

        border.width: 1
        border.color: "#292d37"
    }

    Rectangle {
        anchors.fill: parent
        radius: 28
        color: "transparent"

        border.width: 1
        border.color: "#ffffff10"
    }

    // HEADER
    Row {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        anchors.margins: 32

        height: 55
        spacing: 26

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

            font.pixelSize: 10
            font.letterSpacing: 2

            anchors.verticalCenter: parent.verticalCenter
        }

        Item {
            width: 1
            height: 1
        }

        Row {
            spacing: 8

            anchors.verticalCenter: parent.verticalCenter

            Repeater {
                model: ["MACHINE", "NETWORK", "PROCESSES"]

                Rectangle {
                    width: modeText.implicitWidth + 28
                    height: 34

                    radius: 17

                    color: root.mode === modelData
                           ? "#ffffff"
                           : "#15171d"

                    Text {
                        id: modeText

                        anchors.centerIn: parent

                        text: modelData

                        color: root.mode === modelData
                               ? "#090a0f"
                               : "#777b86"

                        font.pixelSize: 9
                        font.bold: true
                        font.letterSpacing: 1
                    }

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            root.mode = modelData
                        }
                    }
                }
            }
        }
    }

    // VISUAL SPACE
    Item {
        id: scene

        anchors.top: parent.top
        anchors.topMargin: 105

        anchors.bottom: parent.bottom
        anchors.bottomMargin: 75

        anchors.left: parent.left
        anchors.right: parent.right

        // CONNECTIONS
        Canvas {
            anchors.fill: parent

            onPaint: {
                var ctx = getContext("2d")

                ctx.clearRect(
                    0,
                    0,
                    width,
                    height
                )

                ctx.lineWidth = 1
                ctx.strokeStyle = "#30343e"

                function line(x1, y1, x2, y2) {
                    ctx.beginPath()
                    ctx.moveTo(x1, y1)
                    ctx.lineTo(x2, y2)
                    ctx.stroke()
                }

                var cx = width * 0.5
                var cy = height * 0.5

                line(
                    cx,
                    cy,
                    width * 0.30,
                    height * 0.27
                )

                line(
                    cx,
                    cy,
                    width * 0.70,
                    height * 0.25
                )

                line(
                    cx,
                    cy,
                    width * 0.27,
                    height * 0.70
                )

                line(
                    cx,
                    cy,
                    width * 0.73,
                    height * 0.68
                )

                line(
                    cx,
                    cy,
                    width * 0.50,
                    height * 0.12
                )

                line(
                    cx,
                    cy,
                    width * 0.50,
                    height * 0.88
                )
            }
        }

        // PARTICLES
        Repeater {
            model: 18

            Rectangle {
                width: 3
                height: 3

                radius: 2

                color: "#ffffff"

                opacity: 0.15

                x: scene.width *
                   (0.15 + ((index * 37) % 70) / 100)

                y: scene.height *
                   (0.10 + ((index * 61) % 80) / 100)

                SequentialAnimation on opacity {
                    loops: Animation.Infinite

                    NumberAnimation {
                        to: 0.03
                        duration: 900 + index * 50
                    }

                    NumberAnimation {
                        to: 0.45
                        duration: 900 + index * 50
                    }
                }
            }
        }

        // CENTRAL MACHINE
        Item {
            id: machine

            width: 170
            height: 170

            x: scene.width / 2 - width / 2
            y: scene.height / 2 - height / 2

            Rectangle {
                anchors.centerIn: parent

                width: 160
                height: 160

                radius: 80

                color: "#11141b"

                border.width: 1
                border.color: "#4c5360"

                SequentialAnimation on scale {
                    loops: Animation.Infinite

                    NumberAnimation {
                        to: 1.035
                        duration: 1800
                    }

                    NumberAnimation {
                        to: 1
                        duration: 1800
                    }
                }
            }

            Rectangle {
                anchors.centerIn: parent

                width: 118
                height: 118

                radius: 59

                color: "#0b0d12"

                border.width: 1
                border.color: "#ffffff14"
            }

            Column {
                anchors.centerIn: parent

                spacing: 5

                Text {
                    text: "YOUR"

                    color: "#747985"

                    font.pixelSize: 9
                    font.letterSpacing: 2

                    anchors.horizontalCenter:
                        parent.horizontalCenter
                }

                Text {
                    text: "MACHINE"

                    color: "white"

                    font.pixelSize: 18
                    font.bold: true

                    anchors.horizontalCenter:
                        parent.horizontalCenter
                }

                Text {
                    text: "ONLINE"

                    color: "#858b98"

                    font.pixelSize: 8
                    font.letterSpacing: 2

                    anchors.horizontalCenter:
                        parent.horizontalCenter
                }
            }
        }

        // NODES
        Repeater {
            model: [
                {
                    name: "Firefox",
                    type: "APP",
                    x: 0.30,
                    y: 0.27,
                    size: 76
                },

                {
                    name: "VS Code",
                    type: "APP",
                    x: 0.70,
                    y: 0.25,
                    size: 88
                },

                {
                    name: "Terminal",
                    type: "APP",
                    x: 0.27,
                    y: 0.70,
                    size: 65
                },

                {
                    name: "Discord",
                    type: "APP",
                    x: 0.73,
                    y: 0.68,
                    size: 65
                },

                {
                    name: "CPU",
                    type: "SYSTEM",
                    x: 0.50,
                    y: 0.12,
                    size: 55
                },

                {
                    name: "RAM",
                    type: "SYSTEM",
                    x: 0.50,
                    y: 0.88,
                    size: 60
                }
            ]

            Item {
                id: node

                width: modelData.size + 80
                height: modelData.size + 80

                x: scene.width * modelData.x - width / 2
                y: scene.height * modelData.y - height / 2

                property bool hovered:
                    root.hoveredNode === modelData.name

                Rectangle {
                    anchors.centerIn: parent

                    width: modelData.size +
                           (node.hovered ? 18 : 0)

                    height: width

                    radius: width / 2

                    color: "#10131a"

                    border.width:
                        node.hovered ? 2 : 1

                    border.color:
                        node.hovered
                        ? "#ffffff"
                        : "#3a3f4a"

                    Behavior on width {
                        NumberAnimation {
                            duration: 180
                        }
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
                    anchors.top:
                        parent.verticalCenter

                    anchors.topMargin:
                        modelData.size / 2 + 12

                    anchors.horizontalCenter:
                        parent.horizontalCenter

                    spacing: 3

                    Text {
                        text: modelData.name

                        color:
                            node.hovered
                            ? "white"
                            : "#b9bdc7"

                        font.pixelSize: 12
                        font.bold: true

                        anchors.horizontalCenter:
                            parent.horizontalCenter
                    }

                    Text {
                        text: modelData.type

                        color: "#5f6470"

                        font.pixelSize: 8
                        font.letterSpacing: 1.5

                        anchors.horizontalCenter:
                            parent.horizontalCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent

                    hoverEnabled: true

                    onEntered:
                        root.hoveredNode =
                            modelData.name

                    onExited:
                        root.hoveredNode = ""
                }
            }
        }
    }

    // FOOTER
    Row {
        anchors.bottom: parent.bottom
        anchors.left: parent.left

        anchors.margins: 32

        height: 45

        spacing: 28

        Text {
            text: "CPU  27%"

            color: "#858a96"

            font.pixelSize: 11

            anchors.verticalCenter:
                parent.verticalCenter
        }

        Text {
            text: "RAM  8.2 GB"

            color: "#858a96"

            font.pixelSize: 11

            anchors.verticalCenter:
                parent.verticalCenter
        }

        Text {
            text: "NETWORK  16"

            color: "#858a96"

            font.pixelSize: 11

            anchors.verticalCenter:
                parent.verticalCenter
        }

        Item {
            width: 1
            height: 1
        }

        Text {
            text: "ESC  CLOSE"

            color: "#555a65"

            font.pixelSize: 9
            font.letterSpacing: 1

            anchors.verticalCenter:
                parent.verticalCenter
        }
    }

    Keys.onEscapePressed: {
        root.close()
    }
}

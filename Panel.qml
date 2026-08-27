import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

Panel {
    id: root

    moduleName: "louistarwars.omavision"

    manageIpc: false

    property var anchorItem: null
    property var hostWidget: null

    property string mode: "MACHINE"
    property string hoveredNode: ""

    function open() {
        root.controller.show()
    }

    function close() {
        root.controller.hide()
    }

    function toggle() {
        if (root.opened)
            root.close()
        else
            root.open()
    }

    function closeForPopoutSwitch() {
        root.close()
    }

    function switchPanel(direction) {
        if (root.bar &&
            typeof root.bar.switchPanelFrom === "function") {
            return root.bar.switchPanelFrom(
                root.hostWidget || root,
                direction
            )
        }

        return false
    }

    KeyboardPanel {
        id: panel

        anchorItem: root.anchorItem

        owner: root.hostWidget || root

        bar: root.bar

        open: root.opened

        focusTarget: keyCatcher

        contentWidth:
            panel.fittedContentWidth(Style.space(1400))

        contentHeight:
            panel.fittedContentHeight(content.implicitHeight)

        PanelKeyCatcher {
            id: keyCatcher

            anchors.fill: parent

            onCloseRequested: root.close()

            onTabRequested: function(direction) {
                root.switchPanel(direction)
            }

            Item {
                id: content

                implicitWidth: 1400
                implicitHeight: 850

                // =================================================
                // BACKGROUND
                // =================================================

                Rectangle {
                    anchors.fill: parent

                    radius: 28

                    color: "#090a0f"

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

                // =================================================
                // HEADER
                // =================================================

                Row {
                    id: header

                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right

                    anchors.margins: 32

                    height: 55

                    spacing: 22

                    Text {
                        text: "OMAVISION"

                        color: "white"

                        font.pixelSize: 23
                        font.bold: true

                        anchors.verticalCenter:
                            parent.verticalCenter
                    }

                    Text {
                        text: "YOUR MACHINE, VISUALIZED"

                        color: "#737783"

                        font.pixelSize: 10
                        font.letterSpacing: 2

                        anchors.verticalCenter:
                            parent.verticalCenter
                    }

                    Item {
                        width: 1
                        height: 1
                    }

                    Row {
                        spacing: 8

                        anchors.verticalCenter:
                            parent.verticalCenter

                        Repeater {
                            model: [
                                "MACHINE",
                                "NETWORK",
                                "PROCESSES"
                            ]

                            Rectangle {
                                width:
                                    modeText.implicitWidth + 28

                                height: 34

                                radius: 17

                                color:
                                    root.mode === modelData
                                    ? "#ffffff"
                                    : "#15171d"

                                Text {
                                    id: modeText

                                    anchors.centerIn: parent

                                    text: modelData

                                    color:
                                        root.mode === modelData
                                        ? "#090a0f"
                                        : "#777b86"

                                    font.pixelSize: 9
                                    font.bold: true
                                    font.letterSpacing: 1
                                }

                                MouseArea {
                                    anchors.fill: parent

                                    onClicked:
                                        root.mode = modelData
                                }
                            }
                        }
                    }
                }

                // =================================================
                // VISUAL NETWORK
                // =================================================

                Item {
                    id: scene

                    anchors.top: header.bottom
                    anchors.bottom: footer.top

                    anchors.left: parent.left
                    anchors.right: parent.right

                    anchors.margins: 20

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

                            ctx.strokeStyle =
                                "#30343e"

                            var cx = width * 0.5
                            var cy = height * 0.5

                            function line(x1, y1, x2, y2) {
                                ctx.beginPath()
                                ctx.moveTo(x1, y1)
                                ctx.lineTo(x2, y2)
                                ctx.stroke()
                            }

                            line(
                                cx, cy,
                                width * .30,
                                height * .27
                            )

                            line(
                                cx, cy,
                                width * .70,
                                height * .25
                            )

                            line(
                                cx, cy,
                                width * .27,
                                height * .70
                            )

                            line(
                                cx, cy,
                                width * .73,
                                height * .68
                            )

                            line(
                                cx, cy,
                                width * .50,
                                height * .12
                            )

                            line(
                                cx, cy,
                                width * .50,
                                height * .88
                            )
                        }
                    }

                    // =================================================
                    // CENTRAL MACHINE
                    // =================================================

                    Item {
                        width: 180
                        height: 180

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

                    // =================================================
                    // NODES
                    // =================================================

                    Repeater {
                        model: [
                            {
                                name: "Firefox",
                                type: "APP",
                                x: .30,
                                y: .27,
                                size: 76
                            },
                            {
                                name: "VS Code",
                                type: "APP",
                                x: .70,
                                y: .25,
                                size: 88
                            },
                            {
                                name: "Terminal",
                                type: "APP",
                                x: .27,
                                y: .70,
                                size: 65
                            },
                            {
                                name: "Discord",
                                type: "APP",
                                x: .73,
                                y: .68,
                                size: 65
                            },
                            {
                                name: "CPU",
                                type: "SYSTEM",
                                x: .50,
                                y: .12,
                                size: 55
                            },
                            {
                                name: "RAM",
                                type: "SYSTEM",
                                x: .50,
                                y: .88,
                                size: 60
                            }
                        ]

                        Item {
                            id: node

                            width: modelData.size + 80
                            height: modelData.size + 80

                            x: scene.width *
                               modelData.x -
                               width / 2

                            y: scene.height *
                               modelData.y -
                               height / 2

                            property bool hovered:
                                root.hoveredNode ===
                                modelData.name

                            Rectangle {
                                anchors.centerIn: parent

                                width:
                                    modelData.size +
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

                // =================================================
                // FOOTER
                // =================================================

                Row {
                    id: footer

                    anchors.bottom: parent.bottom
                    anchors.left: parent.left

                    anchors.margins: 32

                    height: 45

                    spacing: 28

                    Text {
                        text: "CPU  27%"

                        color: "#858a96"

                        font.pixelSize: 11
                    }

                    Text {
                        text: "RAM  8.2 GB"

                        color: "#858a96"

                        font.pixelSize: 11
                    }

                    Text {
                        text: "NETWORK  16"

                        color: "#858a96"

                        font.pixelSize: 11
                    }

                    Text {
                        text: "ESC  CLOSE"

                        color: "#555a65"

                        font.pixelSize: 9
                        font.letterSpacing: 1
                    }
                }
            }
        }
    }
}

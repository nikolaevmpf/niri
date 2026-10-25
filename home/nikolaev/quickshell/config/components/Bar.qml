import QtQuick
import Quickshell
import "../theme" as Style

PanelWindow {
    id: bar

    readonly property bool compact: width < 1000

    anchors {
        top: true
        left: true
        right: true
    }
    margins {
        top: Style.Theme.screenMargin
        left: Style.Theme.screenMargin
        right: Style.Theme.screenMargin
    }

    implicitHeight: Style.Theme.panelHeight
    exclusiveZone: implicitHeight
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        radius: Style.Theme.radius
        color: Style.Theme.background
        border.width: 1
        border.color: Style.Theme.border

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6

            Text {
                visible: !bar.compact
                anchors.verticalCenter: parent.verticalCenter
                text: "NIRI"
                color: Style.Theme.accent
                font.family: Style.Theme.fontFamily
                font.pixelSize: Style.Theme.fontSize
                font.bold: true
                rightPadding: 8
            }
            ActionButton {
                label: bar.compact ? "Терм." : "Терминал"
                onClicked: Quickshell.execDetached(["ghostty"])
            }
            ActionButton {
                label: bar.compact ? "Web" : "Firefox"
                onClicked: Quickshell.execDetached(["firefox"])
            }
            ActionButton {
                label: "Файлы"
                onClicked: Quickshell.execDetached(["nautilus"])
            }
        }

        Clock {
            anchors.centerIn: parent
        }

        ActionButton {
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            label: "Выход"
            labelColor: Style.Theme.danger
            // Niri displays its own confirmation dialog.
            onClicked: Quickshell.execDetached(["niri", "msg", "action", "quit"])
        }
    }
}

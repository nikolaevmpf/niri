pragma Singleton
import QtQuick

QtObject {
    readonly property color background: "#1e1e2e"
    readonly property color surface: "#313244"
    readonly property color hover: "#45475a"
    readonly property color border: "#45475a"
    readonly property color foreground: "#cdd6f4"
    readonly property color accent: "#89b4fa"
    readonly property color danger: "#f38ba8"

    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 13
    readonly property int panelHeight: 48
    readonly property int buttonHeight: 30
    readonly property int radius: 12
    readonly property int screenMargin: 8
}

import Quickshell
import "components" as Components

ShellRoot {
    Variants {
        model: Quickshell.screens

        delegate: Components.Bar {
            required property var modelData
            screen: modelData
        }
    }
}

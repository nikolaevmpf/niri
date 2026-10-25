import QtQuick
import "../theme" as Style

Text {
    id: clock

    property date now: new Date()
    text: Qt.formatDateTime(now, "ddd, dd.MM  HH:mm")
    color: Style.Theme.foreground
    font.family: Style.Theme.fontFamily
    font.pixelSize: Style.Theme.fontSize

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: clock.now = new Date()
    }
}

import QtQuick
import "../theme" as Style

Rectangle {
    id: button

    required property string label
    property color labelColor: Style.Theme.foreground
    signal clicked()

    implicitWidth: caption.implicitWidth + 22
    implicitHeight: Style.Theme.buttonHeight
    radius: 8
    color: mouse.containsMouse ? Style.Theme.hover : Style.Theme.surface

    Text {
        id: caption
        anchors.centerIn: parent
        text: button.label
        color: button.labelColor
        font.family: Style.Theme.fontFamily
        font.pixelSize: Style.Theme.fontSize
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: button.clicked()
    }
}

import QtQuick 2.15
import QtQuick.Controls 2.15
import MeoUI 1.0
pragma ComponentBehavior: Bound
Control {
    id: control

    // 🌟 核心属性
    property var model: [] // Array of { label: "", value: any, icon: "" }
    property string separator: "chevron_right"
    spacing: 4 * themeGlobalScale

    signal clicked(int index, var data)

    // 🌟 作用域与主题安全防御
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    readonly property var fontLabelLarge: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.labelLarge !== 'undefined') ? MeoTheme.labelLarge : { "size": 14, "weight": Font.Medium }

    implicitHeight: 48 * themeGlobalScale
    implicitWidth: contentRow.implicitWidth + leftPadding + rightPadding

    padding: 8 * themeGlobalScale

    contentItem: Row {
        id: contentRow
        spacing: control.spacing
        anchors.verticalCenter: parent.verticalCenter

        Repeater {
            model: control.model
            delegate: Row {
                spacing: control.spacing
                anchors.verticalCenter: parent.verticalCenter

                // Breadcrumb Item
                Item {
                    width: breadcrumbRow.implicitWidth + 16 * control.themeGlobalScale
                    height: 32 * control.themeGlobalScale
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        id: stateLayer
                        anchors.fill: parent
                        radius: 8 * control.themeGlobalScale
                        color: {
                            if (mouseArea.pressed) return Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, 0.12)
                            if (mouseArea.containsMouse) return Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, 0.08)
                            return "transparent"
                        }
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    Row {
                        id: breadcrumbRow
                        anchors.centerIn: parent
                        spacing: 4 * control.themeGlobalScale

                        MeoIcon {
                            icon: modelData.icon || ""
                            visible: icon !== ""
                            size: 18
                            color: index === control.model.length - 1 ? control.themeOnSurface : control.themeOnSurfaceVariant
                        }

                        Text {
                            text: modelData.label
                            font.pixelSize: control.fontLabelLarge.size * control.themeGlobalScale
                            font.weight: index === control.model.length - 1 ? Font.Bold : control.fontLabelLarge.weight
                            color: index === control.model.length - 1 ? control.themeOnSurface : control.themeOnSurfaceVariant
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: control.clicked(index, modelData)
                    }
                }

                // Separator
                MeoIcon {
                    icon: control.separator
                    visible: index < control.model.length - 1
                    size: 16
                    color: control.themeOnSurfaceVariant
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}

import QtQuick
import QtQuick.Controls
import MeoUI

Rectangle {
    id: control

    // 🌟 核心属性
    property var model: [] // [{ icon: "", label: "" }]
    property int currentIndex: 0
    property bool isExpanded: false
    property Component header: null
    property Component footer: null
    property string labelType: "always" // "always" | "selected" | "none"
    property string shape: "pill" // 🌟 MD3 Expressive Shape

    signal clicked(int index)

    // 🌟 作用域与主题安全防御
    readonly property color themeSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surface !== 'undefined') ? MeoTheme.surface : "#FFFBFE"
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurfaceVariant !== 'undefined') ? MeoTheme.contentOnSurfaceVariant : "#49454F"
    readonly property color themeOnSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSecondaryContainer !== 'undefined') ? MeoTheme.contentOnSecondaryContainer : "#1D192B"
    readonly property color themeSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.secondaryContainer !== 'undefined') ? MeoTheme.secondaryContainer : "#E8DEF8"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    readonly property var fontLabelLarge: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.labelLarge !== 'undefined') ? MeoTheme.labelLarge : { "size": 14, "weight": Font.Medium }

    width: (isExpanded ? 256 : 80) * themeGlobalScale
    height: parent ? parent.height : 600 * themeGlobalScale
    color: themeSurface

    Behavior on width {
        NumberAnimation {
            duration: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationMedium4 !== 'undefined') ? MeoTheme.motionDurationMedium4 : 400
            easing.bezierCurve: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionEasingSoul !== 'undefined') ? MeoTheme.motionEasingSoul : [0.05, 0.7, 0.1, 1]
        }
    }

    // Top Section
    Column {
        id: topSection
        anchors.top: parent.top
        anchors.topMargin: 24 * control.themeGlobalScale
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        spacing: 12 * control.themeGlobalScale

        Loader {
            sourceComponent: control.header
            anchors.horizontalCenter: parent.horizontalCenter
            visible: control.header !== null
        }

        Item {
            width: 1
            height: 8 * control.themeGlobalScale
            visible: control.header !== null
        }

        Repeater {
            model: control.model
            delegate: Item {
                width: control.width
                height: control.isExpanded ? 56 * control.themeGlobalScale : 64 * control.themeGlobalScale

                readonly property bool isSelected: control.currentIndex === index

                Item {
                    id: wrapper
                    anchors.fill: parent
                    anchors.leftMargin: (control.isExpanded ? 12 : 0) * control.themeGlobalScale
                    anchors.rightMargin: (control.isExpanded ? 12 : 0) * control.themeGlobalScale

                    MeoShape {
                        id: selectionIndicator
                        width: control.isExpanded ? parent.width : (isSelected ? 56 * control.themeGlobalScale : 32 * control.themeGlobalScale)
                        height: 32 * control.themeGlobalScale
                        radius: 16 * control.themeGlobalScale
                        type: control.shape
                        color: isSelected ? control.themeSecondaryContainer : "transparent"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: control.isExpanded ? parent.verticalCenter : undefined
                        y: control.isExpanded ? (parent.height - height) / 2 : 0

                        Behavior on width { NumberAnimation { duration: 250; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingEmphasized !== "undefined") ? MeoTheme.motionEasingEmphasized : [0.05, 0.7, 0.1, 1] } }
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }

                    // Adaptive Layout: Column when collapsed, Row when expanded
                    Loader {
                        anchors.fill: parent
                        sourceComponent: control.isExpanded ? expandedLayout : collapsedLayout
                    }

                    Component {
                        id: collapsedLayout
                        Column {
                            anchors.centerIn: parent
                            spacing: 3 * control.themeGlobalScale

                            Item {
                                width: 24 * control.themeGlobalScale
                                height: 24 * control.themeGlobalScale
                                anchors.horizontalCenter: parent.horizontalCenter

                                MeoIcon {
                                    anchors.centerIn: parent
                                    icon: modelData.icon
                                    size: 24
                                    color: isSelected ? control.themeOnSecondaryContainer : control.themeOnSurfaceVariant
                                }

                                MeoBadge {
                                    text: modelData.badgeText || (modelData.badgeCount !== undefined ? modelData.badgeCount.toString() : "")
                                    isDot: modelData.badgeDot || false
                                    visible: text !== "" || isDot
                                    anchors.horizontalCenter: parent.right
                                    anchors.verticalCenter: parent.top
                                    anchors.horizontalCenterOffset: -2 * control.themeGlobalScale
                                    anchors.verticalCenterOffset: 2 * control.themeGlobalScale
                                }
                            }

                            Text {
                                text: modelData.label
                                font.family: (typeof MeoTheme !== "undefined" && MeoTheme.typefacePlain) ? MeoTheme.typefacePlain : "Roboto"
                                font.pixelSize: 12 * control.themeGlobalScale
                                font.weight: Font.Medium
                                color: isSelected ? control.themeOnSecondaryContainer : control.themeOnSurfaceVariant
                                anchors.horizontalCenter: parent.horizontalCenter
                                visible: (control.labelType === "always") || (control.labelType === "selected" && isSelected)
                            }
                        }
                    }

                    Component {
                        id: expandedLayout
                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 16 * control.themeGlobalScale
                            spacing: 12 * control.themeGlobalScale

                            Item {
                                width: 24 * control.themeGlobalScale
                                height: 24 * control.themeGlobalScale
                                anchors.verticalCenter: parent.verticalCenter

                                MeoIcon {
                                    anchors.centerIn: parent
                                    icon: modelData.icon
                                    size: 24
                                    color: isSelected ? control.themeOnSecondaryContainer : control.themeOnSurfaceVariant
                                }

                                MeoBadge {
                                    text: modelData.badgeText || (modelData.badgeCount !== undefined ? modelData.badgeCount.toString() : "")
                                    isDot: modelData.badgeDot || false
                                    visible: text !== "" || isDot
                                    anchors.horizontalCenter: parent.right
                                    anchors.verticalCenter: parent.top
                                    anchors.horizontalCenterOffset: -2 * control.themeGlobalScale
                                    anchors.verticalCenterOffset: 2 * control.themeGlobalScale
                                }
                            }

                            Text {
                                text: modelData.label
                                font.family: (typeof MeoTheme !== "undefined" && MeoTheme.typefacePlain) ? MeoTheme.typefacePlain : "Roboto"
                                font.pixelSize: fontLabelLarge.size * control.themeGlobalScale
                                font.weight: isSelected ? Font.Bold : fontLabelLarge.weight
                                color: isSelected ? control.themeOnSecondaryContainer : control.themeOnSurfaceVariant
                                anchors.verticalCenter: parent.verticalCenter
                                elide: Text.ElideRight
                                width: parent.width - 24 * control.themeGlobalScale - 28 * control.themeGlobalScale
                            }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        control.currentIndex = index
                        control.clicked(index)
                    }
                }
            }
        }
    }

    // Bottom Section
    Loader {
        id: footerLoader
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 24 * control.themeGlobalScale
        anchors.horizontalCenter: parent.horizontalCenter
        sourceComponent: control.footer
        visible: control.footer !== null
    }
}

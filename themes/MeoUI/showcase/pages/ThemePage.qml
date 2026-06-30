import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI

pragma ComponentBehavior: Bound

Flickable {
    id: page

    readonly property bool isDarkMode: MeoTheme.isDarkMode
    readonly property real themeGlobalScale: MeoTheme.globalScale
    property string colorSource: "fallback"

    readonly property var oceanLightScheme: ({
        "primary": "#006A6A", "onPrimary": "#FFFFFF",
        "primaryContainer": "#9CF1F0", "onPrimaryContainer": "#002020",
        "secondary": "#4A6363", "onSecondary": "#FFFFFF",
        "secondaryContainer": "#CCE8E7", "onSecondaryContainer": "#051F1F",
        "tertiary": "#4B607C", "onTertiary": "#FFFFFF",
        "tertiaryContainer": "#D3E4FF", "onTertiaryContainer": "#041C35"
    })
    readonly property var oceanDarkScheme: ({
        "primary": "#80D5D3", "onPrimary": "#003737",
        "primaryContainer": "#004F4F", "onPrimaryContainer": "#9CF1F0",
        "secondary": "#B1CCCB", "onSecondary": "#1C3535",
        "secondaryContainer": "#334B4B", "onSecondaryContainer": "#CCE8E7",
        "tertiary": "#B3C8E8", "onTertiary": "#1C314B",
        "tertiaryContainer": "#344864", "onTertiaryContainer": "#D3E4FF"
    })
    readonly property var sunsetLightScheme: ({
        "primary": "#8C4A60", "onPrimary": "#FFFFFF",
        "primaryContainer": "#FFD9E2", "onPrimaryContainer": "#3A071D",
        "secondary": "#74565F", "onSecondary": "#FFFFFF",
        "secondaryContainer": "#FFD9E2", "onSecondaryContainer": "#2B151C",
        "tertiary": "#7C5635", "onTertiary": "#FFFFFF",
        "tertiaryContainer": "#FFDCC1", "onTertiaryContainer": "#2D1600"
    })
    readonly property var sunsetDarkScheme: ({
        "primary": "#FFB0C8", "onPrimary": "#541D32",
        "primaryContainer": "#703348", "onPrimaryContainer": "#FFD9E2",
        "secondary": "#E3BDC7", "onSecondary": "#422932",
        "secondaryContainer": "#5A3F47", "onSecondaryContainer": "#FFD9E2",
        "tertiary": "#EEBD91", "onTertiary": "#47290C",
        "tertiaryContainer": "#613F20", "onTertiaryContainer": "#FFDCC1"
    })

    function schemeForSource(source) {
        if (source === "ocean")
            return isDarkMode ? oceanDarkScheme : oceanLightScheme
        if (source === "sunset")
            return isDarkMode ? sunsetDarkScheme : sunsetLightScheme
        return null
    }

    function applyColorSource(source) {
        colorSource = source
        const scheme = schemeForSource(source)
        if (scheme)
            MeoTheme.applyDynamicColorScheme(scheme)
        else
            MeoTheme.clearDynamicColorScheme()
    }

    onIsDarkModeChanged: applyColorSource(colorSource)

    contentWidth: width
    contentHeight: contentColumn.implicitHeight + 48 * themeGlobalScale
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    ScrollBar.vertical: ScrollBar {}

    ColumnLayout {
        id: contentColumn
        width: page.width - 48 * page.themeGlobalScale
        x: 24 * page.themeGlobalScale
        y: 24 * page.themeGlobalScale
        spacing: 24 * page.themeGlobalScale

        // 🔤 Theme introduction
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4 * page.themeGlobalScale

            Text {
                text: "MeoTheme"
                color: MeoTheme.contentOnSurface
                font.pixelSize: MeoTheme.headlineLargeEmphasized.size * page.themeGlobalScale
                font.weight: MeoTheme.headlineLargeEmphasized.weight
            }
            Text {
                Layout.fillWidth: true
                text: "Live MD3 design tokens — color, type, shape, scale and motion in one place."
                color: MeoTheme.contentOnSurfaceVariant
                font.pixelSize: MeoTheme.bodyLarge.size * page.themeGlobalScale
                font.weight: MeoTheme.bodyLarge.weight
                wrapMode: Text.WordWrap
            }
        }

        // 🎨 Live theme controls
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: controlsColumn.implicitHeight + 32 * page.themeGlobalScale
            radius: MeoTheme.shapeExtraLarge
            color: MeoTheme.surfaceContainerLow

            Behavior on color {
                ColorAnimation { duration: 150; easing.bezierCurve: [0.34, 0.8, 0.34, 1.0] }
            }

            ColumnLayout {
                id: controlsColumn
                anchors.fill: parent
                anchors.margins: 16 * page.themeGlobalScale
                spacing: 16 * page.themeGlobalScale

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12 * page.themeGlobalScale

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2 * page.themeGlobalScale
                        Text {
                            text: "Appearance"
                            color: MeoTheme.contentOnSurface
                            font.pixelSize: MeoTheme.titleMedium.size * page.themeGlobalScale
                            font.weight: MeoTheme.titleMedium.weight
                        }
                        Text {
                            text: page.isDarkMode ? "Dark theme" : "Light theme"
                            color: MeoTheme.contentOnSurfaceVariant
                            font.pixelSize: MeoTheme.bodyMedium.size * page.themeGlobalScale
                        }
                    }
                    MeoSwitch {
                        checked: page.isDarkMode
                        icon: "dark_mode"
                        uncheckedIcon: "light_mode"
                        onToggled: (checked) => { MeoTheme.isDarkMode = checked }
                    }
                }

                MeoDivider { Layout.fillWidth: true }

                Text {
                    text: "Color source"
                    color: MeoTheme.contentOnSurface
                    font.pixelSize: MeoTheme.titleMedium.size * page.themeGlobalScale
                    font.weight: MeoTheme.titleMedium.weight
                }
                Flow {
                    Layout.fillWidth: true
                    spacing: 8 * page.themeGlobalScale

                    MeoButton {
                        text: "Meo fallback"
                        type: page.colorSource === "fallback" ? "filled" : "outlined"
                        icon.name: "palette"
                        onClicked: page.applyColorSource("fallback")
                    }
                    MeoButton {
                        text: "Ocean"
                        type: page.colorSource === "ocean" ? "filled" : "outlined"
                        icon.name: "water"
                        onClicked: page.applyColorSource("ocean")
                    }
                    MeoButton {
                        text: "Sunset"
                        type: page.colorSource === "sunset" ? "filled" : "outlined"
                        icon.name: "wb_twilight"
                        onClicked: page.applyColorSource("sunset")
                    }
                }

                Text {
                    text: "Interface scale  ·  " + Math.round(page.themeGlobalScale * 100) + "%"
                    color: MeoTheme.contentOnSurface
                    font.pixelSize: MeoTheme.titleMedium.size * page.themeGlobalScale
                    font.weight: MeoTheme.titleMedium.weight
                }
                MeoSlider {
                    Layout.fillWidth: true
                    from: 80
                    to: 130
                    value: page.themeGlobalScale * 100
                    discrete: true
                    stepSize: 5
                    onMoved: (value) => { MeoTheme.globalScale = value / 100 }
                }

                MeoDivider { Layout.fillWidth: true }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12 * page.themeGlobalScale

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2 * page.themeGlobalScale
                        Text {
                            text: "Expressive Mode"
                            color: MeoTheme.contentOnSurface
                            font.pixelSize: MeoTheme.titleMedium.size * page.themeGlobalScale
                            font.weight: MeoTheme.titleMedium.weight
                        }
                        Text {
                            text: MeoTheme.isExpressive ? "Enabled" : "Disabled"
                            color: MeoTheme.contentOnSurfaceVariant
                            font.pixelSize: MeoTheme.bodyMedium.size * page.themeGlobalScale
                        }
                    }
                    MeoSwitch {
                        checked: MeoTheme.isExpressive
                        icon: "auto_awesome"
                        onToggled: (checked) => { MeoTheme.isExpressive = checked }
                    }
                }
            }
        }

        // 🎨 MD3 semantic color roles
        SectionTitle { title: "Semantic color roles"; subtitle: "Each pair keeps content readable on its container." }
        Flow {
            Layout.fillWidth: true
            spacing: 12 * page.themeGlobalScale

            ColorRole { roleName: "Primary"; containerColor: MeoTheme.primary; contentColor: MeoTheme.contentOnPrimary }
            ColorRole { roleName: "Primary container"; containerColor: MeoTheme.primaryContainer; contentColor: MeoTheme.contentOnPrimaryContainer }
            ColorRole { roleName: "Secondary"; containerColor: MeoTheme.secondary; contentColor: MeoTheme.contentOnSecondary }
            ColorRole { roleName: "Secondary container"; containerColor: MeoTheme.secondaryContainer; contentColor: MeoTheme.contentOnSecondaryContainer }
            ColorRole { roleName: "Tertiary"; containerColor: MeoTheme.tertiary; contentColor: MeoTheme.contentOnTertiary }
            ColorRole { roleName: "Tertiary container"; containerColor: MeoTheme.tertiaryContainer; contentColor: MeoTheme.contentOnTertiaryContainer }
            ColorRole { roleName: "Error"; containerColor: MeoTheme.error; contentColor: MeoTheme.contentOnError }
            ColorRole { roleName: "Error container"; containerColor: MeoTheme.errorContainer; contentColor: MeoTheme.contentOnErrorContainer }
        }

        // 🔤 MD3 type scale
        SectionTitle { title: "Typography"; subtitle: "Standard and emphasized roles share the same responsive scale." }
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: typeColumn.implicitHeight + 32 * page.themeGlobalScale
            radius: MeoTheme.shapeLarge
            color: MeoTheme.surfaceContainer

            ColumnLayout {
                id: typeColumn
                anchors.fill: parent
                anchors.margins: 16 * page.themeGlobalScale
                spacing: 10 * page.themeGlobalScale

                TypeSample { sampleText: "Display small"; token: MeoTheme.displaySmall }
                TypeSample { sampleText: "Headline medium"; token: MeoTheme.headlineMedium }
                TypeSample { sampleText: "Title large emphasized"; token: MeoTheme.titleLargeEmphasized }
                TypeSample { sampleText: "Body large — designed to stay comfortable at every scale."; token: MeoTheme.bodyLarge }
                TypeSample { sampleText: "LABEL MEDIUM"; token: MeoTheme.labelMedium }
            }
        }

        // 📐 Shape scale and 🖼️ motion preview
        SectionTitle { title: "Shape & motion"; subtitle: "Hover or press the interactive sample to see the 150 ms Soul Curve." }
        RowLayout {
            Layout.fillWidth: true
            spacing: 16 * page.themeGlobalScale

            Repeater {
                model: [
                    { "name": "Small", "radius": MeoTheme.shapeSmall },
                    { "name": "Large", "radius": MeoTheme.shapeLarge },
                    { "name": "Extra large", "radius": MeoTheme.shapeExtraLarge }
                ]
                delegate: Rectangle {
                    id: shapeSample
                    required property var modelData
                    Layout.fillWidth: true
                    implicitHeight: 96 * page.themeGlobalScale
                    radius: modelData.radius
                    color: shapeMouse.pressed ? MeoTheme.primary : (shapeMouse.containsMouse ? MeoTheme.primaryContainer : MeoTheme.surfaceContainerHighest)
                    scale: shapeMouse.pressed ? 0.96 : 1.0

                    Text {
                        anchors.centerIn: parent
                        text: shapeSample.modelData.name
                        color: shapeMouse.pressed ? MeoTheme.contentOnPrimary : MeoTheme.contentOnSurface
                        font.pixelSize: MeoTheme.labelLarge.size * page.themeGlobalScale
                        font.weight: MeoTheme.labelLarge.weight
                        Behavior on color { ColorAnimation { duration: 150; easing.bezierCurve: [0.34, 0.8, 0.34, 1.0] } }
                    }
                    MouseArea { id: shapeMouse; anchors.fill: parent; hoverEnabled: true }
                    Behavior on color { ColorAnimation { duration: 150; easing.bezierCurve: [0.34, 0.8, 0.34, 1.0] } }
                    Behavior on scale { NumberAnimation { duration: 150; easing.bezierCurve: [0.34, 0.8, 0.34, 1.0] } }
                }
            }
        }
    }

    component SectionTitle: ColumnLayout {
        property string title: ""
        property string subtitle: ""
        Layout.fillWidth: true
        spacing: 2 * page.themeGlobalScale
        Text {
            text: parent.title
            color: MeoTheme.primary
            font.pixelSize: MeoTheme.headlineSmall.size * page.themeGlobalScale
            font.weight: MeoTheme.headlineSmallEmphasized.weight
        }
        Text {
            Layout.fillWidth: true
            text: parent.subtitle
            color: MeoTheme.contentOnSurfaceVariant
            font.pixelSize: MeoTheme.bodyMedium.size * page.themeGlobalScale
            wrapMode: Text.WordWrap
        }
    }

    component ColorRole: Rectangle {
        id: colorRole
        property string roleName: ""
        property color containerColor: "transparent"
        property color contentColor: "transparent"
        width: 196 * page.themeGlobalScale
        height: 104 * page.themeGlobalScale
        radius: MeoTheme.shapeLarge
        color: containerColor

        Column {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: 12 * page.themeGlobalScale
            spacing: 2 * page.themeGlobalScale
            Text {
                text: colorRole.roleName
                color: colorRole.contentColor
                font.pixelSize: MeoTheme.labelLarge.size * page.themeGlobalScale
                font.weight: MeoTheme.labelLarge.weight
            }
            Text {
                text: colorRole.containerColor.toString().toUpperCase()
                color: colorRole.contentColor
                opacity: 0.76
                font.pixelSize: MeoTheme.bodySmall.size * page.themeGlobalScale
            }
        }
        Behavior on color { ColorAnimation { duration: 150; easing.bezierCurve: [0.34, 0.8, 0.34, 1.0] } }
    }

    component TypeSample: Text {
        required property var token
        property string sampleText: ""
        Layout.fillWidth: true
        text: sampleText
        color: MeoTheme.contentOnSurface
        font.pixelSize: token.size * page.themeGlobalScale
        font.weight: token.weight
        font.letterSpacing: token.letterSpacing * page.themeGlobalScale
        wrapMode: Text.WordWrap
    }
}

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI

MeoPageLayout {
    id: page
    title: "MeoTheme"
    subtitle: "Live MD3 design tokens: color, type, shape, scale, and motion in one place."

    property string colorSource: "fallback"
    readonly property real s: MeoTheme.globalScale

    readonly property var oceanLightScheme: ({ "primary": "#006A6A", "onPrimary": "#FFFFFF", "primaryContainer": "#9CF1F0", "onPrimaryContainer": "#002020", "secondary": "#4A6363", "onSecondary": "#FFFFFF", "secondaryContainer": "#CCE8E7", "onSecondaryContainer": "#051F1F", "tertiary": "#4B607C", "onTertiary": "#FFFFFF", "tertiaryContainer": "#D3E4FF", "onTertiaryContainer": "#041C35" })
    readonly property var oceanDarkScheme: ({ "primary": "#80D5D3", "onPrimary": "#003737", "primaryContainer": "#004F4F", "onPrimaryContainer": "#9CF1F0", "secondary": "#B1CCCB", "onSecondary": "#1C3535", "secondaryContainer": "#334B4B", "onSecondaryContainer": "#CCE8E7", "tertiary": "#B3C8E8", "onTertiary": "#1C314B", "tertiaryContainer": "#344864", "onTertiaryContainer": "#D3E4FF" })
    readonly property var sunsetLightScheme: ({ "primary": "#8C4A60", "onPrimary": "#FFFFFF", "primaryContainer": "#FFD9E2", "onPrimaryContainer": "#3A071D", "secondary": "#74565F", "onSecondary": "#FFFFFF", "secondaryContainer": "#FFD9E2", "onSecondaryContainer": "#2B151C", "tertiary": "#7C5635", "onTertiary": "#FFFFFF", "tertiaryContainer": "#FFDCC1", "onTertiaryContainer": "#2D1600" })
    readonly property var sunsetDarkScheme: ({ "primary": "#FFB0C8", "onPrimary": "#541D32", "primaryContainer": "#703348", "onPrimaryContainer": "#FFD9E2", "secondary": "#E3BDC7", "onSecondary": "#422932", "secondaryContainer": "#5A3F47", "onSecondaryContainer": "#FFD9E2", "tertiary": "#EEBD91", "onTertiary": "#47290C", "tertiaryContainer": "#613F20", "onTertiaryContainer": "#FFDCC1" })

    function schemeForSource(source) {
        if (source === "ocean")
            return MeoTheme.isDarkMode ? oceanDarkScheme : oceanLightScheme
        if (source === "sunset")
            return MeoTheme.isDarkMode ? sunsetDarkScheme : sunsetLightScheme
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

    Connections {
        target: MeoTheme
        function onIsDarkModeChanged() { page.applyColorSource(page.colorSource) }
    }

    Rectangle {
        width: parent.width
        implicitHeight: controlsColumn.implicitHeight + 32 * page.s
        radius: MeoTheme.shapeLarge
        color: MeoTheme.surfaceContainerLow

        ColumnLayout {
            id: controlsColumn
            anchors.fill: parent
            anchors.margins: 16 * page.s
            spacing: 16 * page.s

            RowLayout {
                Layout.fillWidth: true
                ColumnLayout {
                    Layout.fillWidth: true
                    MeoText { text: "Appearance"; typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface }
                    MeoText { text: MeoTheme.isDarkMode ? "Dark theme" : "Light theme"; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant }
                }
                MeoSwitch { checked: MeoTheme.isDarkMode; icon: "dark_mode"; uncheckedIcon: "light_mode"; onToggled: (checked) => { MeoTheme.isDarkMode = checked } }
            }

            MeoDivider { Layout.fillWidth: true }

            MeoText { text: "Color source"; typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface }
            Flow {
                Layout.fillWidth: true
                spacing: 8 * page.s
                MeoButton { text: "Meo fallback"; type: page.colorSource === "fallback" ? "filled" : "outlined"; icon.name: "palette"; onClicked: page.applyColorSource("fallback") }
                MeoButton { text: "Ocean"; type: page.colorSource === "ocean" ? "filled" : "outlined"; icon.name: "water"; onClicked: page.applyColorSource("ocean") }
                MeoButton { text: "Sunset"; type: page.colorSource === "sunset" ? "filled" : "outlined"; icon.name: "wb_twilight"; onClicked: page.applyColorSource("sunset") }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8 * page.s
                PreviewSwatch { name: "Primary"; value: MeoTheme.primary; contentColor: MeoTheme.contentOnPrimary }
                PreviewSwatch { name: "Secondary"; value: MeoTheme.secondary; contentColor: MeoTheme.contentOnSecondary }
                PreviewSwatch { name: "Tertiary"; value: MeoTheme.tertiary; contentColor: MeoTheme.contentOnTertiary }
            }

            MeoText { text: "Interface scale  ·  " + Math.round(MeoTheme.globalScale * 100) + "%"; typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface }
            MeoSlider { Layout.fillWidth: true; from: 80; to: 140; value: MeoTheme.globalScale * 100; discrete: true; stepSize: 5; onMoved: (value) => { MeoTheme.globalScale = value / 100 } }
            RowLayout {
                Layout.fillWidth: true
                Repeater {
                    model: ["80%", "100%", "120%", "140%"]
                    delegate: MeoText { required property string modelData; Layout.fillWidth: true; text: modelData; horizontalAlignment: Text.AlignHCenter; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
                }
            }

            MeoDivider { Layout.fillWidth: true }
            RowLayout {
                Layout.fillWidth: true
                ColumnLayout {
                    Layout.fillWidth: true
                    MeoText { text: "Expressive Mode"; typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface }
                    MeoText { text: MeoTheme.isExpressive ? "Enabled" : "Disabled"; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant }
                }
                MeoSwitch { checked: MeoTheme.isExpressive; icon: "auto_awesome"; onToggled: (checked) => { MeoTheme.isExpressive = checked } }
            }
        }
    }

    SectionTitle { title: "Semantic color roles"; subtitle: "Current theme roles shown as readable container/content pairs." }
    Flow {
        width: parent.width
        spacing: 12 * page.s
        ColorRole { roleName: "Primary"; containerColor: MeoTheme.primary; contentColor: MeoTheme.contentOnPrimary }
        ColorRole { roleName: "On primary"; containerColor: MeoTheme.contentOnPrimary; contentColor: MeoTheme.primary }
        ColorRole { roleName: "Primary container"; containerColor: MeoTheme.primaryContainer; contentColor: MeoTheme.contentOnPrimaryContainer }
        ColorRole { roleName: "Secondary"; containerColor: MeoTheme.secondary; contentColor: MeoTheme.contentOnSecondary }
        ColorRole { roleName: "Secondary container"; containerColor: MeoTheme.secondaryContainer; contentColor: MeoTheme.contentOnSecondaryContainer }
        ColorRole { roleName: "Tertiary"; containerColor: MeoTheme.tertiary; contentColor: MeoTheme.contentOnTertiary }
        ColorRole { roleName: "Tertiary container"; containerColor: MeoTheme.tertiaryContainer; contentColor: MeoTheme.contentOnTertiaryContainer }
        ColorRole { roleName: "Error"; containerColor: MeoTheme.error; contentColor: MeoTheme.contentOnError }
        ColorRole { roleName: "Error container"; containerColor: MeoTheme.errorContainer; contentColor: MeoTheme.contentOnErrorContainer }
        ColorRole { roleName: "Surface"; containerColor: MeoTheme.surface; contentColor: MeoTheme.contentOnSurface }
        ColorRole { roleName: "Surface variant"; containerColor: MeoTheme.surfaceVariant; contentColor: MeoTheme.contentOnSurfaceVariant }
        ColorRole { roleName: "Outline"; containerColor: MeoTheme.outline; contentColor: MeoTheme.surface }
    }

    SectionTitle { title: "Typography"; subtitle: "Comfortaa is reserved for brand and page titles; Roboto handles UI, body, controls, and data." }
    Rectangle {
        width: parent.width
        implicitHeight: typeColumn.implicitHeight + 32 * page.s
        radius: MeoTheme.shapeLarge
        color: MeoTheme.surfaceContainer
        Column {
            id: typeColumn
            anchors.fill: parent
            anchors.margins: 16 * page.s
            spacing: 10 * page.s
            MeoText { text: "Page title / Comfortaa Bold"; typeRole: "title"; typeSize: "big"; emphasized: true; color: MeoTheme.contentOnSurface }
            MeoText { text: "Section title / Roboto Bold"; typeRole: "title"; typeSize: "medium"; emphasized: true; color: MeoTheme.contentOnSurface }
            MeoText { text: "Body text / Roboto Regular keeps mixed UI copy readable."; typeRole: "body"; typeSize: "big"; color: MeoTheme.contentOnSurfaceVariant; wrapMode: Text.WordWrap }
            MeoText { text: "Component label / Roboto Medium"; typeRole: "label"; typeSize: "big"; color: MeoTheme.primary }
        }
    }

    SectionTitle { title: "Shape & motion"; subtitle: "Interactive samples use semantic motion tokens instead of hard-coded duration values." }
    RowLayout {
        width: parent.width
        spacing: 16 * page.s
        Repeater {
            model: [
                { "name": "Small", "radius": MeoTheme.shapeSmall },
                { "name": "Large", "radius": MeoTheme.shapeLarge },
                { "name": "Extra large", "radius": MeoTheme.shapeExtraLarge }
            ]
            delegate: Rectangle {
                required property var modelData
                Layout.fillWidth: true
                implicitHeight: 96 * page.s
                radius: modelData.radius
                color: shapeMouse.pressed ? MeoTheme.primary : (shapeMouse.containsMouse ? MeoTheme.primaryContainer : MeoTheme.surfaceContainerHighest)
                scale: shapeMouse.pressed ? 0.96 : 1.0
                MeoText { anchors.centerIn: parent; text: modelData.name; typeRole: "label"; typeSize: "big"; color: shapeMouse.pressed ? MeoTheme.contentOnPrimary : MeoTheme.contentOnSurface }
                MouseArea { id: shapeMouse; anchors.fill: parent; hoverEnabled: true }
                Behavior on color { ColorAnimation { duration: MeoTheme.motionDurationFast; easing.bezierCurve: MeoTheme.motionEasingSoul } }
                Behavior on scale { NumberAnimation { duration: MeoTheme.motionDurationFast; easing.bezierCurve: MeoTheme.motionEasingSoul } }
            }
        }
    }

    component SectionTitle: Column {
        property string title: ""
        property string subtitle: ""
        width: parent.width
        spacing: 2 * page.s
        MeoText { text: parent.title; typeRole: "title"; typeSize: "medium"; emphasized: true; color: MeoTheme.contentOnSurface }
        MeoText { width: parent.width; text: parent.subtitle; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant; wrapMode: Text.WordWrap }
    }

    component ColorRole: Rectangle {
        property string roleName: ""
        property color containerColor: "transparent"
        property color contentColor: "transparent"
        width: 196 * page.s
        height: 104 * page.s
        radius: MeoTheme.shapeLarge
        color: containerColor
        Column {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: 12 * page.s
            spacing: 2 * page.s
            MeoText { text: parent.parent.roleName; typeRole: "label"; typeSize: "big"; color: parent.parent.contentColor }
            MeoText { text: parent.parent.containerColor.toString().toUpperCase(); typeRole: "body"; typeSize: "small"; color: parent.parent.contentColor; opacity: 0.76 }
        }
    }

    component PreviewSwatch: Rectangle {
        property string name: ""
        property color value: "transparent"
        property color contentColor: "#FFFFFF"
        Layout.fillWidth: true
        implicitHeight: 64 * page.s
        radius: MeoTheme.shapeMedium
        color: value
        MeoText { anchors.centerIn: parent; text: parent.name + "  " + parent.value.toString().toUpperCase(); typeRole: "label"; typeSize: "medium"; color: parent.contentColor }
    }
}

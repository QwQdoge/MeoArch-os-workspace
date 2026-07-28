import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import MeoUI

MeoCard {
    id: control

    // We override padding to 0 so we can have full-bleed media touching card edges.
    padding: 0

    // Size variants: "s" | "m" | "l"
    property string cardSize: "m"

    // Media properties
    property string mediaSource: ""
    property real aspectRatio: 16/9
    property string mediaPosition: "top" // "top" | "bottom" | "left" | "right"

    // Header properties
    property string headerTitle: ""
    property string headerSubtitle: ""
    property string avatarSource: ""
    property string avatarInitials: ""
    property bool showOverflowButton: false

    // Card text content
    property string title: ""
    property string supportingText: ""

    // Action buttons model
    // Format: [{ "label": "Action 1", "icon": "favorite", "type": "text", "enabled": true }]
    property var actions: []

    // Thickness token overrides (for card border styling in Outlined variants)
    property string thickness: "thin" // "thin" | "medium" | "thick"

    // Signals
    signal actionClicked(int index, string label)
    signal overflowClicked()

    readonly property real strokeWidthValue: {
        if (thickness === "medium") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.strokeWidthMedium !== 'undefined') ? MeoTheme.strokeWidthMedium : 2 * themeGlobalScale;
        if (thickness === "thick") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.strokeWidthThick !== 'undefined') ? MeoTheme.strokeWidthThick : 3 * themeGlobalScale;
        return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.strokeWidthThin !== 'undefined') ? MeoTheme.strokeWidthThin : 1 * themeGlobalScale;
    }

    implicitWidth: {
        if (mediaPosition === "left" || mediaPosition === "right") {
            if (cardSize === "s") return 300 * themeGlobalScale;
            if (cardSize === "l") return 460 * themeGlobalScale;
            return 380 * themeGlobalScale; // m
        } else {
            if (cardSize === "s") return 240 * themeGlobalScale;
            if (cardSize === "l") return 400 * themeGlobalScale;
            return 320 * themeGlobalScale; // m
        }
    }

    implicitHeight: {
        if (mediaPosition === "left" || mediaPosition === "right") {
            if (cardSize === "s") return 120 * themeGlobalScale;
            if (cardSize === "l") return 200 * themeGlobalScale;
            return 160 * themeGlobalScale; // m
        } else {
            return layoutLoader.item ? layoutLoader.item.implicitHeight : 200 * themeGlobalScale;
        }
    }

    background: Item {
        MeoShape {
            id: shapeBg
            anchors.fill: parent
            type: control.shape
            radius: (typeof mouseArea !== 'undefined' && mouseArea.pressed)
                    ? ((typeof MeoTheme !== 'undefined' && MeoTheme.shapeMedium) ? MeoTheme.shapeMedium : control.radius)
                    : (typeof mouseArea !== 'undefined' && mouseArea.containsMouse) && control.interactive
                      ? ((typeof MeoTheme !== 'undefined' && MeoTheme.shapeLargeIncreased) ? MeoTheme.shapeLargeIncreased : control.radius)
                    : control.selected
                      ? ((typeof MeoTheme !== 'undefined' && MeoTheme.shapeLargeIncreased) ? MeoTheme.shapeLargeIncreased : control.radius)
                      : control.radius
            color: {
                if (control.selected) return (typeof MeoTheme !== 'undefined' && MeoTheme.primaryContainer) ? MeoTheme.primaryContainer : control.themeSurfaceContainerHighest
                if (control.type === "filled") return control.themeSurfaceContainerHighest
                if (control.type === "elevated") return control.themeSurfaceContainerLow
                return control.themeSurface
            }
            strokeColor: control.selected ? ((typeof MeoTheme !== 'undefined' && MeoTheme.primary) ? MeoTheme.primary : control.themeOutlineVariant)
                                          : control.type === "outlined" ? control.themeOutlineVariant : "transparent"
            strokeWidth: control.selected ? ((typeof MeoTheme !== 'undefined' && typeof MeoTheme.strokeWidthMedium !== 'undefined') ? MeoTheme.strokeWidthMedium : 2 * control.themeGlobalScale)
                                          : control.type === "outlined" ? control.strokeWidthValue : 0

            scale: control.interactive && control.bouncy ? ((typeof mouseArea !== 'undefined' && mouseArea.pressed) ? 0.97 : ((typeof mouseArea !== 'undefined' && mouseArea.containsMouse) ? 1.015 : 1.0)) : 1.0

            Behavior on scale {
                NumberAnimation {
                    duration: control.motionFast
                    easing.bezierCurve: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionEasingSoul !== 'undefined') ? MeoTheme.motionEasingSoul : [0.34, 1.56, 0.64, 1.0]
                }
            }

            // Surface Tint for Elevation
            Rectangle {
                anchors.fill: parent
                color: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceTint !== 'undefined') ? MeoTheme.surfaceTint(control.level) : "transparent"
                visible: control.type === "elevated" && control.level > 0
                Behavior on color { ColorAnimation { duration: control.motionFast } }

                layer.enabled: visible && control.visible
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: Item {
                        width: shapeBg.width
                        height: shapeBg.height
                        MeoShape {
                            anchors.fill: parent
                            type: control.shape
                            radius: control.radius
                        }
                    }
                }
            }

            // MD3 Elevation for 'elevated' type
            layer.enabled: control.visible && control.elevation > 0
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowBlur: control.elevation * 0.2
                shadowVerticalOffset: control.elevation * 1.2 * control.themeGlobalScale
                shadowOpacity: 0.2 + control.elevation * 0.02
                shadowColor: Qt.rgba(0,0,0,0.2)
            }

            MeoStateLayer {
                id: stateLayer
                anchors.fill: parent
                radius: shapeBg.radius
                shape: shapeBg.type
                visible: control.interactive
                pressed: (typeof mouseArea !== 'undefined') ? mouseArea.pressed : false
                hovered: (typeof mouseArea !== 'undefined') ? mouseArea.containsMouse : false
                focused: control.activeFocus
                pressX: (typeof mouseArea !== 'undefined') ? mouseArea.mouseX : width / 2
                pressY: (typeof mouseArea !== 'undefined') ? mouseArea.mouseY : height / 2
                color: control.isDarkMode ? "#FFFFFF" : "#000000"
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                enabled: control.interactive
                hoverEnabled: true
                onClicked: {
                    control.forceActiveFocus(Qt.MouseFocusReason)
                    control.clicked()
                }
            }

            Behavior on color { ColorAnimation { duration: control.motionFast } }
            Behavior on radius {
                NumberAnimation {
                    duration: (typeof mouseArea !== 'undefined' && mouseArea.containsMouse) || (typeof mouseArea !== 'undefined' && mouseArea.pressed) ? MeoTheme.motionDurationShapeEnter : MeoTheme.motionDurationShapeSettle
                    easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
                }
            }
        }
    }

    contentItem: Item {
        id: cardContentContainer

        // Selected indicator overlay (MD3 standard checkbox in top-right corner)
        Rectangle {
            id: selectedIndicator
            width: 24 * themeGlobalScale
            height: 24 * themeGlobalScale
            radius: width / 2
            color: MeoTheme.primary
            border.color: MeoTheme.contentOnPrimary
            border.width: 1.5 * themeGlobalScale
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 12 * themeGlobalScale
            anchors.rightMargin: 12 * themeGlobalScale
            z: 10
            visible: control.selected

            MeoIcon {
                anchors.centerIn: parent
                icon: "check"
                size: 14
                color: MeoTheme.contentOnPrimary
            }
        }

        Loader {
            id: layoutLoader
            anchors.fill: parent
            sourceComponent: (control.mediaPosition === "left" || control.mediaPosition === "right")
                             ? horizontalLayoutComponent
                             : verticalLayoutComponent
        }
    }

    // Vertical Layout
    Component {
        id: verticalLayoutComponent
        ColumnLayout {
            spacing: 0

            // 1. Header (if above media)
            Item {
                id: headerItem
                Layout.fillWidth: true
                Layout.preferredHeight: headerRow.implicitHeight + 24 * themeGlobalScale
                visible: control.headerTitle !== "" || control.avatarSource !== "" || control.avatarInitials !== ""

                RowLayout {
                    id: headerRow
                    anchors.fill: parent
                    anchors.margins: 16 * themeGlobalScale
                    spacing: 12 * themeGlobalScale

                    MeoAvatar {
                        Layout.alignment: Qt.AlignVCenter
                        size: 40
                        source: control.avatarSource
                        initials: control.avatarInitials
                        visible: control.avatarSource !== "" || control.avatarInitials !== ""
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2 * themeGlobalScale
                        MeoText {
                            Layout.fillWidth: true
                            text: control.headerTitle
                            typeRole: "title"
                            typeSize: "small"
                            emphasized: true
                        }
                        MeoText {
                            Layout.fillWidth: true
                            text: control.headerSubtitle
                            typeRole: "body"
                            typeSize: "small"
                            color: MeoTheme.contentOnSurfaceVariant
                            visible: control.headerSubtitle !== ""
                        }
                    }

                    MeoIconButton {
                        Layout.alignment: Qt.AlignVCenter
                        icon.name: "more_vert"
                        type: "standard"
                        visible: control.showOverflowButton
                        onClicked: control.overflowClicked()
                    }
                }
            }

            // 2. Media Image (if top)
            Item {
                id: mediaTopContainer
                Layout.fillWidth: true
                Layout.preferredHeight: width / control.aspectRatio
                visible: control.mediaSource !== "" && control.mediaPosition === "top"

                Image {
                    anchors.fill: parent
                    source: control.mediaSource
                    fillMode: Image.PreserveAspectCrop
                }

                // Hover / pressed state overlay for media
                MeoStateLayer {
                    anchors.fill: parent
                    pressed: (typeof mouseArea !== 'undefined') ? mouseArea.pressed : false
                    hovered: (typeof mouseArea !== 'undefined') ? mouseArea.containsMouse : false
                    focused: control.activeFocus
                    visible: control.interactive
                }

                // Masking to parent shape
                layer.enabled: true
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: Item {
                        width: mediaTopContainer.width
                        height: mediaTopContainer.height
                        MeoShape {
                            anchors.fill: parent
                            type: control.shape
                            radius: control.radius
                        }
                    }
                }
            }

            // 3. Main Card Text & Content
            ColumnLayout {
                Layout.fillWidth: true
                Layout.margins: 16 * themeGlobalScale
                spacing: 8 * themeGlobalScale
                visible: control.title !== "" || control.supportingText !== ""

                MeoText {
                    Layout.fillWidth: true
                    text: control.title
                    typeRole: "title"
                    typeSize: control.cardSize === "l" ? "medium" : "small"
                    emphasized: true
                    visible: text !== ""
                }

                MeoText {
                    Layout.fillWidth: true
                    text: control.supportingText
                    typeRole: "body"
                    typeSize: control.cardSize === "l" ? "medium" : "small"
                    color: MeoTheme.contentOnSurfaceVariant
                    visible: text !== ""
                    wrapMode: Text.WordWrap
                }
            }

            // 4. Media Image (if bottom)
            Item {
                id: mediaBottomContainer
                Layout.fillWidth: true
                Layout.preferredHeight: width / control.aspectRatio
                visible: control.mediaSource !== "" && control.mediaPosition === "bottom"

                Image {
                    anchors.fill: parent
                    source: control.mediaSource
                    fillMode: Image.PreserveAspectCrop
                }

                // Hover / pressed state overlay for media
                MeoStateLayer {
                    anchors.fill: parent
                    pressed: (typeof mouseArea !== 'undefined') ? mouseArea.pressed : false
                    hovered: (typeof mouseArea !== 'undefined') ? mouseArea.containsMouse : false
                    focused: control.activeFocus
                    visible: control.interactive
                }

                layer.enabled: true
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: Item {
                        width: mediaBottomContainer.width
                        height: mediaBottomContainer.height
                        MeoShape {
                            anchors.fill: parent
                            type: control.shape
                            radius: control.radius
                        }
                    }
                }
            }

            // 5. Bottom Actions
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: actionsRow.implicitHeight + 16 * themeGlobalScale
                visible: control.actions && control.actions.length > 0

                RowLayout {
                    id: actionsRow
                    anchors.fill: parent
                    anchors.leftMargin: 16 * themeGlobalScale
                    anchors.rightMargin: 16 * themeGlobalScale
                    anchors.bottomMargin: 8 * themeGlobalScale
                    spacing: 8 * themeGlobalScale

                    Repeater {
                        model: control.actions
                        delegate: MeoButton {
                            text: modelData.label || ""
                            icon.name: modelData.icon || ""
                            type: modelData.type || "text"
                            size: control.cardSize === "s" ? "xs" : "s"
                            enabled: typeof modelData.enabled !== 'undefined' ? modelData.enabled : true
                            onClicked: control.actionClicked(index, text)
                        }
                    }
                }
            }
        }
    }

    // Horizontal Layout
    Component {
        id: horizontalLayoutComponent
        RowLayout {
            spacing: 0

            // 1. Left Media Image
            Item {
                id: mediaLeftContainer
                Layout.fillHeight: true
                Layout.preferredWidth: {
                    if (control.aspectRatio > 0) return height * control.aspectRatio;
                    if (control.cardSize === "s") return 100 * themeGlobalScale;
                    if (control.cardSize === "l") return 160 * themeGlobalScale;
                    return 130 * themeGlobalScale; // m
                }
                visible: control.mediaSource !== "" && control.mediaPosition === "left"

                Image {
                    anchors.fill: parent
                    source: control.mediaSource
                    fillMode: Image.PreserveAspectCrop
                }

                // Hover / pressed state overlay for media
                MeoStateLayer {
                    anchors.fill: parent
                    pressed: (typeof mouseArea !== 'undefined') ? mouseArea.pressed : false
                    hovered: (typeof mouseArea !== 'undefined') ? mouseArea.containsMouse : false
                    focused: control.activeFocus
                    visible: control.interactive
                }

                layer.enabled: true
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: Item {
                        width: mediaLeftContainer.width
                        height: mediaLeftContainer.height
                        MeoShape {
                            anchors.fill: parent
                            type: control.shape
                            radius: control.radius
                        }
                    }
                }
            }

            // 2. Center/Right Content Area
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                // Header
                Item {
                    id: horizontalHeaderItem
                    Layout.fillWidth: true
                    Layout.preferredHeight: horizontalHeaderRow.implicitHeight + 16 * themeGlobalScale
                    visible: control.headerTitle !== "" || control.avatarSource !== "" || control.avatarInitials !== ""

                    RowLayout {
                        id: horizontalHeaderRow
                        anchors.fill: parent
                        anchors.margins: 12 * themeGlobalScale
                        spacing: 8 * themeGlobalScale

                        MeoAvatar {
                            Layout.alignment: Qt.AlignVCenter
                            size: 32
                            source: control.avatarSource
                            initials: control.avatarInitials
                            visible: control.avatarSource !== "" || control.avatarInitials !== ""
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1 * themeGlobalScale
                            MeoText {
                                Layout.fillWidth: true
                                text: control.headerTitle
                                typeRole: "title"
                                typeSize: "small"
                                emphasized: true
                            }
                            MeoText {
                                Layout.fillWidth: true
                                text: control.headerSubtitle
                                typeRole: "body"
                                typeSize: "small"
                                color: MeoTheme.contentOnSurfaceVariant
                                visible: control.headerSubtitle !== ""
                            }
                        }

                        MeoIconButton {
                            Layout.alignment: Qt.AlignVCenter
                            icon.name: "more_vert"
                            type: "standard"
                            size: "s"
                            visible: control.showOverflowButton
                            onClicked: control.overflowClicked()
                        }
                    }
                }

                // Text details
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.margins: 12 * themeGlobalScale
                    spacing: 4 * themeGlobalScale
                    visible: control.title !== "" || control.supportingText !== ""

                    MeoText {
                        Layout.fillWidth: true
                        text: control.title
                        typeRole: "title"
                        typeSize: "small"
                        emphasized: true
                        visible: text !== ""
                    }

                    MeoText {
                        Layout.fillWidth: true
                        text: control.supportingText
                        typeRole: "body"
                        typeSize: "small"
                        color: MeoTheme.contentOnSurfaceVariant
                        visible: text !== ""
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        maximumLineCount: 3
                    }
                }

                Item {
                    Layout.fillHeight: true
                }

                // Bottom actions
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: horizontalActionsRow.implicitHeight + 12 * themeGlobalScale
                    visible: control.actions && control.actions.length > 0

                    RowLayout {
                        id: horizontalActionsRow
                        anchors.fill: parent
                        anchors.leftMargin: 12 * themeGlobalScale
                        anchors.rightMargin: 12 * themeGlobalScale
                        anchors.bottomMargin: 8 * themeGlobalScale
                        spacing: 8 * themeGlobalScale

                        Repeater {
                            model: control.actions
                            delegate: MeoButton {
                                text: modelData.label || ""
                                icon.name: modelData.icon || ""
                                type: modelData.type || "text"
                                size: "xs"
                                enabled: typeof modelData.enabled !== 'undefined' ? modelData.enabled : true
                                onClicked: control.actionClicked(index, text)
                            }
                        }
                    }
                }
            }

            // 3. Right Media Image
            Item {
                id: mediaRightContainer
                Layout.fillHeight: true
                Layout.preferredWidth: {
                    if (control.aspectRatio > 0) return height * control.aspectRatio;
                    if (control.cardSize === "s") return 100 * themeGlobalScale;
                    if (control.cardSize === "l") return 160 * themeGlobalScale;
                    return 130 * themeGlobalScale; // m
                }
                visible: control.mediaSource !== "" && control.mediaPosition === "right"

                Image {
                    anchors.fill: parent
                    source: control.mediaSource
                    fillMode: Image.PreserveAspectCrop
                }

                // Hover / pressed state overlay for media
                MeoStateLayer {
                    anchors.fill: parent
                    pressed: (typeof mouseArea !== 'undefined') ? mouseArea.pressed : false
                    hovered: (typeof mouseArea !== 'undefined') ? mouseArea.containsMouse : false
                    focused: control.activeFocus
                    visible: control.interactive
                }

                layer.enabled: true
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: Item {
                        width: mediaRightContainer.width
                        height: mediaRightContainer.height
                        MeoShape {
                            anchors.fill: parent
                            type: control.shape
                            radius: control.radius
                        }
                    }
                }
            }
        }
    }
}

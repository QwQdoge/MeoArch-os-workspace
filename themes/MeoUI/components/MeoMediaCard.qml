import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import MeoUI

MeoCard {
    id: control

    // 🌟 Standard property definitions
    property string size: "m" // "s" | "m" | "l"
    property string title: ""
    property string subtitle: ""
    property string supportingText: ""
    property url mediaSource: ""
    property real mediaAspectRatio: 16.0 / 9.0 // e.g. 1.7777
    property string mediaPosition: "top" // "top" | "left" | "right" | "bottom"
    property url avatarSource: ""
    property string avatarInitials: ""
    property Component headerTrailing: null
    property list<Component> actions: []
    property int imageFillMode: Image.PreserveAspectCrop

    // Override MeoCard default padding to allow full-bleed media
    padding: 0

    // Theme values
    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property color themeOnSurface: MeoTheme.contentOnSurface
    readonly property color themeOnSurfaceVariant: MeoTheme.contentOnSurfaceVariant

    // Layout configuration based on size
    readonly property real innerPadding: {
        if (size === "s") return 8 * themeGlobalScale;
        if (size === "l") return 24 * themeGlobalScale;
        return 16 * themeGlobalScale;
    }

    readonly property real itemSpacing: {
        if (size === "s") return 6 * themeGlobalScale;
        if (size === "l") return 16 * themeGlobalScale;
        return 12 * themeGlobalScale;
    }

    readonly property var titleFontToken: {
        if (size === "s") return MeoTheme.titleSmallUi;
        if (size === "l") return MeoTheme.titleMediumUi;
        return MeoTheme.titleSmallUi;
    }

    readonly property var textFontToken: {
        if (size === "s") return MeoTheme.bodySmallUi;
        if (size === "l") return MeoTheme.bodyBig;
        return MeoTheme.bodyMediumUi;
    }

    // Main layout container with clipping to match the parent's card shape/radius
    contentItem: Item {
        id: contentContainer
        anchors.fill: parent

        layer.enabled: control.shape !== "rect" && control.shape !== "round" && control.shape !== "square"
        layer.effect: MultiEffect {
            maskEnabled: true
            maskSource: Item {
                width: contentContainer.width
                height: contentContainer.height
                MeoShape {
                    anchors.fill: parent
                    type: control.shape
                    radius: control.radius
                }
            }
        }

        // Clip content for rect/round/square cases simply using Item's clip or Rectangle clip
        clip: true

        // Outer layout selector
        Loader {
            anchors.fill: parent
            sourceComponent: {
                if (control.mediaSource.toString() !== "" && (control.mediaPosition === "left" || control.mediaPosition === "right")) {
                    return horizontalLayoutComponent;
                }
                return verticalLayoutComponent;
            }
        }
    }

    // 🌟 Vertical Layout: Media is Top/Bottom, or no media
    Component {
        id: verticalLayoutComponent

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // Top Media (Full Bleed)
            Loader {
                Layout.fillWidth: true
                Layout.preferredHeight: width / control.mediaAspectRatio
                visible: control.mediaSource.toString() !== "" && control.mediaPosition === "top"
                active: visible
                sourceComponent: mediaComponent
            }

            // Text and Header Content Area
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: control.innerPadding
                spacing: control.itemSpacing

                // Header section
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12 * control.themeGlobalScale
                    visible: control.title !== "" || control.subtitle !== "" || control.avatarSource.toString() !== "" || control.avatarInitials !== ""

                    // Avatar
                    MeoAvatar {
                        id: headerAvatar
                        visible: control.avatarSource.toString() !== "" || control.avatarInitials !== ""
                        source: control.avatarSource
                        initials: control.avatarInitials
                        size: control.size === "s" ? 32 * control.themeGlobalScale : 40 * control.themeGlobalScale
                        variant: control.shape === "rect" ? "circle" : "squircle"
                    }

                    // Title & Subtitle block
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2 * control.themeGlobalScale

                        MeoText {
                            Layout.fillWidth: true
                            text: control.title
                            typeRole: "title"
                            typeSize: control.size === "s" ? "small" : (control.size === "l" ? "large" : "medium")
                            emphasized: true
                            color: control.themeOnSurface
                            elide: Text.ElideRight
                        }

                        MeoText {
                            Layout.fillWidth: true
                            text: control.subtitle
                            visible: text !== ""
                            typeRole: "body"
                            typeSize: "small"
                            color: control.themeOnSurfaceVariant
                            elide: Text.ElideRight
                        }
                    }

                    // Trailing Action component (e.g. overflow menu button)
                    Loader {
                        sourceComponent: control.headerTrailing
                        visible: control.headerTrailing !== null
                    }
                }

                // Supporting Text body
                MeoText {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: control.supportingText
                    visible: text !== ""
                    typeRole: "body"
                    typeSize: control.size === "s" ? "small" : "medium"
                    color: control.themeOnSurfaceVariant
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                }

                // Actions Button Row
                RowLayout {
                    id: verticalActionsRow
                    Layout.fillWidth: true
                    spacing: 8 * control.themeGlobalScale
                    visible: control.actions.length > 0

                    Repeater {
                        model: control.actions
                        delegate: Loader {
                            sourceComponent: modelData
                        }
                    }
                }
            }

            // Bottom Media (Full Bleed)
            Loader {
                Layout.fillWidth: true
                Layout.preferredHeight: width / control.mediaAspectRatio
                visible: control.mediaSource.toString() !== "" && control.mediaPosition === "bottom"
                active: visible
                sourceComponent: mediaComponent
            }
        }
    }

    // 🌟 Horizontal Layout: Media is Left or Right
    Component {
        id: horizontalLayoutComponent

        RowLayout {
            anchors.fill: parent
            spacing: 0

            // Left Media
            Loader {
                Layout.fillHeight: true
                Layout.preferredWidth: height * control.mediaAspectRatio
                visible: control.mediaPosition === "left"
                active: visible
                sourceComponent: mediaComponent
            }

            // Text content
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: control.innerPadding
                spacing: control.itemSpacing

                // Header with Avatar
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12 * control.themeGlobalScale
                    visible: control.title !== "" || control.subtitle !== ""

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2 * control.themeGlobalScale

                        MeoText {
                            Layout.fillWidth: true
                            text: control.title
                            typeRole: "title"
                            typeSize: control.size === "s" ? "small" : "medium"
                            emphasized: true
                            color: control.themeOnSurface
                            elide: Text.ElideRight
                        }

                        MeoText {
                            Layout.fillWidth: true
                            text: control.subtitle
                            visible: text !== ""
                            typeRole: "body"
                            typeSize: "small"
                            color: control.themeOnSurfaceVariant
                            elide: Text.ElideRight
                        }
                    }

                    Loader {
                        sourceComponent: control.headerTrailing
                        visible: control.headerTrailing !== null
                    }
                }

                // Supporting text
                MeoText {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: control.supportingText
                    visible: text !== ""
                    typeRole: "body"
                    typeSize: control.size === "s" ? "small" : "medium"
                    color: control.themeOnSurfaceVariant
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                }

                // Actions Row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8 * control.themeGlobalScale
                    visible: control.actions.length > 0

                    Repeater {
                        model: control.actions
                        delegate: Loader {
                            sourceComponent: modelData
                        }
                    }
                }
            }

            // Right Media
            Loader {
                Layout.fillHeight: true
                Layout.preferredWidth: height * control.mediaAspectRatio
                visible: control.mediaPosition === "right"
                active: visible
                sourceComponent: mediaComponent
            }
        }
    }

    // 🌟 Reusable Media Component
    Component {
        id: mediaComponent

        Item {
            id: mediaWrapper
            anchors.fill: parent
            clip: true

            Image {
                id: mediaImage
                anchors.fill: parent
                source: control.mediaSource
                fillMode: control.imageFillMode
                horizontalAlignment: Image.AlignHCenter
                verticalAlignment: Image.AlignVCenter

                // Dynamic scale animation for bouncy hover interaction
                scale: control.interactive && control.bouncy && control.hovered ? 1.05 : 1.0

                Behavior on scale {
                    NumberAnimation {
                        duration: control.motionFast
                        easing.bezierCurve: MeoTheme.motionEasingStandard
                    }
                }
            }

            // Optional hover state layer overlay over the image
            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0,0,0,1)
                opacity: control.interactive && control.hovered ? 0.04 : 0.0
                Behavior on opacity { NumberAnimation { duration: control.motionFast } }
            }
        }
    }
}

pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import MeoUI 1.0
import ".."
import "../components"

PageFrame {
    id: page
    showBackButton: false
    showPrimaryButton: controller && controller.installationState === "complete"
    primaryLabel: "Continue"
    readonly property var stages: [
        "Validating configuration",
        "Preparing disk and filesystems",
        "Installing and configuring MeoArch",
        "Final checks"
    ]

    Column {
        width: parent.width
        spacing: page.dp(18)

        PageHeading {
            width: parent.width
            title: "Installing"
            subtitle: "Keep this device powered on while MeoArch is installed."
        }
        Row {
            width: parent.width
            spacing: page.dp(16)

            MeoText {
                text: page.controller ? page.controller.installationProgress + "%" : "0%"
                typeRole: "title"
                typeSize: "big"
                emphasized: true
                color: MeoTheme.primary
            }
            MeoText {
                anchors.baseline: parent.children[0].baseline
                text: page.controller && page.controller.installationState === "complete"
                      ? "Installation complete"
                      : page.controller && page.controller.installationState === "failed"
                        ? "Installation stopped"
                        : "Working…"
                typeRole: "body"
                typeSize: "big"
                color: MeoTheme.contentOnSurfaceVariant
            }
        }
        MeoProgressBar {
            width: parent.width
            height: page.dp(8)
            value: page.controller ? page.controller.installationProgress / 100 : 0
            isThick: true
            vibrant: true
        }
        MeoCard {
            width: parent.width
            implicitHeight: page.dp(240)
            type: "filled"
            padding: page.dp(20)

            Column {
                width: parent.width
                Repeater {
                    model: page.stages
                    delegate: Item {
                        id: stageRow
                        required property string modelData
                        required property int index
                        width: parent.width
                        height: page.dp(50)
                        readonly property int threshold: index * 25
                        readonly property bool active: page.controller
                                                               && page.controller.installationProgress >= threshold
                                                               && page.controller.installationProgress < threshold + 25
                        readonly property bool complete: page.controller
                                                                 && page.controller.installationProgress >= threshold + 25

                        MeoLoadingIndicator {
                            id: stageSpinner
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            size: "xs"
                            running: stageRow.active
                            indeterminate: true
                            visible: stageRow.active
                        }
                        MeoIcon {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            visible: !stageSpinner.visible
                            icon: stageRow.complete ? "check_circle" : "radio_button_unchecked"
                            size: 22
                            color: stageRow.complete ? MeoTheme.primary : MeoTheme.outline
                        }
                        MeoText {
                            anchors.left: parent.left
                            anchors.leftMargin: page.dp(36)
                            anchors.verticalCenter: parent.verticalCenter
                            text: stageRow.modelData
                            typeRole: "body"
                            typeSize: "medium"
                            emphasized: stageRow.active
                            color: MeoTheme.contentOnSurface
                        }
                    }
                }
            }
        }
        MeoButton { text: "Show Details"; type: "text"; onClicked: logPopup.openFrom(this) }
    }

    MeoMotionPopup {
        id: logPopup
        presentation: MeoMotionPopup.Dialog
        anchors.centerIn: Overlay.overlay
        width: Math.min(page.dp(720), Overlay.overlay ? Overlay.overlay.width - page.dp(64) : page.dp(720))
        height: page.dp(420)
        padding: page.dp(24)
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        surfaceColor: "#252329"

        contentItem: Column {
            spacing: page.dp(12)
            MeoText { text: "Installation details"; color: "white"; typeRole: "title"; typeSize: "medium"; emphasized: true }
            MeoText {
                width: parent.width
                text: page.controller && page.controller.installationState === "failed"
                      ? "Installation did not complete.\n\n" + page.controller.errorMessage
                      : "Live installation output is recorded in\n/tmp/meoarch-installer/logs/install.log\n\nSecrets are never written to this view."
                color: "#E9E4EC"
                typeRole: "body"
                typeSize: "small"
                lineHeight: 1.5
            }
        }
    }
}

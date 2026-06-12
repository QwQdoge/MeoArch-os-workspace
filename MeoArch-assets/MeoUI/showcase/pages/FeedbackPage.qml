import QtQuick
import QtQuick.Controls
import MeoUI

Flickable {
    contentHeight: feedbackColumn.implicitHeight + 40
    clip: true
    Column {
        id: feedbackColumn
        padding: 24 * MeoTheme.globalScale
        spacing: 24 * MeoTheme.globalScale
        width: parent.width

        Text { text: "Feedback"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }

        MeoBanner {
            text: "This is an updated MD3 Expressive Banner with a leading icon and refined layout."
            icon: "info"
            confirmText: "Action"
            cancelText: "Dismiss"
            width: 400 * MeoTheme.globalScale
        }

        MeoButton {
            text: "Show Snackbar (Expressive)"
            onClicked: snackbar.open()
        }

        MeoButton {
            text: "Show Expressive Dialog"
            onClicked: expressiveDialog.open()
        }

        MeoSnackbar {
            id: snackbar
            message: "This is an expressive snackbar with a 4dp radius."
            actionText: "UNDO"
            parent: ApplicationWindow.window ? ApplicationWindow.window.contentItem : undefined
        }

        MeoExpressiveDialog {
            id: expressiveDialog
            title: "Permission Required"
            message: "This app needs access to your camera to take expressive photos. We will never share your photos without permission."
            icon: "camera"
            confirmText: "Allow"
            cancelText: "Deny"
            onConfirmed: console.log("Confirmed")
            onCancelled: console.log("Cancelled")
        }
    }
}

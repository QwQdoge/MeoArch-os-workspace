import QtQuick
import QtQuick.Controls
import MeoUI

Popup {
    id: control

    // 🌟 核心属性
    property string text: ""
    property var suggestions: []
    property Component content: null // Custom results content
    property string placeholder: "Search..."

    // 🌟 MD3 Expressive: Search View is usually full-screen or large modal
    // Morphing is handled by parallel animations on opacity and container size if triggered from a bar

    readonly property color themeSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surface !== 'undefined') ? MeoTheme.surface : "#FFFBFE"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    width: parent ? parent.width : 360 * themeGlobalScale
    height: parent ? parent.height : 600 * themeGlobalScale
    padding: 0
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape

    background: Rectangle {
        color: control.themeSurface
    }

    contentItem: Column {
        id: mainColumn
        width: parent.width

        // Morphing Search Bar Area
        MeoSearchBar {
            id: searchBar
            width: parent.width
            text: control.text
            active: control.opened
            placeholder: control.placeholder
            onTextChanged: control.text = text

            // Forward back button to close
            // (MeoSearchBar already handles active state toggle)
            onActiveChanged: if (!active) control.close()
        }

        // Search Suggestions or Results
        Item {
            width: parent.width
            height: parent.height - searchBar.height

            // Suggestions Layer
            MeoSearchSuggestions {
                anchors.fill: parent
                model: control.suggestions
                highlightText: control.text
                visible: control.text !== "" && control.content === null
                onSelected: (index, data) => {
                    control.text = data.label
                    // Action for selection
                }
            }

            // Results Layer (Custom Content)
            Loader {
                anchors.fill: parent
                sourceComponent: control.content
                visible: control.content !== null
            }

            // Empty/History State
            Column {
                anchors.centerIn: parent
                visible: control.text === "" && control.suggestions.length === 0 && control.content === null
                spacing: 16 * control.themeGlobalScale

                MeoIcon {
                    icon: "search"
                    size: 48
                    color: control.themeOnSurfaceVariant
                    anchors.horizontalCenter: parent.horizontalCenter
                    opacity: 0.38
                }

                Text {
                    text: "Search your content"
                    color: control.themeOnSurfaceVariant
                    font.pixelSize: 16 * control.themeGlobalScale
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }

    // 🌟 MD3 Expressive Expanding Animation
    enter: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 250; easing.bezierCurve: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionEasingSoul !== 'undefined') ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0] }
            NumberAnimation { property: "scale"; from: 0.95; to: 1.0; duration: 250; easing.bezierCurve: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionEasingSoul !== 'undefined') ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0] }
            NumberAnimation { target: mainColumn; property: "opacity"; from: 0.0; to: 1.0; duration: 200 }
        }
    }

    exit: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 200 }
            NumberAnimation { property: "scale"; from: 1.0; to: 0.95; duration: 200 }
        }
    }
}

import QtQuick
import QtQuick.Layouts
import MeoUI

MeoPageLayout {
    id: page

    property string categoryId: "foundations"
    ShowcaseCatalog {
        id: catalog
    }

    readonly property var category: catalog.categoryById(categoryId)

    title: category.label
    subtitle: category.subtitle

    Flow {
        width: parent.width
        spacing: MeoTheme.space8

        Repeater {
            model: page.category.components
            delegate: Rectangle {
                required property var modelData

                implicitWidth: Math.max(150 * MeoTheme.globalScale, indexLabel.implicitWidth + MeoTheme.space24)
                implicitHeight: MeoTheme.buttonHeightM
                radius: MeoTheme.shapeMedium
                color: MeoTheme.surfaceContainerLow
                border.color: MeoTheme.outlineVariant

                MeoText {
                    id: indexLabel
                    anchors.centerIn: parent
                    text: modelData.name
                    typeRole: "label"
                    typeSize: "medium"
                    color: MeoTheme.contentOnSurfaceVariant
                }
            }
        }
    }

    Repeater {
        model: page.category.components
        delegate: ShowcaseSection {
            required property var modelData
            width: parent.width
            componentData: modelData

            ShowcaseStateGrid {
                Layout.fillWidth: true
                Layout.preferredHeight: childrenRect.height
            }

            ShowcaseVariantRow {
                Layout.fillWidth: true
                Layout.preferredHeight: implicitHeight
                title: "Live sample"

                ShowcaseSampleDelegate {
                    componentData: modelData
                }
            }

            ShowcaseApiTable {
                Layout.fillWidth: true
                variants: modelData.variants
                stateSummary: modelData.states
                api: modelData.api
            }

            ShowcaseSnippet {
                Layout.fillWidth: true
                code: modelData.usage
            }
        }
    }
}

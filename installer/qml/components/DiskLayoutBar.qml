pragma ComponentBehavior: Bound
import QtQuick
import MeoUI 1.0

// One horizontal map of a disk: proportional segments plus a legend.
// Used for both the current layout and the layout after installation so the
// two read the same way. Each segment: { label, detail, bytes, role }.
// Roles: "root", "home", "efi", "other", "free", "erase".
Column {
    id: bar
    property string caption: ""
    property var segments: []
    property real scale: MeoTheme.globalScale
    spacing: 8 * scale

    function dp(value) { return value * scale }
    function roleColor(role) {
        if (role === "root") return MeoTheme.primary
        if (role === "home") return MeoTheme.tertiary
        if (role === "efi") return MeoTheme.secondary
        if (role === "erase") return MeoTheme.error
        if (role === "free") return MeoTheme.surfaceContainerLowest
        return MeoTheme.outline
    }
    function formatBytes(bytes) {
        const value = Math.max(0, Number(bytes) || 0)
        if (value >= 1099511627776)
            return qsTr("%1 TiB").arg((value / 1099511627776).toFixed(1))
        if (value >= 1073741824)
            return qsTr("%1 GiB").arg(Math.round(value / 1073741824))
        return qsTr("%1 MiB").arg(Math.round(value / 1048576))
    }

    // Widths are proportional, but every segment keeps a visible minimum so a
    // 512 MiB EFI partition is not lost next to a 1 TB data partition.
    readonly property var widths: {
        const list = bar.segments || []
        const gap = dp(3)
        const minimum = dp(10)
        const available = Math.max(0, bar.width - gap * Math.max(0, list.length - 1))
        const total = list.reduce((sum, item) => sum + Math.max(0, Number(item.bytes) || 0), 0)
        if (!list.length || total <= 0)
            return []
        const raw = list.map(item => available * Math.max(0, Number(item.bytes) || 0) / total)
        const boosted = raw.map(value => Math.max(minimum, value))
        const extra = boosted.reduce((sum, value) => sum + value, 0) - available
        const shrinkable = raw.reduce((sum, value) => sum + (value > minimum ? value - minimum : 0), 0)
        return boosted.map((value, index) => raw[index] > minimum && shrinkable > 0
                                             ? value - extra * (raw[index] - minimum) / shrinkable
                                             : value)
    }

    MeoText {
        visible: bar.caption.length > 0
        width: parent.width
        text: bar.caption
        typeRole: "label"
        typeSize: "large"
        emphasized: true
        color: MeoTheme.contentOnSurfaceVariant
    }

    Row {
        width: parent.width
        height: bar.dp(26)
        spacing: bar.dp(3)
        Repeater {
            model: bar.segments
            delegate: MeoShape {
                id: segment
                required property var modelData
                required property int index
                type: "rect"
                width: Math.max(0, bar.widths[index] || 0)
                height: parent.height
                radius: bar.dp(6)
                color: bar.roleColor(modelData.role)
                opacity: modelData.role === "other" ? 0.45 : 1
                strokeWidth: modelData.role === "free" ? Math.max(1, bar.dp(1)) : 0
                strokeColor: MeoTheme.outlineVariant
                Accessible.role: Accessible.StaticText
                Accessible.name: modelData.label + ", " + bar.formatBytes(modelData.bytes)
                // Striped fill marks space that will be erased.
                Row {
                    visible: segment.modelData.role === "erase"
                    anchors.fill: parent
                    clip: true
                    spacing: bar.dp(6)
                    Repeater {
                        model: Math.ceil(segment.width / bar.dp(8)) + 1
                        MeoShape {
                            type: "rect"
                            radius: 0
                            width: bar.dp(2)
                            height: segment.height * 1.6
                            y: -segment.height * 0.3
                            rotation: 30
                            color: MeoTheme.onError
                            opacity: 0.35
                        }
                    }
                }
            }
        }
    }

    Flow {
        width: parent.width
        spacing: bar.dp(14)
        Repeater {
            model: bar.segments
            delegate: Row {
                id: legendItem
                required property var modelData
                spacing: bar.dp(6)
                MeoShape {
                    type: "circle"
                    anchors.verticalCenter: parent.verticalCenter
                    width: bar.dp(10)
                    height: width
                    color: bar.roleColor(legendItem.modelData.role)
                    opacity: legendItem.modelData.role === "other" ? 0.45 : 1
                    strokeWidth: legendItem.modelData.role === "free" ? Math.max(1, bar.dp(1)) : 0
                    strokeColor: MeoTheme.outline
                }
                MeoText {
                    text: legendItem.modelData.label + " · " + bar.formatBytes(legendItem.modelData.bytes)
                          + (String(legendItem.modelData.detail || "").length ? " · " + legendItem.modelData.detail : "")
                    typeRole: "body"
                    typeSize: "small"
                    color: MeoTheme.contentOnSurfaceVariant
                }
            }
        }
    }
}

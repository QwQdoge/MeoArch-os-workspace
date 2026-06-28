import QtQuick
import QtQuick.Controls

Rectangle {
    id: control

    // 🌟 核心属性
    property string text: ""
    property int maxCount: 99
    property bool isDot: false

    // 🌟 作用域与主题安全防御
    property Item target: null
    readonly property color themeError: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.error !== 'undefined') ? MeoTheme.error : "#B3261E"
    readonly property color themeOnError: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onError !== 'undefined') ? MeoTheme.onError : "#FFFFFF"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitWidth: isDot ? 6 * themeGlobalScale : Math.max(16 * themeGlobalScale, label.implicitWidth + 8 * themeGlobalScale)
    implicitHeight: isDot ? 6 * themeGlobalScale : 16 * themeGlobalScale
    radius: height / 2
    color: themeError

    // Auto anchoring
    x: target ? target.width - width/2 : 0
    y: target ? -height/2 : 0
    onTargetChanged: if (target) parent = target

    Text {
        id: label
        anchors.centerIn: parent
        text: {
            let count = parseInt(control.text);
            if (!isNaN(count) && count > control.maxCount) {
                return control.maxCount + "+";
            }
            return control.text;
        }
        visible: !control.isDot
        font.pixelSize: 10 * control.themeGlobalScale
        font.weight: Font.Medium
        color: control.themeOnError
    }
}

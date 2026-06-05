import QtQuick
import QtQuick.Controls
import MeoUI

Frame {
    id: control

    // 🌟 对外暴露的核心接口
    property string title: "Untitled Track"
    property string artist: "Unknown Artist"
    property string coverSource: "" // 封面图片源，若为空则显示动态 placeholder
    property bool isPlaying: false
    property int duration: 180000 // 总时长（毫秒，默认3分钟）
    property int position: 45000 // 当前进度（毫秒，默认45秒）
    property real volume: 0.7 // 音量 (0.0 ~ 1.0)

    signal playRequested
    signal pauseRequested
    signal nextRequested
    signal previousRequested
    signal seekRequested(int newPosition)
    signal volumeRequested(real newVolume)

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnPrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onPrimary !== 'undefined') ? MeoTheme.onPrimary : "#FFFFFF"
    readonly property color themeSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.secondaryContainer !== 'undefined') ? MeoTheme.secondaryContainer : "#E8DEF8"
    readonly property color themeOnSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSecondaryContainer !== 'undefined') ? MeoTheme.onSecondaryContainer : "#1D192B"
    readonly property color themeSurfaceContainerLow: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerLow !== 'undefined') ? MeoTheme.surfaceContainerLow : "#F7F2FA"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property color themeOutline: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outline !== 'undefined') ? MeoTheme.outline : "#79747E"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    padding: 16 * themeGlobalScale
    implicitWidth: 360 * themeGlobalScale
    implicitHeight: 180 * themeGlobalScale

    // 🌟 外层 M3 卡片容器
    background: Rectangle {
        color: control.themeSurfaceContainerLow
        radius: 16 * control.themeGlobalScale
        border.color: control.isDarkMode ? Qt.rgba(255, 255, 255, 0.08) : Qt.rgba(0, 0, 0, 0.08)
        border.width: 1

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
    }

    // 内部总体布局
    Column {
        anchors.fill: parent
        spacing: 12 * control.themeGlobalScale

        // 第一行：封面与歌曲信息
        Row {
            width: parent.width
            spacing: 16 * control.themeGlobalScale

            // Album Art (唱片封面)
            Rectangle {
                id: albumArtContainer
                width: 64 * control.themeGlobalScale
                height: 64 * control.themeGlobalScale
                radius: 8 * control.themeGlobalScale
                clip: true
                color: control.isDarkMode ? "#36343B" : "#ECE6F0"

                // 封面图片
                Image {
                    anchors.fill: parent
                    source: control.coverSource
                    fillMode: Image.PreserveAspectCrop
                    visible: source !== ""
                }

                // 封面缺失时的动态艺术生成 placeholder
                Rectangle {
                    anchors.fill: parent
                    visible: control.coverSource === ""
                    gradient: Gradient {
                        GradientStop {
                            position: 0.0
                            color: control.themePrimary
                        }
                        GradientStop {
                            position: 1.0
                            color: Qt.darker(control.themePrimary, 1.8)
                        }
                    }

                    // 音符图标
                    Text {
                        anchors.centerIn: parent
                        text: "♪"
                        color: control.themeOnPrimary
                        font.pixelSize: 28 * control.themeGlobalScale
                        font.weight: Font.Bold
                    }
                }
            }

            // 歌曲信息文字区
            Column {
                width: parent.width - albumArtContainer.width - parent.spacing
                anchors.verticalCenter: albumArtContainer.verticalCenter
                spacing: 4 * control.themeGlobalScale

                Text {
                    text: control.title
                    width: parent.width
                    font.pixelSize: 16 * control.themeGlobalScale
                    font.weight: Font.Bold
                    color: control.themeOnSurface
                    elide: Text.ElideRight
                }

                Text {
                    text: control.artist
                    width: parent.width
                    font.pixelSize: 14 * control.themeGlobalScale
                    color: control.themeOnSurfaceVariant
                    elide: Text.ElideRight
                }
            }
        }

        // 第二行：进度条与播放时长指示
        Column {
            width: parent.width
            spacing: 4 * control.themeGlobalScale

            // 进度条本身 (Slider 扁平化重构)
            Slider {
                id: progressSlider
                width: parent.width
                height: 12 * control.themeGlobalScale
                padding: 0
                from: 0
                to: Math.max(1, control.duration)
                value: control.position

                background: Rectangle {
                    x: progressSlider.leftPadding
                    y: progressSlider.topPadding + (progressSlider.availableHeight - height) / 2
                    width: progressSlider.availableWidth
                    height: 4 * control.themeGlobalScale
                    radius: 2 * control.themeGlobalScale
                    color: Qt.rgba(control.themeOnSurfaceVariant.r, control.themeOnSurfaceVariant.g, control.themeOnSurfaceVariant.b, 0.24)

                    Rectangle {
                        width: progressSlider.visualPosition * parent.width
                        height: parent.height
                        color: control.themePrimary
                        radius: 2 * control.themeGlobalScale
                    }
                }

                handle: Rectangle {
                    x: progressSlider.leftPadding + progressSlider.visualPosition * (progressSlider.availableWidth - width)
                    y: progressSlider.topPadding + (progressSlider.availableHeight - height) / 2
                    width: progressSlider.hovered ? 12 * control.themeGlobalScale : 8 * control.themeGlobalScale
                    height: width
                    radius: width / 2
                    color: control.themePrimary

                    Behavior on width {
                        NumberAnimation {
                            duration: 100
                        }
                    }
                }

                onMoved: {
                    control.seekRequested(value);
                }
            }

            // 时长标签
            Row {
                width: parent.width

                // 当前播放位置
                Text {
                    text: formatTime(control.position)
                    font.pixelSize: 11 * control.themeGlobalScale
                    color: control.themeOnSurfaceVariant
                }

                Item {
                    width: 1
                    height: 1
                    anchors.horizontalCenter: parent.horizontalCenter
                } // Spacing

                // 总播放时长
                Text {
                    text: formatTime(control.duration)
                    font.pixelSize: 11 * control.themeGlobalScale
                    color: control.themeOnSurfaceVariant
                    anchors.right: parent.right
                }
            }
        }

        // 第三行：控制按钮区与音量控制
        Row {
            width: parent.width
            spacing: 12 * control.themeGlobalScale
            anchors.horizontalCenter: parent.horizontalCenter

            // 占位使得控制按钮完美居中，左侧音量在角落
            Item {
                width: (parent.width - centerButtons.width) / 2
                height: 36 * control.themeGlobalScale

                // 左侧音量小组件
                Row {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4 * control.themeGlobalScale

                    Text {
                        text: control.volume > 0.5 ? "🔊" : (control.volume > 0.0 ? "🔉" : "🔇")
                        font.pixelSize: 14 * control.themeGlobalScale
                        color: control.themeOnSurfaceVariant
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Slider {
                        id: volumeSlider
                        width: 60 * control.themeGlobalScale
                        height: 12 * control.themeGlobalScale
                        padding: 0
                        from: 0.0
                        to: 1.0
                        value: control.volume

                        background: Rectangle {
                            x: volumeSlider.leftPadding
                            y: volumeSlider.topPadding + (volumeSlider.availableHeight - height) / 2
                            width: volumeSlider.availableWidth
                            height: 2 * control.themeGlobalScale
                            radius: 1 * control.themeGlobalScale
                            color: Qt.rgba(control.themeOnSurfaceVariant.r, control.themeOnSurfaceVariant.g, control.themeOnSurfaceVariant.b, 0.2)

                            Rectangle {
                                width: volumeSlider.visualPosition * parent.width
                                height: parent.height
                                color: control.themeOnSurfaceVariant
                                radius: 1 * control.themeGlobalScale
                            }
                        }

                        handle: Rectangle {
                            x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                            y: volumeSlider.topPadding + (volumeSlider.availableHeight - height) / 2
                            width: 6 * control.themeGlobalScale
                            height: width
                            radius: width / 2
                            color: control.themeOnSurfaceVariant
                        }

                        onMoved: {
                            control.volumeRequested(value);
                        }
                    }
                }
            }

            // 中间的三个控制键 (⏭ ⏮ 播放键)
            Row {
                id: centerButtons
                spacing: 16 * control.themeGlobalScale
                anchors.verticalCenter: parent.verticalCenter

                // ⏮ Previous Button
                Button {
                    id: prevBtn
                    width: 36 * control.themeGlobalScale
                    height: 36 * control.themeGlobalScale
                    hoverEnabled: true

                    background: Rectangle {
                        radius: 18 * control.themeGlobalScale
                        color: prevBtn.pressed ? Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, 0.12) : (prevBtn.hovered ? Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, 0.08) : "transparent")
                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }
                    }
                    contentItem: Text {
                        text: "⏮"
                        font.pixelSize: 18 * control.themeGlobalScale
                        color: control.themeOnSurface
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: control.previousRequested()
                }

                // ▶ Play / ⏸ Pause Button (M3 Tonal/Filled 混合态主操作钮)
                Button {
                    id: playBtn
                    width: 48 * control.themeGlobalScale
                    height: 48 * control.themeGlobalScale
                    anchors.verticalCenter: parent.verticalCenter
                    hoverEnabled: true

                    background: Rectangle {
                        radius: 24 * control.themeGlobalScale
                        color: control.isPlaying ? control.themeSecondaryContainer : control.themePrimary

                        // Hover/Pressed State Layer
                        Rectangle {
                            anchors.fill: parent
                            radius: parent.radius
                            color: playBtn.pressed ? Qt.rgba(0, 0, 0, 0.12) : (playBtn.hovered ? Qt.rgba(255, 255, 255, 0.08) : "transparent")
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }
                    }
                    contentItem: Text {
                        text: control.isPlaying ? "⏸" : "▶"
                        font.pixelSize: 20 * control.themeGlobalScale
                        color: control.isPlaying ? control.themeOnSecondaryContainer : control.themeOnPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        if (control.isPlaying) {
                            control.pauseRequested();
                        } else {
                            control.playRequested();
                        }
                    }
                }

                // ⏭ Next Button
                Button {
                    id: nextBtn
                    width: 36 * control.themeGlobalScale
                    height: 36 * control.themeGlobalScale
                    hoverEnabled: true

                    background: Rectangle {
                        radius: 18 * control.themeGlobalScale
                        color: nextBtn.pressed ? Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, 0.12) : (nextBtn.hovered ? Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, 0.08) : "transparent")
                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }
                    }
                    contentItem: Text {
                        text: "⏭"
                        font.pixelSize: 18 * control.themeGlobalScale
                        color: control.themeOnSurface
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: control.nextRequested()
                }
            }

            // 右侧对称占位项
            Item {
                width: (parent.width - centerButtons.width) / 2
                height: 36 * control.themeGlobalScale
            }
        }
    }

    // 🌟 辅助时间格式化函数 (毫秒 -> mm:ss)
    function formatTime(ms) {
        let totalSeconds = Math.floor(ms / 1000);
        let minutes = Math.floor(totalSeconds / 60);
        let seconds = totalSeconds % 60;
        return minutes + ":" + (seconds < 10 ? "0" : "") + seconds;
    }
}

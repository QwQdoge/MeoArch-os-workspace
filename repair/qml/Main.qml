pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import MeoUI 1.0

Window {
    id: root

    required property var repairController
    property bool visualPreview: false
    property string initialCategory: "all"
    property string selectedCategory: "all"
    property string selectedProvider: "openai"
    property bool showCheckLog: false
    property var consentSummary: ({})
    property bool consentConfirmed: false

    // The permanent navigation rail makes scanning fast on a large display,
    // but it leaves too little working space for the four-step flow on a
    // laptop-sized live session. The same categories are surfaced inline when
    // compact, so the path remains keyboard-accessible rather than hidden.
    readonly property bool compactLayout: width < dp(1180)
    readonly property bool auditComplete: repairController.auditState === "complete"
    readonly property int workflowIndex: {
        if (repairController.readyToExecute || repairController.executionState !== "idle")
            return 3
        if (repairController.planSha256.length > 0 || repairController.proposalJson.length > 0)
            return 2
        if (auditComplete)
            return 1
        return 0
    }
    readonly property string workflowHint: {
        if (repairController.executionState === "complete")
            return qsTr("已完成固定动作；请查看执行日志并按需再次运行只读检查。")
        if (repairController.readyToExecute)
            return qsTr("风险复核已通过。请阅读计划，并完整输入确认短语；在此之前不会执行任何动作。")
        if (repairController.planSha256.length > 0)
            return qsTr("方案已生成，正在等待或未通过独立风险复核；此时没有任何动作可以执行。")
        if (repairController.auditState === "running")
            return qsTr("正在运行程序内固定的只读检查；可以随时停止，尚未进行修复。")
        if (auditComplete)
            return qsTr("检查结果已就绪。AI 是可选的；配置来源后才可请求受限方案和独立复核。")
        return qsTr("选择问题分类后运行固定只读检查。无需登录，也无需填写 API Key。")
    }

    readonly property var providerIds: ["openai", "gemini", "deepseek", "openrouter", "ollama"]
    readonly property var providerLabels: ["OpenAI", "Google Gemini", "DeepSeek", "OpenRouter", "Ollama（本机）"]
    readonly property var effectiveCredentials: visualPreview ? [
        { "id": "preview-proposal", "displayName": "OpenAI", "provider": "openai", "defaultModel": "gpt-5" },
        { "id": "preview-review", "displayName": "Gemini", "provider": "gemini", "defaultModel": "gemini-2.5-pro" }
    ] : repairController.credentials
    readonly property var credentialLabels: {
        const labels = []
        for (let index = 0; index < effectiveCredentials.length; ++index) {
            const item = effectiveCredentials[index]
            const model = item.defaultModel ? " · " + item.defaultModel : ""
            labels.push(item.displayName + " · " + item.provider + model)
        }
        return labels
    }

    width: 1440
    height: 900
    minimumWidth: 980
    minimumHeight: 680
    visible: true
    color: MeoTheme.surface
    title: qsTr("MeoArch Quick Repair")

    function dp(value) { return Math.round(value * MeoTheme.globalScale) }
    function providerIndex(provider) {
        const index = providerIds.indexOf(provider)
        return index < 0 ? 0 : index
    }
    function credentialId(index) {
        return index >= 0 && index < effectiveCredentials.length ? effectiveCredentials[index].id : ""
    }
    function firstItems(items, limit) {
        const result = []
        for (let index = 0; index < items.length && index < limit; ++index)
            result.push(items[index])
        return result
    }
    function selectedCategoryMeta() {
        const categories = repairController.checkCategories
        for (let index = 0; index < categories.length; ++index) {
            if (categories[index].id === selectedCategory)
                return categories[index]
        }
        return categories.length > 0 ? categories[0] : ({ "title": "Quick check", "description": "", "icon": "troubleshoot" })
    }
    function configureProviderDefaults(provider) {
        if (provider === "openai") {
            proposalModel.text = "gpt-5"
            reviewerModel.text = "gpt-5-mini"
        } else if (provider === "gemini") {
            proposalModel.text = "gemini-2.5-pro"
            reviewerModel.text = "gemini-2.5-flash"
        } else if (provider === "deepseek") {
            proposalModel.text = "deepseek-chat"
            reviewerModel.text = "deepseek-reasoner"
        } else if (provider === "openrouter") {
            proposalModel.text = "openai/gpt-5"
            reviewerModel.text = "google/gemini-2.5-pro"
        } else {
            proposalModel.text = "qwen2.5:14b"
            reviewerModel.text = "deepseek-r1:14b"
            endpointField.text = "http://127.0.0.1:11434"
        }
    }

    Component.onCompleted: {
        MeoTheme.isDarkMode = false
        selectedCategory = initialCategory
        selectedProvider = repairController.localProvider
        providerPicker.currentIndex = providerIndex(selectedProvider)
        endpointField.text = repairController.localEndpoint
        proposalModel.text = repairController.localProposalModel
        reviewerModel.text = repairController.localReviewerModel
        if (visualPreview) {
            selectedCategory = "network"
            proposalPicker.currentIndex = 0
            reviewerPicker.currentIndex = 1
        }
    }

    Connections {
        target: root.repairController
        function onAiConsentReady(summary) {
            root.consentSummary = summary
            root.consentConfirmed = false
            consentDialog.open()
        }
        function onAuthChanged() {
            if (root.repairController.signedIn) {
                passwordField.text = ""
                totpField.text = ""
            }
        }
    }

    MeoShape {
        anchors.fill: parent
        type: "rect"
        radius: 0
        color: MeoTheme.surface

        MeoShape {
            width: root.dp(540); height: width
            type: "rect"; radius: width / 2
            color: MeoTheme.primaryContainer; opacity: 0.32
            anchors.right: parent.right; anchors.top: parent.top
            anchors.rightMargin: -width * 0.36; anchors.topMargin: -height * 0.50
        }
        MeoShape {
            width: root.dp(360); height: width
            type: "rect"; radius: width / 2
            color: MeoTheme.tertiaryContainer; opacity: 0.24
            anchors.left: parent.left; anchors.bottom: parent.bottom
            anchors.leftMargin: -width * 0.48; anchors.bottomMargin: -height * 0.52
        }
    }

    RowLayout {
        id: appBar
        anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
        anchors.margins: root.dp(24)
        height: root.dp(64)
        spacing: root.dp(14)

        MeoAiMark { Layout.preferredWidth: root.dp(56); Layout.preferredHeight: root.dp(56) }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            MeoText {
                text: qsTr("MeoArch 快速修复")
                typeRole: "title"; typeSize: "big"; emphasized: true
                color: MeoTheme.contentOnSurface
            }
            MeoText {
                text: qsTr("分类检查 · 双模型风险复核 · 精确确认")
                typeRole: "body"; typeSize: "small"
                color: MeoTheme.contentOnSurfaceVariant
            }
        }
        MeoChip {
            label: root.repairController.liveEnvironment ? qsTr("Live 修复") : qsTr("系统修复")
            icon: root.repairController.liveEnvironment ? "usb" : "desktop_windows"
            selected: true
        }
        MeoIconButton {
            visible: root.repairController.diagnosticTtyAvailable
            icon.name: "terminal"; type: "outlined"; size: "l"
            Accessible.name: qsTr("打开 Live TTY 3 诊断终端")
            onClicked: root.repairController.openDiagnosticTty()
        }
        MeoChip { label: qsTr("账号可选"); icon: "person_off"; visualStyle: "outlined" }
        MeoIconButton {
            icon.name: "close"; type: "tonal"; size: "l"
            Accessible.name: qsTr("退出快速修复")
            onClicked: Qt.quit()
        }
    }

    RowLayout {
        anchors.left: parent.left; anchors.right: parent.right
        anchors.top: appBar.bottom; anchors.bottom: parent.bottom
        anchors.leftMargin: root.dp(20); anchors.rightMargin: root.dp(20)
        anchors.topMargin: root.dp(12); anchors.bottomMargin: root.dp(20)
        spacing: root.dp(18)

        MeoCard {
            visible: !root.compactLayout
            Layout.preferredWidth: root.compactLayout ? 0 : root.dp(286)
            Layout.maximumWidth: root.compactLayout ? 0 : root.dp(286)
            Layout.minimumWidth: 0
            Layout.fillHeight: !root.compactLayout
            type: "filled"
            padding: root.dp(12)

            ColumnLayout {
                anchors.fill: parent
                spacing: root.dp(6)

                MeoText {
                    Layout.leftMargin: root.dp(12); Layout.topMargin: root.dp(8)
                    text: qsTr("问题分类")
                    typeRole: "title"; typeSize: "small"; emphasized: true
                    color: MeoTheme.contentOnSurface
                }
                MeoText {
                    Layout.leftMargin: root.dp(12); Layout.rightMargin: root.dp(12)
                    Layout.fillWidth: true
                    text: qsTr("先运行固定的只读脚本；AI 不是必需条件。")
                    wrapMode: Text.WordWrap
                    typeRole: "body"; typeSize: "small"
                    color: MeoTheme.contentOnSurfaceVariant
                }
                Item { Layout.preferredHeight: root.dp(6) }
                Repeater {
                    model: root.repairController.checkCategories
                    delegate: MeoNavigationDrawerItem {
                        id: categoryItem
                        required property var modelData
                        Layout.fillWidth: true
                        label: modelData.title
                        supportingText: modelData.description
                        icon: modelData.icon
                        mode: "group"
                        selected: root.selectedCategory === modelData.id
                        onClicked: root.selectedCategory = modelData.id
                    }
                }
                Item { Layout.fillHeight: true }
                MeoBanner {
                    Layout.fillWidth: true
                    title: qsTr("命令行模式（只读）")
                    text: "meoarch-repair --cli --category=" + root.selectedCategory
                          + qsTr("；运行与图形界面相同的检查，不会绕过风险复核或精确确认。")
                    icon: "terminal"
                }
            }
        }

        ScrollView {
            id: mainScroll
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            ColumnLayout {
                width: Math.min(mainScroll.availableWidth, root.dp(1080))
                x: Math.max(0, (mainScroll.availableWidth - width) / 2)
                spacing: root.dp(18)

                MeoCard {
                    Layout.fillWidth: true
                    type: "outlined"
                    compact: true
                    padding: root.dp(16)

                    ColumnLayout {
                        width: parent.width
                        spacing: root.dp(10)

                        MeoStepper {
                            Layout.fillWidth: true
                            Layout.preferredHeight: root.dp(76)
                            model: [
                                { "label": qsTr("快速检查") },
                                { "label": qsTr("选择 AI") },
                                { "label": qsTr("风险复核") },
                                { "label": qsTr("确认执行") }
                            ]
                            currentIndex: root.workflowIndex
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: root.dp(10)
                            MeoIcon {
                                icon: root.workflowIndex === 3 ? "verified_user" : "arrow_forward"
                                size: 22
                                color: MeoTheme.primary
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0
                                MeoText {
                                    text: qsTr("下一步")
                                    typeRole: "label"; typeSize: "medium"; emphasized: true
                                    color: MeoTheme.contentOnSurface
                                }
                                MeoText {
                                    Layout.fillWidth: true
                                    text: root.workflowHint
                                    wrapMode: Text.WordWrap
                                    typeRole: "body"; typeSize: "small"
                                    color: MeoTheme.contentOnSurfaceVariant
                                }
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: root.compactLayout ? 1 : 0
                            visible: root.compactLayout
                            Rectangle {
                                anchors.fill: parent
                                color: MeoTheme.outlineVariant
                            }
                        }

                        MeoText {
                            Layout.fillWidth: true
                            visible: root.compactLayout
                            text: qsTr("问题分类")
                            typeRole: "title"; typeSize: "small"; emphasized: true
                            color: MeoTheme.contentOnSurface
                        }
                        MeoText {
                            Layout.fillWidth: true
                            visible: root.compactLayout
                            text: qsTr("小屏布局会在这里保留全部分类；命令行只运行相同的固定检查。")
                            wrapMode: Text.WordWrap
                            typeRole: "body"; typeSize: "small"
                            color: MeoTheme.contentOnSurfaceVariant
                        }
                        GridLayout {
                            Layout.fillWidth: true
                            visible: root.compactLayout
                            columns: width >= root.dp(760) ? 3 : 2
                            columnSpacing: root.dp(8)
                            rowSpacing: root.dp(8)
                            Repeater {
                                model: root.repairController.checkCategories
                                delegate: MeoButton {
                                    required property var modelData
                                    Layout.fillWidth: true
                                    text: modelData.title
                                    icon.name: modelData.icon
                                    type: root.selectedCategory === modelData.id ? "tonal" : "outlined"
                                    selected: root.selectedCategory === modelData.id
                                    Accessible.name: qsTr("选择检查分类：") + modelData.title
                                    onClicked: root.selectedCategory = modelData.id
                                }
                            }
                        }
                    }
                }

                MeoCard {
                    Layout.fillWidth: true
                    type: "filled"
                    padding: root.dp(20)
                    RowLayout {
                        width: parent.width
                        spacing: root.dp(16)
                        MeoIcon { icon: "verified_user"; size: 34; color: MeoTheme.primary }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: root.dp(3)
                            MeoText {
                                text: qsTr("AI 不能生成或控制 Shell 命令")
                                typeRole: "title"; typeSize: "small"; emphasized: true
                                color: MeoTheme.contentOnSurface
                            }
                            MeoText {
                                Layout.fillWidth: true
                                text: qsTr("模型只能选择程序内固定的动作 ID。第二个不同模型复核同一计划哈希；用户输入精确确认短语后，固定脚本才会执行。")
                                wrapMode: Text.WordWrap
                                typeRole: "body"; typeSize: "small"
                                color: MeoTheme.contentOnSurfaceVariant
                            }
                        }
                    }
                }

                MeoBanner {
                    Layout.fillWidth: true
                    visible: root.repairController.liveEnvironment
                    title: qsTr("Live TTY 诊断终端")
                    text: root.repairController.diagnosticTtyMessage
                    icon: "terminal"
                }

                MeoCard {
                    Layout.fillWidth: true
                    type: "elevated"
                    padding: root.dp(20)
                    ColumnLayout {
                        width: parent.width
                        spacing: root.dp(14)
                        RowLayout {
                            Layout.fillWidth: true
                            MeoIcon { icon: root.selectedCategoryMeta().icon; size: 30; color: MeoTheme.primary }
                            ColumnLayout {
                                Layout.fillWidth: true; spacing: 0
                                MeoText {
                                    text: qsTr("1 · 快速检查：") + root.selectedCategoryMeta().title
                                    typeRole: "title"; typeSize: "small"; emphasized: true
                                    color: MeoTheme.contentOnSurface
                                }
                                MeoText {
                                    Layout.fillWidth: true
                                    text: root.visualPreview
                                          ? qsTr("网络检查完成：发现 2 个需要注意的项目；尚未执行任何修复。")
                                          : root.repairController.auditSummary
                                    wrapMode: Text.WordWrap
                                    typeRole: "body"; typeSize: "small"
                                    color: MeoTheme.contentOnSurfaceVariant
                                }
                            }
                            MeoButton {
                                text: root.repairController.auditState === "running" ? qsTr("停止") : qsTr("运行检查")
                                type: root.repairController.auditState === "running" ? "outlined" : "filled"
                                icon.name: root.repairController.auditState === "running" ? "stop" : "play_arrow"
                                enabled: !root.visualPreview
                                onClicked: {
                                    if (root.repairController.auditState === "running")
                                        root.repairController.cancelQuickCheck()
                                    else
                                        root.repairController.startQuickCheck(root.selectedCategory)
                                }
                            }
                        }
                        MeoProgressBar {
                            Layout.fillWidth: true
                            visible: root.repairController.auditState === "running"
                            indeterminate: true; vibrant: true; isThick: true
                        }
                        MeoText {
                            Layout.fillWidth: true
                            visible: root.repairController.auditState !== "complete"
                                     && root.repairController.auditState !== "running"
                            text: qsTr("完成这项只读检查后，才能请求 AI 生成受限的修复方案。")
                            wrapMode: Text.WordWrap
                            typeRole: "body"; typeSize: "small"
                            color: MeoTheme.contentOnSurfaceVariant
                        }
                        Repeater {
                            model: root.visualPreview ? [
                                { "type": "warning", "text": "No IPv4 default route is configured." },
                                { "type": "suggestion", "text": "Check the active NetworkManager connection." }
                            ] : root.firstItems(root.repairController.auditFindings, 6)
                            delegate: RowLayout {
                                id: findingRow
                                required property var modelData
                                Layout.fillWidth: true
                                spacing: root.dp(9)
                                MeoIcon {
                                    icon: findingRow.modelData.type === "warning" ? "warning" : "lightbulb"
                                    size: 20
                                    color: findingRow.modelData.type === "warning" ? MeoTheme.error : MeoTheme.primary
                                }
                                MeoText {
                                    Layout.fillWidth: true
                                    text: findingRow.modelData.text
                                    wrapMode: Text.WordWrap
                                    typeRole: "body"; typeSize: "small"
                                    color: MeoTheme.contentOnSurfaceVariant
                                }
                            }
                        }
                        MeoButton {
                            text: root.showCheckLog ? qsTr("隐藏原始输出") : qsTr("查看原始输出")
                            type: "text"
                            icon.name: root.showCheckLog ? "expand_less" : "terminal"
                            onClicked: root.showCheckLog = !root.showCheckLog
                        }
                        MeoTextArea {
                            Layout.fillWidth: true
                            Layout.preferredHeight: root.showCheckLog ? root.dp(220) : 0
                            visible: root.showCheckLog
                            readOnly: true
                            label: qsTr("固定脚本输出")
                            text: root.visualPreview ? "[network] NetworkManager\nMEO_FINDING|warning|network.no_default_route|No IPv4 default route is configured." : root.repairController.checkLog
                        }
                    }
                }

                MeoCard {
                    Layout.fillWidth: true
                    type: "elevated"
                    padding: root.dp(20)
                    ColumnLayout {
                        width: parent.width
                        spacing: root.dp(14)
                        MeoBanner {
                            Layout.fillWidth: true
                            title: qsTr("AI 数据边界")
                            text: qsTr("AI 只会在单次同意后接收当前分类的结构化诊断发现。原始终端日志、网络地址、挂载标签、密码和 API Key 不会发送。")
                            icon: "privacy_tip"
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            MeoAiMark { Layout.preferredWidth: root.dp(44); Layout.preferredHeight: root.dp(44) }
                            ColumnLayout {
                                Layout.fillWidth: true; spacing: 0
                                MeoText {
                                    text: qsTr("2 · AI 来源（可选）")
                                    typeRole: "title"; typeSize: "small"; emphasized: true
                                    color: MeoTheme.contentOnSurface
                                }
                                MeoText {
                                    text: qsTr("默认不登录；可用本次会话密钥、KWallet，或切换 Account。")
                                    typeRole: "body"; typeSize: "small"
                                    color: MeoTheme.contentOnSurfaceVariant
                                }
                            }
                            MeoSegmentedButtons {
                                Layout.preferredWidth: Math.min(root.dp(390), Math.max(root.dp(270), parent.width * 0.46))
                                Layout.minimumWidth: root.dp(270)
                                model: [
                                    { "label": qsTr("本地安全密钥"), "icon": "key" },
                                    { "label": qsTr("Account（可选）"), "icon": "account_circle" }
                                ]
                                currentIndex: root.repairController.aiSource === "account" ? 1 : 0
                                onSelected: (index, data) => root.repairController.setAiSource(index === 1 ? "account" : "local")
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            visible: root.repairController.aiSource !== "account"
                            spacing: root.dp(12)
                            GridLayout {
                                Layout.fillWidth: true
                                columns: width > root.dp(760) ? 2 : 1
                                columnSpacing: root.dp(12); rowSpacing: root.dp(12)
                                MeoExposedDropdown {
                                    id: providerPicker
                                    Layout.fillWidth: true
                                    label: qsTr("AI 提供商")
                                    model: root.providerLabels
                                    text: root.providerLabels[root.providerIndex(root.selectedProvider)]
                                    onSelected: (index, value) => {
                                        root.selectedProvider = root.providerIds[index]
                                        root.configureProviderDefaults(root.selectedProvider)
                                    }
                                }
                                MeoTextField {
                                    id: endpointField
                                    Layout.fillWidth: true
                                    visible: root.selectedProvider === "ollama"
                                    label: qsTr("Ollama 回环地址")
                                    placeholder: "http://127.0.0.1:11434"
                                    type: "outlined"
                                }
                                MeoTextField {
                                    id: proposalModel
                                    Layout.fillWidth: true
                                    label: qsTr("方案模型")
                                    type: "outlined"
                                }
                                MeoTextField {
                                    id: reviewerModel
                                    Layout.fillWidth: true
                                    label: qsTr("风险复核模型（必须不同）")
                                    type: "outlined"
                                }
                            }
                            MeoTextField {
                                id: localKeyField
                                Layout.fillWidth: true
                                visible: root.selectedProvider !== "ollama"
                                label: qsTr("API Key（仅写入，不回显）")
                                isPassword: true
                                type: "outlined"
                                maxLength: 4096
                                helperText: qsTr("仅写入系统安全凭据库；“仅本次会话”会在退出后清除。")
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: root.dp(8)
                                MeoButton {
                                    text: qsTr("保存非敏感设置")
                                    type: "tonal"; icon.name: "settings"
                                    onClicked: root.repairController.configureLocalAi(
                                        root.selectedProvider, endpointField.text,
                                        proposalModel.text, reviewerModel.text)
                                }
                                MeoButton {
                                    visible: root.selectedProvider !== "ollama"
                                    text: qsTr("仅本次会话")
                                    type: "outlined"; icon.name: "memory"
                                    onClicked: {
                                        root.repairController.configureLocalAi(root.selectedProvider, endpointField.text, proposalModel.text, reviewerModel.text)
                                        root.repairController.saveLocalCredential(localKeyField.text, true)
                                        localKeyField.text = ""
                                    }
                                }
                                MeoButton {
                                    visible: root.selectedProvider !== "ollama"
                                    text: qsTr("保存到 KWallet")
                                    type: "filled"; icon.name: "lock"
                                    onClicked: {
                                        root.repairController.configureLocalAi(root.selectedProvider, endpointField.text, proposalModel.text, reviewerModel.text)
                                        root.repairController.saveLocalCredential(localKeyField.text, false)
                                        localKeyField.text = ""
                                    }
                                }
                                Item { Layout.fillWidth: true }
                                MeoButton {
                                    visible: root.repairController.hasSessionCredential
                                    text: qsTr("清除会话密钥"); type: "text"
                                    onClicked: root.repairController.clearSessionCredential()
                                }
                                MeoButton {
                                    visible: root.repairController.hasLocalCredential
                                    text: qsTr("删除已存密钥"); type: "text"
                                    onClicked: root.repairController.deleteLocalCredential()
                                }
                            }
                            MeoBanner {
                                Layout.fillWidth: true
                                title: root.repairController.hasSessionCredential ? qsTr("会话密钥可用")
                                      : root.repairController.hasLocalCredential ? qsTr("KWallet 密钥可用")
                                      : root.selectedProvider === "ollama" ? qsTr("无需 API Key") : qsTr("尚未设置密钥")
                                text: root.repairController.credentialMessage.length > 0
                                      ? root.repairController.credentialMessage
                                      : qsTr("拒绝同意时不会读取密钥；不提供明文回退存储。")
                                icon: root.repairController.hasLocalCredential ? "verified_user" : "privacy_tip"
                                tone: root.repairController.credentialState === "error" ? "error" : "tonal"
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            visible: root.repairController.aiSource === "account"
                            spacing: root.dp(12)
                            MeoBanner {
                                Layout.fillWidth: true
                                visible: !root.repairController.accountConfigured
                                title: qsTr("Account 连接未配置")
                                text: qsTr("这不会影响快速检查或本地 BYOK。")
                                icon: "cloud_off"
                            }
                            GridLayout {
                                Layout.fillWidth: true
                                visible: root.repairController.accountConfigured && !root.repairController.signedIn
                                columns: width > root.dp(720) ? 3 : 1
                                columnSpacing: root.dp(10); rowSpacing: root.dp(10)
                                MeoTextField { id: emailField; Layout.fillWidth: true; label: qsTr("邮箱"); type: "outlined" }
                                MeoTextField { id: passwordField; Layout.fillWidth: true; label: qsTr("密码"); isPassword: true; type: "outlined" }
                                MeoButton {
                                    text: qsTr("登录 Account"); type: "filled"
                                    onClicked: root.repairController.signIn(emailField.text, passwordField.text)
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                visible: root.repairController.mfaRequired
                                MeoTextField { id: totpField; Layout.fillWidth: true; label: qsTr("双重验证代码"); type: "outlined" }
                                MeoButton { text: qsTr("验证"); onClicked: root.repairController.verifyTotp(totpField.text) }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                visible: root.repairController.signedIn || root.visualPreview
                                MeoText { text: root.visualPreview ? "preview@meoarch.org" : root.repairController.accountEmail; color: MeoTheme.contentOnSurface }
                                Item { Layout.fillWidth: true }
                                MeoButton { text: qsTr("刷新连接"); type: "text"; onClicked: root.repairController.refreshCredentials() }
                                MeoButton { text: qsTr("退出登录"); type: "text"; onClicked: root.repairController.signOut() }
                            }
                            GridLayout {
                                Layout.fillWidth: true
                                visible: root.repairController.signedIn || root.visualPreview
                                columns: width > root.dp(720) ? 2 : 1
                                columnSpacing: root.dp(12); rowSpacing: root.dp(12)
                                MeoExposedDropdown {
                                    id: proposalPicker
                                    Layout.fillWidth: true; label: qsTr("方案 AI")
                                    model: root.credentialLabels
                                    onSelected: (index, value) => root.repairController.setProposalCredentialId(root.credentialId(index))
                                }
                                MeoExposedDropdown {
                                    id: reviewerPicker
                                    Layout.fillWidth: true; label: qsTr("独立风险复核 AI")
                                    model: root.credentialLabels
                                    onSelected: (index, value) => root.repairController.setReviewerCredentialId(root.credentialId(index))
                                }
                            }
                            MeoText {
                                Layout.fillWidth: true
                                visible: root.repairController.authMessage.length > 0
                                text: root.repairController.authMessage
                                wrapMode: Text.WordWrap
                                color: root.repairController.authState === "error" ? MeoTheme.error : MeoTheme.contentOnSurfaceVariant
                                typeRole: "body"; typeSize: "small"
                            }
                        }
                        MeoBanner {
                            Layout.fillWidth: true
                            visible: root.repairController.auditState === "complete"
                                     && ((root.repairController.aiSource === "account"
                                          && (!root.repairController.signedIn
                                              || root.repairController.proposalCredentialId.length === 0
                                              || root.repairController.reviewerCredentialId.length === 0
                                              || root.repairController.proposalCredentialId === root.repairController.reviewerCredentialId))
                                         || (root.repairController.aiSource !== "account"
                                             && root.selectedProvider !== "ollama"
                                             && !root.repairController.hasLocalCredential
                                             && !root.repairController.hasSessionCredential))
                            title: qsTr("AI 方案尚未就绪")
                            text: root.repairController.aiSource === "account"
                                  ? (!root.repairController.signedIn
                                     ? qsTr("仅在想使用 Account 管理的连接时登录；登录后选择两个不同的 AI。")
                                     : qsTr("请选择两个不同的 Account AI 连接，分别生成方案和独立复核风险。"))
                                  : qsTr("可填写一次性密钥或保存到 KWallet；不登录也能继续。")
                            icon: "info"
                        }
                    }
                }

                MeoCard {
                    Layout.fillWidth: true
                    type: "elevated"
                    padding: root.dp(20)
                    ColumnLayout {
                        width: parent.width
                        spacing: root.dp(12)
                        RowLayout {
                            Layout.fillWidth: true
                            MeoIcon { icon: "psychology"; size: 30; color: MeoTheme.primary }
                            ColumnLayout {
                                Layout.fillWidth: true; spacing: 0
                                MeoText { text: qsTr("3 · 定位问题并独立复核风险"); typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface }
                                MeoText { text: qsTr("每次模型调用都会显示完整目的、数据类别、目标地址、提示词与 SHA-256。"); typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
                            }
                            MeoButton {
                                text: qsTr("生成方案并复核")
                                type: "filled"
                                leadingComponent: Component {
                                    MeoAiMark { }
                                }
                                loading: ["preparing_consent", "invoking", "reading_credential"].indexOf(root.repairController.aiState) >= 0
                                enabled: !root.visualPreview && root.repairController.auditState === "complete"
                                onClicked: root.repairController.requestAiPlan()
                            }
                        }
                        MeoBanner {
                            Layout.fillWidth: true
                            visible: root.repairController.auditState !== "complete"
                            title: qsTr("先完成快速检查")
                            text: qsTr("AI 按钮会在固定检查完成后启用；这样模型只会看到本次诊断结果。")
                            icon: "troubleshoot"
                        }
                        MeoBanner {
                            Layout.fillWidth: true
                            visible: root.repairController.aiMessage.length > 0
                            title: qsTr("AI 状态：") + root.repairController.aiState
                            text: root.repairController.aiMessage
                            icon: root.repairController.aiState === "error" || root.repairController.aiState === "rejected" ? "error" : "info"
                            tone: root.repairController.aiState === "error" || root.repairController.aiState === "rejected" ? "error" : "tonal"
                        }
                        GridLayout {
                            Layout.fillWidth: true
                            visible: root.visualPreview || root.repairController.proposalJson.length > 0
                            columns: width > root.dp(760) ? 2 : 1
                            columnSpacing: root.dp(12); rowSpacing: root.dp(12)
                            MeoTextArea {
                                Layout.fillWidth: true; Layout.preferredHeight: root.dp(240)
                                label: qsTr("严格格式方案 org.meo.repair-plan/v1")
                                readOnly: true
                                text: root.visualPreview ? "{\n  \"schema\": \"org.meo.repair-plan/v1\",\n  \"actions\": [{\"id\":\"A1\",\"kind\":\"inspect_network_state\",\"reason\":\"Verify route state\"}]\n}" : root.repairController.proposalJson
                            }
                            MeoTextArea {
                                Layout.fillWidth: true; Layout.preferredHeight: root.dp(240)
                                label: qsTr("风险复核 org.meo.repair-risk-review/v1")
                                readOnly: true
                                text: root.visualPreview ? "{\n  \"schema\": \"org.meo.repair-risk-review/v1\",\n  \"verdict\": \"approve\",\n  \"requiredChanges\": []\n}" : root.repairController.riskReviewJson
                            }
                        }
                    }
                }

                MeoCard {
                    Layout.fillWidth: true
                    visible: root.visualPreview || root.repairController.planSha256.length > 0
                    type: "outlined"
                    padding: root.dp(20)
                    ColumnLayout {
                        width: parent.width
                        spacing: root.dp(10)
                        MeoText { text: qsTr("4 · 用户精确确认"); typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface }
                        MeoText {
                            Layout.fillWidth: true
                            text: qsTr("计划 SHA-256：") + (root.visualPreview ? "d10a6e27f25e770c9da9fb92a18a4f40e9e88c286ec5c78d6dd54a93259f1684" : root.repairController.planSha256)
                            wrapMode: Text.WrapAnywhere; font.family: "monospace"
                            color: MeoTheme.contentOnSurfaceVariant
                        }
                        MeoText {
                            text: qsTr("请输入：") + (root.visualPreview ? "APPLY REPAIR D10A6E27F25E" : root.repairController.confirmationPhrase)
                            emphasized: true; color: MeoTheme.error
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            MeoTextField {
                                id: confirmationField
                                Layout.fillWidth: true
                                label: qsTr("精确确认短语")
                                type: "outlined"
                                isError: text.length > 0
                                         && text !== root.repairController.confirmationPhrase
                                errorText: qsTr("确认短语需要完整匹配当前计划，请复制或逐字检查。")
                            }
                            MeoButton {
                                text: qsTr("执行已复核动作")
                                type: "filled"; vibrant: true; icon.name: "build_circle"
                                enabled: !root.visualPreview && root.repairController.readyToExecute
                                         && confirmationField.text === root.repairController.confirmationPhrase
                                onClicked: {
                                    root.repairController.executeConfirmedPlan(confirmationField.text)
                                    confirmationField.text = ""
                                }
                            }
                        }
                        MeoBanner {
                            Layout.fillWidth: true
                            visible: !root.visualPreview && !root.repairController.readyToExecute
                            title: qsTr("执行仍被阻止")
                            text: qsTr("只有第二个模型批准同一计划哈希、且没有要求修改时，执行按钮才会启用。")
                            icon: "gpp_maybe"
                        }
                    }
                }

                MeoCard {
                    Layout.fillWidth: true
                    visible: root.repairController.executionLog.length > 0
                    type: "filled"
                    padding: root.dp(20)
                    ColumnLayout {
                        width: parent.width; spacing: root.dp(8)
                        MeoText { text: qsTr("执行日志 · ") + root.repairController.executionState; typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface }
                        MeoTextArea { Layout.fillWidth: true; Layout.preferredHeight: root.dp(260); readOnly: true; text: root.repairController.executionLog }
                    }
                }
                Item { Layout.preferredHeight: root.dp(8) }
            }
        }
    }

    MeoMotionPopup {
        id: consentDialog
        presentation: MeoMotionPopup.Dialog
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: Math.min(root.width - root.dp(48), root.dp(920))
        height: Math.min(root.height - root.dp(48), root.dp(780))
        modal: true
        focus: true
        closePolicy: Popup.NoAutoClose
        padding: root.dp(22)
        contentItem: ColumnLayout {
            spacing: root.dp(14)
            RowLayout {
                Layout.fillWidth: true
                MeoAiMark { Layout.preferredWidth: root.dp(48); Layout.preferredHeight: root.dp(48) }
                ColumnLayout {
                    Layout.fillWidth: true; spacing: 0
                    MeoText {
                        text: root.consentSummary.stage === "review" ? qsTr("一次性同意 · 风险复核 AI") : qsTr("一次性同意 · 方案 AI")
                        typeRole: "title"; typeSize: "small"; emphasized: true
                        color: MeoTheme.contentOnSurface
                    }
                    MeoText { text: qsTr("在数据离开设备前逐项核对"); typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
                }
            }
            MeoCard {
                Layout.fillWidth: true
                type: "filled"; padding: root.dp(14)
                ColumnLayout {
                    width: parent.width; spacing: root.dp(4)
                    MeoText { Layout.fillWidth: true; text: qsTr("提供商：") + String(root.consentSummary.providerName || root.consentSummary.provider || "—"); color: MeoTheme.contentOnSurface }
                    MeoText { Layout.fillWidth: true; text: qsTr("目标：") + String(root.consentSummary.destination || "Meo Account broker"); wrapMode: Text.WrapAnywhere; color: MeoTheme.contentOnSurfaceVariant }
                    MeoText { Layout.fillWidth: true; text: qsTr("模型：") + String(root.consentSummary.model || "—"); color: MeoTheme.contentOnSurface }
                    MeoText { Layout.fillWidth: true; text: qsTr("用途：") + String(root.consentSummary.purpose || "—"); wrapMode: Text.WordWrap; color: MeoTheme.contentOnSurface }
                    MeoText { Layout.fillWidth: true; text: qsTr("数据类别：") + JSON.stringify(root.consentSummary.dataCategories || []); wrapMode: Text.WordWrap; color: MeoTheme.contentOnSurfaceVariant }
                    MeoText { Layout.fillWidth: true; text: qsTr("Payload SHA-256：") + String(root.consentSummary.payloadSha256 || "—"); wrapMode: Text.WrapAnywhere; font.family: "monospace"; color: MeoTheme.contentOnSurfaceVariant }
                }
            }
            ScrollView {
                Layout.fillWidth: true; Layout.fillHeight: true; clip: true
                ColumnLayout {
                    width: parent.width; spacing: root.dp(10)
                    MeoTextArea { Layout.fillWidth: true; Layout.preferredHeight: root.dp(155); label: qsTr("系统提示词"); text: String(root.consentSummary.systemPrompt || ""); readOnly: true }
                    MeoTextArea { Layout.fillWidth: true; Layout.preferredHeight: root.dp(220); label: qsTr("将发送的数据"); text: String(root.consentSummary.userPrompt || ""); readOnly: true }
                }
            }
            MeoCheckbox {
                Layout.fillWidth: true
                label: qsTr("我已检查每个字段，仅允许这一次请求。")
                checked: root.consentConfirmed
                onToggled: checked => root.consentConfirmed = checked
            }
            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }
                MeoButton {
                    text: qsTr("拒绝"); type: "text"
                    onClicked: {
                        consentDialog.close()
                        root.repairController.resolveAiConsent(false)
                    }
                }
                MeoButton {
                    text: qsTr("仅允许这一次并发送"); type: "filled"
                    enabled: root.consentConfirmed
                    onClicked: {
                        consentDialog.close()
                        root.repairController.resolveAiConsent(true)
                    }
                }
            }
        }
    }
}

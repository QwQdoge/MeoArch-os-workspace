pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import MeoUI 1.0
import Meo.System 1.0

Window {
    id: root

    required property var repairController
    required property var uiLanguageController
    property bool visualPreview: false
    property string uiLanguage: "en_US"
    property string uiLanguagePreference: "system"
    property string previewWizardStage: ""
    property string initialCategory: "all"
    property string selectedCategory: "all"
    property string selectedProvider: "openai"
    property bool showCheckLog: false
    property var consentSummary: ({})
    property bool consentConfirmed: false
    property string audioRepairMessage: ""
    property string pendingAudioAction: ""
    property string pendingAudioDeviceId: ""
    property int audioPostCheckAttempts: 0
    property var guidedQuestions: []
    property bool advancedMode: true
    property bool automaticInvestigationRequested: false
    property string wizardStage: "choose"
    property int wizardQuestionIndex: 0
    property string wizardSelectedAnswer: ""
    property string wizardProblem: ""
    property string wizardResultMessage: ""
    readonly property var currentWizardQuestion: wizardQuestionIndex >= 0
                                                 && wizardQuestionIndex < guidedQuestions.length
                                               ? guidedQuestions[wizardQuestionIndex] : ({})
    readonly property var helpCategoryGroups: repairController.liveEnvironment ? [
        {
            "title": qsTr("Live 环境"),
            "rows": root.categoryRows(["audio", "display", "network", "graphics", "security"])
        },
        {
            "title": repairController.mountedTargetAvailable
                     ? qsTr("已安装系统 · /mnt") : qsTr("已安装系统 · 尚未挂载"),
            "rows": root.categoryRows(["boot", "packages", "storage"])
        },
        {
            "title": qsTr("概览"),
            "rows": root.categoryRows(["all"])
        }
    ] : [
        {
            "title": qsTr("常见问题"),
            "rows": root.categoryRows(["audio", "display", "network"])
        },
        {
            "title": qsTr("系统"),
            "rows": root.categoryRows(["boot", "packages", "storage", "graphics"])
        },
        {
            "title": qsTr("安全与其他"),
            "rows": root.categoryRows(["security", "all"])
        }
    ]
    readonly property int wizardProgressIndex: {
        if (["choose", "describe", "question"].indexOf(wizardStage) >= 0)
            return 0
        if (wizardStage === "checking")
            return 1
        if (["repair", "ai_planning", "repair_approval", "repairing",
             "display_confirm"].indexOf(wizardStage) >= 0)
            return 2
        return 3
    }

    // The permanent navigation rail makes scanning fast on a large display,
    // but it leaves too little working space for the four-step flow on a
    // laptop-sized live session. The same categories are surfaced inline when
    // compact, so the path remains keyboard-accessible rather than hidden.
    readonly property bool compactLayout: width < dp(1180)
    readonly property bool auditComplete: repairController.auditState === "complete"
    readonly property bool aiOperationBusy: ["preparing_consent", "awaiting_consent",
                                              "reading_credential", "invoking"]
                                             .indexOf(repairController.aiState) >= 0
    readonly property bool workflowBusy: repairController.auditState === "running"
                                         || repairController.audioRecoveryState === "running"
                                         || repairController.displayRecoveryState === "awaiting_confirmation"
                                         || aiOperationBusy
                                         || repairController.executionState === "running"
                                         || pendingAudioAction.length > 0
                                         || SystemState.operationBusy
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
            return qsTr("检查结果已就绪。接下来可让 AI 根据这些发现准备方案；任何修复仍需你确认后才会执行。")
        return qsTr("先选择问题分类，我们会进行安全的只读检查。无需登录或配置 API Key。")
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
    color: MeoTheme.surfaceContainerLow
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
    function wizardAnswerOptions() {
        const source = root.currentWizardQuestion.options || []
        const result = []
        for (let index = 0; index < source.length; ++index) {
            result.push({
                "label": source[index].label,
                "checked": root.wizardSelectedAnswer === source[index].id
            })
        }
        return result
    }
    function categoryIcon(category) {
        const categories = root.repairController.checkCategories
        for (let index = 0; index < categories.length; ++index) {
            if (categories[index].id === category)
                return categories[index].icon
        }
        return "troubleshoot"
    }
    function categoryMetadata(category) {
        const categories = root.repairController.checkCategories
        for (let index = 0; index < categories.length; ++index) {
            if (categories[index].id === category)
                return ({ "id": category, "title": root.categoryLabel(category),
                          "description": root.categoryDescription(category),
                          "icon": categories[index].icon })
        }
        return ({ "id": category, "title": root.categoryLabel(category),
                  "description": root.categoryDescription(category),
                  "icon": root.categoryIcon(category) })
    }
    function diagnosticSubjectLabel(category) {
        const scope = root.categoryMetadata(category).scope
        if (scope === "target")
            return root.repairController.mountedTargetAvailable
                    ? qsTr("诊断对象 · 已安装系统（/mnt）")
                    : qsTr("诊断对象 · 已安装系统（尚未挂载）")
        if (scope === "live")
            return qsTr("诊断对象 · 当前 Live 环境")
        if (scope === "mixed")
            return qsTr("诊断对象 · Live 环境 + 已安装系统")
        return qsTr("诊断对象 · 当前已安装系统")
    }
    function diagnosticSubjectDescription(category) {
        const scope = root.categoryMetadata(category).scope
        if (scope === "target")
            return root.repairController.mountedTargetAvailable
                    ? qsTr("此检查读取 /mnt 下的目标系统，不把 Live 系统本身当作目标。")
                    : qsTr("需要先把已安装系统挂载到 /mnt；当前只会返回有限的目标检查信息。")
        if (scope === "live")
            return qsTr("此检查只描述当前从安装介质启动的 Live 系统。")
        if (scope === "mixed")
            return qsTr("概览会明确分段显示 Live 环境与 /mnt 下的已安装系统。")
        return qsTr("此检查描述当前正在运行的已安装 MeoArch 系统。")
    }

    function categoryRows(ids) {
        const result = []
        for (let index = 0; index < ids.length; ++index) {
            const item = root.categoryMetadata(ids[index])
            result.push({
                "route": "category:" + item.id,
                "title": item.title,
                "subtitle": item.description,
                "leadingIcon": item.icon,
                "trailingKind": "navigation"
            })
        }
        return result
    }
    function categorySearchResults(query) {
        const normalized = query.trim().toLowerCase()
        if (normalized.length === 0)
            return []
        const result = []
        const categories = root.repairController.checkCategories
        for (let index = 0; index < categories.length; ++index) {
            const item = root.categoryMetadata(categories[index].id)
            const haystack = (item.title + " " + item.description + " " + item.id).toLowerCase()
            if (haystack.indexOf(normalized) >= 0)
                result.push(root.categoryRows([item.id])[0])
        }
        return result
    }
    function investigateCategory(category, requestAi) {
        if (root.workflowBusy)
            return
        root.chooseCategory(category)
        root.automaticInvestigationRequested = requestAi
        root.repairController.startQuickCheck(category)
    }
    function investigateProblem(problem) {
        const normalized = problem.trim()
        if (normalized.length === 0 || root.workflowBusy)
            return
        const category = root.repairController.classifyProblem(normalized)
        root.repairController.setUserProblem(normalized)
        root.investigateCategory(category, true)
    }
    function aiReadyForPlan() {
        if (root.repairController.aiSource === "account") {
            return root.repairController.signedIn
                    && root.repairController.proposalCredentialId.length > 0
                    && root.repairController.reviewerCredentialId.length > 0
                    && root.repairController.proposalCredentialId
                       !== root.repairController.reviewerCredentialId
        }
        return root.repairController.localProvider === "ollama"
                || root.repairController.hasLocalCredential
                || root.repairController.hasSessionCredential
    }
    function networkStatusLabel() {
        const state = root.repairController.networkConnectionState
        if (state === "online") return qsTr("网络 · 已联网")
        if (state === "portal") return qsTr("网络 · 需要登录")
        if (state === "limited") return qsTr("网络 · 受限")
        if (state === "connecting") return qsTr("网络 · 连接中")
        if (state === "offline") return qsTr("网络 · 离线")
        return qsTr("网络 · 不可用")
    }
    function networkStatusIcon() {
        const state = root.repairController.networkConnectionState
        if (state === "online") return "wifi"
        if (state === "portal") return "captive_portal"
        if (state === "limited") return "wifi_find"
        if (state === "connecting") return "sync"
        return "wifi_off"
    }
    function networkSignalIcon(strength) {
        if (strength >= 70) return "signal_wifi_4_bar"
        if (strength >= 40) return "network_wifi_3_bar"
        if (strength >= 20) return "network_wifi_2_bar"
        return "network_wifi_1_bar"
    }
    function accountStatusLabel() {
        const state = root.repairController.accountConnectionState
        if (state === "connected") return qsTr("Meo Account · 已连接")
        if (state === "connecting") return qsTr("Meo Account · 连接中")
        if (state === "available") return qsTr("Meo Account · 可登录")
        if (state === "error") return qsTr("Meo Account · 连接错误")
        return qsTr("Meo Account · 未配置")
    }
    function accountStatusIcon() {
        return root.repairController.accountConnectionState === "connected"
                ? "account_circle" : "person_off"
    }
    function categoryLabel(category) {
        if (category === "audio") return qsTr("声音")
        if (category === "display") return qsTr("显示器")
        if (category === "network") return qsTr("网络")
        if (category === "boot") return qsTr("启动")
        if (category === "packages") return qsTr("系统更新")
        if (category === "storage") return qsTr("存储设备")
        if (category === "graphics") return qsTr("显卡和画面")
        if (category === "security") return qsTr("系统安全")
        return qsTr("系统")
    }
    function categoryDescription(category) {
        if (category === "audio") return qsTr("扬声器、耳机、音量和 PipeWire 服务")
        if (category === "display") return qsTr("外接显示器、输出状态和安全回退")
        if (category === "network") return qsTr("网络连接、路由、DNS 和 NetworkManager")
        if (category === "boot") return qsTr("启动项、挂载和失败的系统服务")
        if (category === "packages") return qsTr("软件包数据库、签名和文件完整性")
        if (category === "storage") return qsTr("磁盘空间、挂载、SMART 和 Btrfs 状态")
        if (category === "graphics") return qsTr("显卡驱动、内核消息和桌面会话")
        if (category === "security") return qsTr("系统安全检查和加固建议")
        return qsTr("运行所有安全的只读诊断")
    }
    function findingLabel(finding) {
        const code = finding.code || ""
        const labels = {
            "network.manager_inactive": qsTr("网络管理服务没有运行。"),
            "network.captive_portal": qsTr("网络已经连接，但还需要在登录页面完成认证。"),
            "network.limited_connectivity": qsTr("当前网络只有受限连接，无法确认完整互联网访问。"),
            "network.no_internet": qsTr("NetworkManager 报告当前没有互联网连接。"),
            "network.connectivity_unknown": qsTr("系统目前无法确认互联网连接状态。"),
            "network.wifi_disabled": qsTr("检测到 Wi-Fi 设备，但无线功能目前已关闭。"),
            "network.no_default_route": qsTr("电脑没有可用的 IPv4 或 IPv6 默认网络路线。"),
            "network.no_dns_server": qsTr("电脑没有可用的 DNS 服务器。"),
            "packages.target_not_mounted": qsTr("Live 环境中还没有挂载可检查的已安装系统。"),
            "scope.target_not_mounted": qsTr("没有在 /mnt 找到已挂载的目标系统。"),
            "packages.database_inconsistent": qsTr("软件包数据库存在不一致。"),
            "packages.files_inconsistent": qsTr("部分软件包文件缺失或已经改变。"),
            "packages.keyring_unreadable": qsTr("系统无法正常读取软件包签名密钥。"),
            "boot.failed_units": qsTr("一个或多个系统服务启动失败。"),
            "boot.loader_grub": qsTr("检测到系统使用 GRUB 引导。"),
            "boot.loader_limine": qsTr("检测到系统使用 Limine 引导。"),
            "boot.loader_systemd_boot": qsTr("检测到系统使用 systemd-boot 引导。"),
            "boot.loader_unknown": qsTr("没有找到可识别的 GRUB、Limine 或 systemd-boot 配置。"),
            "boot.offline_service_state": qsTr("Live 模式不会把自身的失败服务状态当作目标系统故障。"),
            "boot.target_boot_missing": qsTr("已挂载系统缺少启动目录。"),
            "boot.target_boot_not_mounted": qsTr("已安装系统的启动分区尚未挂载。"),
            "boot.boot_not_mounted": qsTr("系统需要的启动分区目前没有挂载。"),
            "boot.initramfs_missing": qsTr("系统缺少可用的启动初始镜像。"),
            "boot.manager_reload_needed": qsTr("系统服务配置已经改变，需要重新载入。"),
            "storage.root_nearly_full": qsTr("系统磁盘空间已使用至少 90%。"),
            "storage.target_root_nearly_full": qsTr("已挂载目标系统的根分区空间已使用至少 90%。"),
            "storage.target_not_mounted": qsTr("Live 环境没有在 /mnt 找到已挂载的目标系统根分区。"),
            "storage.btrfs_device_errors": qsTr("Btrfs 检测到非零设备错误。"),
            "storage.smart_failed": qsTr("磁盘健康检查报告硬件故障。"),
            "storage.nvme_critical_warning": qsTr("NVMe 磁盘报告严重健康警告。"),
            "graphics.no_drm_device": qsTr("系统没有检测到可用的图形设备节点。"),
            "graphics.nvidia_module_not_loaded": qsTr("检测到 NVIDIA 显卡，但驱动模块没有载入。"),
            "graphics.nvidia_drm_modeset_disabled": qsTr("NVIDIA 的 Wayland 显示模式支持没有启用。"),
            "security.lynis_missing": qsTr("系统安全检查工具尚未安装。"),
            "security.no_report": qsTr("安全检查没有生成有效报告。")
        }
        if (labels[code])
            return labels[code]
        if (code.indexOf("security.lynis_") === 0)
            return qsTr("安全检查发现一项需要人工确认的设置：%1").arg(finding.text || code)
        return finding.text || code
    }
    function actionLabel(kind) {
        if (kind === "restart_network_manager")
            return qsTr("重新启动网络服务，然后检查连接、路线和 DNS")
        if (kind === "refresh_pacman_keyring")
            return qsTr("重新载入系统软件包签名密钥，然后验证密钥库")
        if (kind === "rebuild_initramfs")
            return qsTr("重新生成启动初始镜像，然后确认镜像有效")
        if (kind === "reload_systemd_manager")
            return qsTr("重新载入系统服务配置，然后确认服务管理器可响应")
        return qsTr("运行已批准的固定安全动作")
    }
    function wizardPlan() {
        if (root.visualPreview && root.previewWizardStage === "repair-approval") {
            return {
                "summary": qsTr("网络服务状态异常；AI 方案和独立风险复核都只批准重新启动网络服务。"),
                "actions": [{
                    "id": "A1",
                    "kind": "restart_network_manager",
                    "reason": qsTr("网络管理服务没有运行，并且当前没有默认网络路线。")
                }]
            }
        }
        if (root.repairController.proposalJson.length === 0)
            return ({})
        try {
            return JSON.parse(root.repairController.proposalJson)
        } catch (error) {
            return ({})
        }
    }
    function wizardPlanActions() {
        const plan = root.wizardPlan()
        return plan.actions instanceof Array ? plan.actions : []
    }
    function wizardPlanHasWriteAction() {
        const writeKinds = ["restart_network_manager", "refresh_pacman_keyring",
                            "rebuild_initramfs", "reload_systemd_manager"]
        const actions = root.wizardPlanActions()
        for (let index = 0; index < actions.length; ++index) {
            if (writeKinds.indexOf(actions[index].kind) >= 0)
                return true
        }
        return false
    }
    function wizardPlanSummary() {
        const plan = root.wizardPlan()
        return plan.summary || root.repairController.aiMessage
    }
    function previewFindings() {
        if (selectedCategory === "audio") {
            return [
                { "type": "info", "text": qsTr("找到多个声音输出；当前默认设备可能不是你想使用的设备。") },
                { "type": "info", "text": qsTr("已保存的首选声音输出目前不可用，桌面正在使用备用输出。") }
            ]
        }
        if (selectedCategory === "display") {
            return [
                { "type": "warning", "text": qsTr("当前布局中至少有一个已连接的显示器未启用。") }
            ]
        }
        return [
            { "type": "warning", "text": qsTr("没有配置 IPv4 默认路由。") },
            { "type": "suggestion", "text": qsTr("检查当前活跃的 NetworkManager 连接。") }
        ]
    }
    function previewCheckLog() {
        if (selectedCategory === "audio")
            return "[audio] outputs\nMEO_FINDING|info|audio.multiple_outputs|Multiple audio outputs are available."
        if (selectedCategory === "display")
            return "[display] KScreen outputs\nMEO_FINDING|warning|display.connected_output_disabled|A connected display is disabled."
        return "[network] NetworkManager\nMEO_FINDING|warning|network.no_default_route|No IPv4 default route is configured."
    }
    function selectedCategoryMeta() {
        return categoryMetadata(selectedCategory)
    }
    function localizedAuditSummary() {
        const category = selectedCategoryMeta().title
        if (repairController.auditState === "complete")
            return qsTr("%1 检查完成；尚未执行任何修复。").arg(category)
        if (repairController.auditState === "running")
            return qsTr("正在检查%1的状态。").arg(category)
        if (repairController.auditState === "idle")
            return qsTr("选择分类后，即可开始安全的只读检查。")
        return qsTr("检查没有完成：%1").arg(repairController.auditSummary)
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

    function describeAndCheck() {
        if (root.workflowBusy)
            return
        const problem = problemField.text.trim()
        root.chooseCategory(root.repairController.classifyProblem(problem))
        root.repairController.setUserProblem(problem)
        root.repairController.startQuickCheck(root.selectedCategory)
    }

    function chooseCategory(category) {
        if (root.workflowBusy)
            return
        root.repairController.prepareGuidedCategory(category)
        root.selectedCategory = root.repairController.selectedCategory
        root.guidedQuestions = root.repairController.guidedQuestionsForCategory(root.selectedCategory)
    }

    function startWizard(category, problem) {
        if (root.workflowBusy)
            return
        root.chooseCategory(category)
        root.wizardProblem = problem
        problemField.text = problem
        root.repairController.setUserProblem(problem)
        root.wizardQuestionIndex = 0
        root.wizardSelectedAnswer = ""
        root.wizardResultMessage = ""
        if (root.guidedQuestions.length > 0) {
            root.wizardStage = "question"
        } else {
            root.wizardStage = "checking"
            root.repairController.startQuickCheck(root.selectedCategory)
        }
    }

    function startDescribedWizard() {
        const problem = wizardProblemField.text.trim()
        if (problem.length === 0 || root.workflowBusy)
            return
        root.startWizard(root.repairController.classifyProblem(problem), problem)
    }

    function selectWizardAnswer(questionId, optionId) {
        root.repairController.setGuidedAnswer(questionId, optionId)
        root.wizardSelectedAnswer = optionId
    }

    function previousWizardQuestion() {
        if (root.wizardQuestionIndex <= 0) {
            root.wizardStage = "choose"
            root.wizardSelectedAnswer = ""
            return
        }
        --root.wizardQuestionIndex
        const question = root.guidedQuestions[root.wizardQuestionIndex]
        root.wizardSelectedAnswer = root.repairController.guidedAnswers[question.id] || ""
    }

    function advanceWizardQuestion() {
        if (root.wizardSelectedAnswer.length === 0 || root.workflowBusy)
            return
        const answeredQuestion = root.currentWizardQuestion.id || ""
        if (root.selectedCategory === "display" && answeredQuestion === "detected"
                && root.wizardSelectedAnswer === "no") {
            root.wizardResultMessage = root.repairController.guidedHandoffMessage
            root.wizardStage = "handoff"
            return
        }
        if (root.selectedCategory === "display" && answeredQuestion === "stable"
                && root.wizardSelectedAnswer === "no") {
            root.wizardResultMessage = root.repairController.guidedHandoffMessage
            root.wizardStage = "handoff"
            return
        }
        if (root.selectedCategory === "display" && answeredQuestion === "visible"
                && root.wizardSelectedAnswer === "yes") {
            root.wizardResultMessage = qsTr("第二个显示器已经有画面，不需要更改显示布局。")
            root.wizardStage = "done"
            return
        }
        if (root.wizardQuestionIndex + 1 < root.guidedQuestions.length) {
            ++root.wizardQuestionIndex
            const question = root.guidedQuestions[root.wizardQuestionIndex]
            root.wizardSelectedAnswer = root.repairController.guidedAnswers[question.id] || ""
            return
        }

        if (root.selectedCategory === "audio"
                && root.repairController.guidedAnswers["scope"] === "one_app") {
            root.wizardResultMessage = qsTr("只有一个应用受影响，因此不会更改整个系统的声音服务。请先检查该应用自己的输出设备和音量。")
            root.wizardStage = "handoff"
            return
        }
        if (root.selectedCategory === "display"
                && root.repairController.guidedAnswers["visible"] === "yes") {
            root.wizardResultMessage = qsTr("第二个显示器已经有画面，不需要更改显示布局。")
            root.wizardStage = "done"
            return
        }
        if (root.repairController.guidedHandoffMessage.length > 0) {
            root.wizardResultMessage = root.repairController.guidedHandoffMessage
            root.wizardStage = "handoff"
            return
        }

        root.wizardStage = "checking"
        root.repairController.startQuickCheck(root.selectedCategory)
    }

    function firstDisabledDisplay() {
        const outputs = root.repairController.displayOutputs
        for (let index = 0; index < outputs.length; ++index) {
            if (outputs[index].connected && !outputs[index].enabled)
                return outputs[index]
        }
        return null
    }

    function applyWizardAudioRepair() {
        if (root.workflowBusy)
            return
        root.wizardStage = "repairing"
        if (root.repairController.audioServiceRepairAvailable) {
            root.repairController.restartAudioServices()
            return
        }
        root.repairController.clearPlan()
        SystemState.clearOperationError()
        root.pendingAudioAction = "unmute"
        root.audioPostCheckAttempts = 0
        root.audioRepairMessage = qsTr("正在解除静音并复查……")
        SystemState.audioMuted = false
        if (SystemState.volumePercent === 0)
            SystemState.volumePercent = 50
        audioPostCheck.restart()
    }

    function useWizardAudioDevice(deviceId) {
        if (root.workflowBusy)
            return
        root.repairController.clearPlan()
        SystemState.clearOperationError()
        root.pendingAudioAction = "output"
        root.pendingAudioDeviceId = deviceId
        root.audioPostCheckAttempts = 0
        root.audioRepairMessage = qsTr("正在切换默认输出并复查……")
        root.wizardStage = "repairing"
        SystemState.setDefaultAudioOutput(deviceId)
        audioPostCheck.restart()
    }

    function requestWizardAiPlan() {
        if (root.workflowBusy)
            return
        root.wizardResultMessage = ""
        root.wizardStage = "ai_planning"
        root.repairController.requestAiPlan()
    }

    function approveWizardAiRepair() {
        if (root.workflowBusy || !root.repairController.readyToExecute
                || !root.wizardPlanHasWriteAction())
            return
        root.wizardStage = "repairing"
        root.repairController.executeConfirmedPlan(root.repairController.confirmationPhrase)
    }

    function resetWizard() {
        if (root.workflowBusy)
            return
        root.chooseCategory("all")
        root.wizardStage = "choose"
        root.wizardQuestionIndex = 0
        root.wizardSelectedAnswer = ""
        root.wizardProblem = ""
        root.wizardResultMessage = ""
        wizardProblemField.text = ""
    }

    Timer {
        id: audioPostCheck
        interval: 600
        repeat: false
        onTriggered: {
            ++root.audioPostCheckAttempts
            let postCheckPassed = false
            if (root.pendingAudioAction === "unmute") {
                postCheckPassed = !SystemState.audioMuted && SystemState.volumePercent > 0
                root.audioRepairMessage = postCheckPassed
                        ? qsTr("已解除静音并通过音量状态复查。请播放声音确认实际听感。")
                        : qsTr("音频状态复查未通过；没有继续更改其他设置。")
            } else if (root.pendingAudioAction === "output") {
                let active = false
                for (let index = 0; index < SystemState.audioOutputDevices.length; ++index) {
                    const item = SystemState.audioOutputDevices[index]
                    if (item.id === root.pendingAudioDeviceId && item.active)
                        active = true
                }
                postCheckPassed = active
            }
            if (!postCheckPassed && root.audioPostCheckAttempts < 5
                    && (SystemState.operationBusy
                        || SystemState.operationError.length === 0)) {
                root.audioRepairMessage = qsTr("正在等待声音设备确认更改（%1/5）……")
                        .arg(root.audioPostCheckAttempts)
                audioPostCheck.restart()
                return
            }
            if (root.pendingAudioAction === "output") {
                root.audioRepairMessage = postCheckPassed
                        ? qsTr("默认输出已切换并通过状态复查。请播放声音确认实际听感。")
                        : SystemState.operationError.length > 0
                          ? qsTr("无法切换输出：%1。没有继续更改其他设置。")
                                .arg(SystemState.operationError)
                          : qsTr("输出切换复查未通过；没有继续更改其他设置。")
            }
            root.pendingAudioAction = ""
            root.pendingAudioDeviceId = ""
            if (!root.advancedMode && root.wizardStage === "repairing") {
                root.wizardResultMessage = root.audioRepairMessage
                root.wizardStage = postCheckPassed ? "verify" : "handoff"
                if (postCheckPassed)
                    Qt.callLater(function() { root.repairController.playAudioTestTone() })
            }
        }
    }

    component WizardIcon: Item {
        property string icon: "help"
        property color iconColor: MeoTheme.contentOnPrimaryContainer

        implicitWidth: root.dp(52)
        implicitHeight: root.dp(52)

        MeoShape {
            anchors.fill: parent
            type: "rect"
            radius: root.dp(18)
            color: MeoTheme.primaryContainer
        }
        MeoIcon {
            anchors.centerIn: parent
            icon: parent.icon
            size: 28
            color: parent.iconColor
        }
    }

    Component.onCompleted: {
        MeoTheme.isDarkMode = false
        repairController.refreshEnvironmentState()
        chooseCategory(initialCategory)
        selectedProvider = repairController.localProvider
        providerPicker.currentIndex = providerIndex(selectedProvider)
        endpointField.text = repairController.localEndpoint
        proposalModel.text = repairController.localProposalModel
        reviewerModel.text = repairController.localReviewerModel
        if (initialCategory === "audio")
            startWizard("audio", qsTr("我听不到声音"))
        else if (initialCategory === "display")
            startWizard("display", qsTr("第二个显示器没有画面"))
        else if (initialCategory !== "all")
            startWizard(initialCategory, qsTr("我需要解决%1问题").arg(
                            root.categoryLabel(initialCategory)))
        if (visualPreview) {
            proposalPicker.currentIndex = 0
            reviewerPicker.currentIndex = 1
            if (previewWizardStage === "repair-approval")
                wizardStage = "repair_approval"
        }
    }

    Timer {
        interval: 10000
        repeat: true
        running: root.visible
        onTriggered: root.repairController.refreshEnvironmentState()
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
        function onAuditChanged() {
            if (root.advancedMode && root.automaticInvestigationRequested
                    && root.repairController.auditState === "complete") {
                root.automaticInvestigationRequested = false
                if (root.repairController.auditFindings.length > 0
                        && root.aiReadyForPlan()) {
                    root.repairController.requestAiPlan()
                } else if (root.selectedCategory === "audio"
                           && root.repairController.auditFindings.length === 0) {
                    root.repairController.playAudioTestTone()
                }
                return
            }
            if (root.advancedMode && root.repairController.auditState === "error") {
                root.automaticInvestigationRequested = false
                return
            }
            if (root.advancedMode || root.wizardStage !== "checking")
                return
            if (root.repairController.auditState === "complete") {
                if (root.selectedCategory === "audio"
                        && !root.repairController.audioServiceRepairAvailable
                        && !SystemState.audioMuted && SystemState.volumePercent > 0) {
                    if (!SystemState.audioAvailable
                            || SystemState.audioOutputDevices.length === 0) {
                        root.wizardResultMessage = qsTr("声音服务正在运行，但没有检测到可用的真实输出设备。请检查耳机、HDMI、USB 或蓝牙连接。")
                        root.wizardStage = "handoff"
                    } else if (SystemState.audioOutputDevices.length === 1) {
                        root.wizardResultMessage = qsTr("没有发现可安全自动更改的状态。现在播放测试声音进行实际确认。")
                        root.wizardStage = "verify"
                        Qt.callLater(function() { root.repairController.playAudioTestTone() })
                    } else {
                        root.wizardStage = "repair"
                    }
                } else {
                    root.wizardStage = "repair"
                }
            } else if (root.repairController.auditState === "error") {
                root.wizardResultMessage = root.repairController.auditSummary
                root.wizardStage = "handoff"
            }
        }
        function onAiChanged() {
            if (root.advancedMode || root.wizardStage !== "ai_planning")
                return
            if (root.repairController.readyToExecute) {
                if (root.wizardPlanHasWriteAction()) {
                    root.wizardStage = "repair_approval"
                } else {
                    root.wizardResultMessage = qsTr("AI 没有找到可以安全自动执行的修复动作；不会用检查动作冒充修复。")
                    root.wizardStage = "handoff"
                }
            } else if (["advice", "rejected", "denied", "error"].indexOf(
                           root.repairController.aiState) >= 0) {
                root.wizardResultMessage = root.repairController.aiMessage
                root.wizardStage = "handoff"
            }
        }
        function onExecutionChanged() {
            if (root.advancedMode || root.selectedCategory === "audio"
                    || root.selectedCategory === "display")
                return
            if (root.repairController.executionState === "running") {
                root.wizardStage = "repairing"
            } else if (root.repairController.executionState === "complete") {
                root.wizardResultMessage = qsTr("固定修复动作已经完成，并通过动作自带的状态复查。")
                root.wizardStage = "verify"
            } else if (["error", "complete_with_errors"].indexOf(
                           root.repairController.executionState) >= 0) {
                root.wizardResultMessage = root.repairController.executionLog
                root.wizardStage = "handoff"
            }
        }
        function onGuidedChanged() {
            if (root.advancedMode || root.wizardStage !== "repairing"
                    || root.selectedCategory !== "audio")
                return
            if (root.repairController.audioRecoveryState === "complete") {
                root.wizardResultMessage = root.repairController.audioRecoveryMessage
                root.wizardStage = "verify"
                Qt.callLater(function() { root.repairController.playAudioTestTone() })
            } else if (["error", "blocked"].indexOf(root.repairController.audioRecoveryState) >= 0) {
                root.wizardResultMessage = root.repairController.audioRecoveryMessage
                root.wizardStage = "handoff"
            }
        }
        function onDisplayRecoveryChanged() {
            if (root.advancedMode || root.selectedCategory !== "display")
                return
            if (root.repairController.displayRecoveryState === "awaiting_confirmation") {
                root.wizardStage = "display_confirm"
            } else if (root.repairController.displayRecoveryState === "kept") {
                root.wizardResultMessage = qsTr("第二个显示器已保持启用，状态复查通过。")
                root.wizardStage = "done"
            } else if (root.repairController.displayRecoveryState === "reverted") {
                root.wizardResultMessage = qsTr("显示更改已安全还原。")
                root.wizardStage = "handoff"
            } else if (["error", "blocked", "unavailable"].indexOf(
                           root.repairController.displayRecoveryState) >= 0
                       && ["repairing", "display_confirm"].indexOf(root.wizardStage) >= 0) {
                root.wizardResultMessage = root.repairController.displayRecoveryMessage
                root.wizardStage = "handoff"
            }
        }
    }

    MeoShape {
        anchors.fill: parent
        type: "rect"
        radius: 0
        color: MeoTheme.surfaceContainerLow

        MeoShape {
            width: root.dp(420); height: width
            type: "rect"; radius: width / 2
            color: MeoTheme.primaryContainer; opacity: 0.16
            anchors.right: parent.right; anchors.top: parent.top
            anchors.rightMargin: -width * 0.36; anchors.topMargin: -height * 0.50
        }
        MeoShape {
            width: root.dp(300); height: width
            type: "rect"; radius: width / 2
            color: MeoTheme.tertiaryContainer; opacity: 0.12
            anchors.left: parent.left; anchors.bottom: parent.bottom
            anchors.leftMargin: -width * 0.48; anchors.bottomMargin: -height * 0.52
        }
    }

    RowLayout {
        id: appBar
        anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
        anchors.leftMargin: root.dp(28); anchors.rightMargin: root.dp(20)
        anchors.topMargin: root.dp(18)
        height: root.dp(56)
        spacing: root.dp(12)

        MeoAiMark { Layout.preferredWidth: root.dp(42); Layout.preferredHeight: root.dp(42) }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            MeoText {
                text: qsTr("系统帮助")
                typeRole: "title"; typeSize: "medium"; emphasized: true
                color: MeoTheme.contentOnSurface
            }
            MeoText {
                text: qsTr("诊断问题、获取方案并安全修复")
                typeRole: "body"; typeSize: "small"
                color: MeoTheme.contentOnSurfaceVariant
            }
        }
        MeoIconButton {
            visible: root.advancedMode && root.repairController.diagnosticTtyAvailable
            icon.name: "terminal"; type: "outlined"; size: "l"
            Accessible.name: qsTr("打开 Live TTY 3 诊断终端")
            onClicked: root.repairController.openDiagnosticTty()
        }
        MeoIconButton {
            id: languageButton
            icon.name: "language"; type: "outlined"; size: "l"
            Accessible.name: qsTr("选择应用语言")
            onClicked: languageMenu.openFrom(languageButton)
        }
        MeoButton {
            text: root.repairController.signedIn ? root.repairController.accountEmail
                                                 : qsTr("登录账号（推荐）")
            icon.name: root.repairController.signedIn ? "account_circle" : "login"
            type: root.repairController.signedIn ? "tonal" : "outlined"
            size: "xs"
            enabled: root.repairController.accountConfigured && !root.workflowBusy
            onClicked: {
                root.repairController.setAiSource("account")
            }
        }
    }

    RowLayout {
        id: statusStrip
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: appBar.bottom
        anchors.leftMargin: root.dp(28)
        anchors.rightMargin: root.dp(20)
        anchors.topMargin: root.dp(2)
        height: root.dp(42)
        spacing: root.dp(8)

        MeoChip {
            label: root.repairController.liveEnvironment ? qsTr("Live 环境") : qsTr("已安装系统")
            icon: root.repairController.liveEnvironment ? "usb" : "desktop_windows"
            selected: true
        }
        MeoChip {
            label: root.networkStatusLabel()
            icon: root.networkStatusIcon()
            visualStyle: root.repairController.networkConnectionState === "online"
                         ? "filled" : "outlined"
            Accessible.description: root.repairController.networkConnectionMessage
        }
        MeoChip {
            visible: root.repairController.liveEnvironment
            label: root.repairController.mountedTargetAvailable
                   ? qsTr("目标系统 · 已挂载") : qsTr("目标系统 · 未挂载")
            icon: root.repairController.mountedTargetAvailable ? "hard_drive" : "drive_file_move"
            visualStyle: root.repairController.mountedTargetAvailable ? "filled" : "outlined"
        }
        MeoChip {
            label: root.accountStatusLabel()
            icon: root.accountStatusIcon()
            visualStyle: root.repairController.accountConnectionState === "connected"
                         ? "filled" : "outlined"
        }
        Item { Layout.fillWidth: true }
        MeoIconButton {
            icon.name: "refresh"
            type: "standard"
            size: "m"
            Accessible.name: qsTr("刷新环境、网络和目标系统状态")
            onClicked: root.repairController.refreshEnvironmentState()
        }
    }

    MeoMenu {
        id: languageMenu
        model: [
            {
                "label": qsTr("跟随系统"),
                "supportingText": qsTr("使用此设备的语言"),
                "icon": "language",
                "selected": root.uiLanguagePreference === "system",
                "action": function() { root.uiLanguageController.select("system") }
            },
            {
                "label": qsTr("简体中文"),
                "icon": "translate",
                "selected": root.uiLanguagePreference === "zh_CN",
                "action": function() { root.uiLanguageController.select("zh_CN") }
            },
            {
                "label": qsTr("English"),
                "icon": "translate",
                "selected": root.uiLanguagePreference === "en_US",
                "action": function() { root.uiLanguageController.select("en_US") }
            }
        ]
    }

    ScrollView {
        id: wizardScroll
        visible: !root.advancedMode
        enabled: !root.advancedMode
        anchors.left: parent.left; anchors.right: parent.right
        anchors.top: statusStrip.bottom; anchors.bottom: parent.bottom
        anchors.leftMargin: root.dp(24); anchors.rightMargin: root.dp(24)
        anchors.topMargin: root.dp(8); anchors.bottomMargin: root.dp(20)
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        ColumnLayout {
            width: Math.min(wizardScroll.availableWidth, root.dp(720))
            x: Math.max(0, (wizardScroll.availableWidth - width) / 2)
            spacing: root.dp(16)

            Item { Layout.preferredHeight: root.dp(8) }

            RowLayout {
                Layout.fillWidth: true
                spacing: root.dp(12)
                MeoStepper {
                    Layout.fillWidth: true
                    Layout.maximumWidth: root.dp(520)
                    model: [qsTr("描述"), qsTr("检查"), qsTr("解决"), qsTr("确认")]
                    currentIndex: root.wizardProgressIndex
                }
                Item { Layout.fillWidth: true }
                MeoChip {
                    visible: root.wizardStage === "question"
                    label: qsTr("问题 %1 / %2").arg(root.wizardQuestionIndex + 1)
                                                 .arg(root.guidedQuestions.length)
                    icon: "quiz"
                    visualStyle: "outlined"
                }
            }

            MeoCard {
                Layout.fillWidth: true
                type: "filled"
                padding: root.dp(28)

                ColumnLayout {
                    width: parent.width
                    spacing: root.dp(16)

                    ColumnLayout {
                        Layout.fillWidth: true
                        visible: root.wizardStage === "choose"
                        spacing: root.dp(16)

                        WizardIcon {
                            Layout.alignment: Qt.AlignHCenter
                            icon: "help"
                        }
                        MeoText {
                            Layout.fillWidth: true
                            text: qsTr("你需要解决什么问题？")
                            horizontalAlignment: Text.AlignHCenter
                            typeRole: "title"; typeSize: "medium"; emphasized: true
                            color: MeoTheme.contentOnSurface
                        }
                        MeoText {
                            Layout.fillWidth: true
                            text: qsTr("先选择最接近的一项。接下来每一页只会问一个简单问题。")
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            typeRole: "body"; typeSize: "medium"
                            color: MeoTheme.contentOnSurfaceVariant
                        }
                        Item { Layout.preferredHeight: root.dp(4) }
                        MeoButton {
                            Layout.fillWidth: true
                            text: qsTr("我听不到声音")
                            icon.name: "volume_off"
                            type: "tonal"
                            size: "m"
                            onClicked: root.startWizard("audio", qsTr("我听不到声音"))
                        }
                        MeoButton {
                            Layout.fillWidth: true
                            text: qsTr("第二个显示器没有画面")
                            icon.name: "desktop_access_disabled"
                            type: "tonal"
                            size: "m"
                            onClicked: root.startWizard("display", qsTr("第二个显示器没有画面"))
                        }
                        MeoButton {
                            Layout.fillWidth: true
                            text: qsTr("其他问题")
                            icon.name: "chat"
                            type: "outlined"
                            onClicked: root.wizardStage = "describe"
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        visible: root.wizardStage === "describe"
                        spacing: root.dp(16)

                        WizardIcon {
                            Layout.alignment: Qt.AlignHCenter
                            icon: "chat"
                        }
                        MeoText {
                            Layout.fillWidth: true
                            text: qsTr("发生了什么问题？")
                            horizontalAlignment: Text.AlignHCenter
                            typeRole: "title"; typeSize: "medium"; emphasized: true
                            color: MeoTheme.contentOnSurface
                        }
                        MeoTextField {
                            id: wizardProblemField
                            Layout.fillWidth: true
                            label: qsTr("例如：蓝牙耳机没有声音")
                            type: "outlined"
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            Item { Layout.fillWidth: true }
                            MeoButton {
                                text: qsTr("返回")
                                type: "text"
                                onClicked: root.wizardStage = "choose"
                            }
                            MeoButton {
                                text: qsTr("下一步")
                                icon.name: "arrow_forward"
                                type: "filled"
                                enabled: wizardProblemField.text.trim().length > 0 && !root.workflowBusy
                                onClicked: root.startDescribedWizard()
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        visible: root.wizardStage === "question"
                        spacing: root.dp(16)

                        WizardIcon {
                            Layout.alignment: Qt.AlignHCenter
                            icon: root.categoryIcon(root.selectedCategory)
                        }
                        MeoText {
                            Layout.fillWidth: true
                            text: root.currentWizardQuestion.label || ""
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            typeRole: "title"; typeSize: "medium"; emphasized: true
                            color: MeoTheme.contentOnSurface
                        }
                        MeoSelectionGroup {
                            Layout.fillWidth: true
                            type: "radio"
                            model: root.wizardAnswerOptions()
                            enabled: !root.workflowBusy
                            onSelectionChanged: function(index, checked) {
                                if (!checked || index < 0
                                        || index >= (root.currentWizardQuestion.options || []).length)
                                    return
                                root.selectWizardAnswer(root.currentWizardQuestion.id,
                                                        root.currentWizardQuestion.options[index].id)
                            }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            MeoButton {
                                text: qsTr("返回")
                                type: "text"
                                enabled: !root.workflowBusy
                                onClicked: root.previousWizardQuestion()
                            }
                            Item { Layout.fillWidth: true }
                            MeoButton {
                                text: root.wizardQuestionIndex + 1 < root.guidedQuestions.length
                                      ? qsTr("下一步") : qsTr("开始检查")
                                icon.name: "arrow_forward"
                                type: "filled"
                                enabled: root.wizardSelectedAnswer.length > 0 && !root.workflowBusy
                                onClicked: root.advanceWizardQuestion()
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        visible: root.wizardStage === "checking"
                        spacing: root.dp(18)

                        WizardIcon {
                            Layout.alignment: Qt.AlignHCenter
                            icon: "troubleshoot"
                        }
                        MeoText {
                            Layout.fillWidth: true
                            text: qsTr("正在检查%1").arg(root.categoryLabel(root.selectedCategory))
                            horizontalAlignment: Text.AlignHCenter
                            typeRole: "title"; typeSize: "medium"; emphasized: true
                            color: MeoTheme.contentOnSurface
                        }
                        MeoProgressBar {
                            Layout.fillWidth: true
                            indeterminate: true; vibrant: true; isThick: true
                        }
                        MeoText {
                            Layout.fillWidth: true
                            text: qsTr("这一步只读取状态，不会更改设置，也不需要 AI。")
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            typeRole: "body"; typeSize: "medium"
                            color: MeoTheme.contentOnSurfaceVariant
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        visible: root.wizardStage === "repair"
                        spacing: root.dp(16)

                        WizardIcon {
                            Layout.alignment: Qt.AlignHCenter
                            icon: root.categoryIcon(root.selectedCategory)
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            visible: root.selectedCategory === "audio"
                            spacing: root.dp(14)
                            MeoText {
                                Layout.fillWidth: true
                                text: root.repairController.audioServiceRepairAvailable
                                      ? qsTr("声音服务没有正常运行。现在修复吗？")
                                      : SystemState.audioMuted || SystemState.volumePercent === 0
                                        ? qsTr("声音被静音或音量为零。现在恢复吗？")
                                        : SystemState.audioOutputDevices.length > 1
                                          ? qsTr("你想从哪个设备听到声音？")
                                          : qsTr("检查完成。你现在能听到声音吗？")
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.WordWrap
                                typeRole: "title"; typeSize: "medium"; emphasized: true
                                color: MeoTheme.contentOnSurface
                            }
                            MeoText {
                                Layout.fillWidth: true
                                text: root.repairController.audioServiceRepairAvailable
                                      ? qsTr("修复只会重启当前用户的 PipeWire 服务，完成后会再次检查真实输出设备。")
                                      : qsTr("我们只会执行这一项更改，然后马上复查。")
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.WordWrap
                                typeRole: "body"; typeSize: "small"
                                color: MeoTheme.contentOnSurfaceVariant
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                visible: root.repairController.audioServiceRepairAvailable
                                         || SystemState.audioMuted || SystemState.volumePercent === 0
                                Item { Layout.fillWidth: true }
                                MeoButton {
                                    text: qsTr("否，暂不更改")
                                    type: "outlined"
                                    onClicked: {
                                        root.wizardResultMessage = qsTr("没有执行任何更改。")
                                        root.wizardStage = "handoff"
                                    }
                                }
                                MeoButton {
                                    text: qsTr("是，修复")
                                    type: "filled"
                                    icon.name: "build"
                                    onClicked: root.applyWizardAudioRepair()
                                }
                            }
                            Repeater {
                                model: !root.repairController.audioServiceRepairAvailable
                                       && !SystemState.audioMuted && SystemState.volumePercent > 0
                                       && SystemState.audioOutputDevices.length > 1
                                       ? SystemState.audioOutputDevices : []
                                delegate: MeoButton {
                                    id: wizardAudioOutput
                                    required property var modelData
                                    Layout.fillWidth: true
                                    text: wizardAudioOutput.modelData.name
                                    icon.name: wizardAudioOutput.modelData.active ? "check" : "speaker"
                                    type: wizardAudioOutput.modelData.active ? "tonal" : "outlined"
                                    onClicked: root.useWizardAudioDevice(wizardAudioOutput.modelData.id)
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                visible: !root.repairController.audioServiceRepairAvailable
                                         && !SystemState.audioMuted && SystemState.volumePercent > 0
                                         && SystemState.audioOutputDevices.length <= 1
                                Item { Layout.fillWidth: true }
                                MeoButton {
                                    text: qsTr("否")
                                    type: "outlined"
                                    onClicked: {
                                        root.wizardResultMessage = qsTr("系统检查没有找到可以安全自动更改的项目。")
                                        root.wizardStage = "handoff"
                                    }
                                }
                                MeoButton {
                                    text: qsTr("是")
                                    type: "filled"
                                    onClicked: {
                                        root.wizardResultMessage = qsTr("声音已经恢复，未执行额外更改。")
                                        root.wizardStage = "done"
                                    }
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            visible: root.selectedCategory === "display"
                            spacing: root.dp(14)
                            MeoText {
                                Layout.fillWidth: true
                                text: root.firstDisabledDisplay()
                                      ? qsTr("找到一个已连接但未启用的显示器。要临时启用它吗？")
                                      : qsTr("没有找到可以安全自动启用的显示器。")
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.WordWrap
                                typeRole: "title"; typeSize: "medium"; emphasized: true
                                color: MeoTheme.contentOnSurface
                            }
                            MeoText {
                                Layout.fillWidth: true
                                text: root.firstDisabledDisplay()
                                      ? qsTr("启用后会出现 15 秒确认；如果没有画面或应用退出，系统会自动还原。")
                                      : root.repairController.auditSummary
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.WordWrap
                                typeRole: "body"; typeSize: "small"
                                color: MeoTheme.contentOnSurfaceVariant
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                visible: root.firstDisabledDisplay() !== null
                                Item { Layout.fillWidth: true }
                                MeoButton {
                                    text: qsTr("否，暂不更改")
                                    type: "outlined"
                                    onClicked: {
                                        root.wizardResultMessage = qsTr("没有执行任何显示更改。")
                                        root.wizardStage = "handoff"
                                    }
                                }
                                MeoButton {
                                    text: qsTr("是，临时启用")
                                    icon.name: "visibility"
                                    type: "filled"
                                    enabled: root.repairController.displayGuidedRepairAllowed
                                    onClicked: {
                                        const display = root.firstDisabledDisplay()
                                        if (display) {
                                            root.wizardStage = "repairing"
                                            root.repairController.beginDisplayRecovery(display.id)
                                        }
                                    }
                                }
                            }
                            MeoButton {
                                Layout.alignment: Qt.AlignHCenter
                                visible: root.firstDisabledDisplay() === null
                                text: qsTr("查看详细诊断")
                                type: "outlined"
                                onClicked: root.advancedMode = true
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            visible: root.selectedCategory !== "audio"
                                     && root.selectedCategory !== "display"
                            spacing: root.dp(14)
                            MeoText {
                                Layout.fillWidth: true
                                text: root.repairController.auditFindings.length > 0
                                      ? qsTr("找到可能的问题") : qsTr("没有找到明确故障")
                                horizontalAlignment: Text.AlignHCenter
                                typeRole: "title"; typeSize: "medium"; emphasized: true
                                color: MeoTheme.contentOnSurface
                            }
                            MeoText {
                                Layout.fillWidth: true
                                text: root.repairController.auditFindings.length > 0
                                      ? qsTr("下面只显示诊断发现。AI 只能从固定白名单中提出有证据的修复动作。")
                                      : root.repairController.auditSummary
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.WordWrap
                                typeRole: "body"; typeSize: "medium"
                                color: MeoTheme.contentOnSurfaceVariant
                            }
                            Repeater {
                                model: root.firstItems(root.repairController.auditFindings, 3)
                                delegate: MeoCard {
                                    id: simpleFinding
                                    required property var modelData
                                    Layout.fillWidth: true
                                    type: "outlined"
                                    compact: true
                                    padding: root.dp(12)
                                    MeoText {
                                        width: parent.width
                                        text: root.findingLabel(simpleFinding.modelData)
                                        wrapMode: Text.WordWrap
                                        typeRole: "body"; typeSize: "small"
                                        color: MeoTheme.contentOnSurface
                                    }
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                Item { Layout.fillWidth: true }
                                MeoButton {
                                    text: qsTr("暂不使用 AI")
                                    type: "outlined"
                                    onClicked: {
                                        root.wizardResultMessage = qsTr("没有发送数据，也没有执行任何更改。")
                                        root.wizardStage = "handoff"
                                    }
                                }
                                MeoButton {
                                    visible: root.repairController.auditFindings.length > 0
                                    text: qsTr("让 AI 准备修复")
                                    icon.name: "auto_fix_high"
                                    type: "filled"
                                    onClicked: root.requestWizardAiPlan()
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        visible: root.wizardStage === "ai_planning"
                        spacing: root.dp(18)
                        MeoAiMark {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: root.dp(56)
                            Layout.preferredHeight: root.dp(56)
                        }
                        MeoText {
                            Layout.fillWidth: true
                            text: qsTr("AI 正在定位并复核修复方案")
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            typeRole: "title"; typeSize: "medium"; emphasized: true
                            color: MeoTheme.contentOnSurface
                        }
                        MeoProgressBar {
                            Layout.fillWidth: true
                            indeterminate: true; vibrant: true; isThick: true
                        }
                        MeoText {
                            Layout.fillWidth: true
                            text: root.repairController.aiMessage.length > 0
                                  ? root.repairController.aiMessage
                                  : qsTr("发送前会显示数据用途；模型不能生成命令，只能选择本机允许的固定动作。")
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            typeRole: "body"; typeSize: "small"
                            color: MeoTheme.contentOnSurfaceVariant
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        visible: root.wizardStage === "repair_approval"
                        spacing: root.dp(16)
                        WizardIcon {
                            Layout.alignment: Qt.AlignHCenter
                            icon: "verified_user"
                        }
                        MeoText {
                            Layout.fillWidth: true
                            text: qsTr("AI 已找到可执行的修复")
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            typeRole: "title"; typeSize: "medium"; emphasized: true
                            color: MeoTheme.contentOnSurface
                        }
                        MeoText {
                            Layout.fillWidth: true
                            text: root.wizardPlanSummary()
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            typeRole: "body"; typeSize: "medium"
                            color: MeoTheme.contentOnSurfaceVariant
                        }
                        Repeater {
                            model: root.wizardPlanActions()
                            delegate: MeoCard {
                                id: simpleAction
                                required property var modelData
                                Layout.fillWidth: true
                                type: "outlined"
                                compact: true
                                padding: root.dp(12)
                                ColumnLayout {
                                    width: parent.width
                                    spacing: root.dp(4)
                                    MeoText {
                                        Layout.fillWidth: true
                                        text: simpleAction.modelData.reason
                                        wrapMode: Text.WordWrap
                                        typeRole: "body"; typeSize: "medium"; emphasized: true
                                        color: MeoTheme.contentOnSurface
                                    }
                                    MeoText {
                                        Layout.fillWidth: true
                                        text: qsTr("将执行：%1").arg(
                                                  root.actionLabel(simpleAction.modelData.kind))
                                        wrapMode: Text.WrapAnywhere
                                        typeRole: "label"; typeSize: "small"
                                        color: MeoTheme.contentOnSurfaceVariant
                                    }
                                }
                            }
                        }
                        MeoText {
                            Layout.fillWidth: true
                            text: root.repairController.liveEnvironment
                                  ? qsTr("点击同意后只执行上面的固定动作，并立即复查。")
                                  : qsTr("点击同意后只执行上面的固定动作；需要管理员权限时，系统会单独显示密码窗口。")
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            typeRole: "body"; typeSize: "small"
                            color: MeoTheme.contentOnSurfaceVariant
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            Item { Layout.fillWidth: true }
                            MeoButton {
                                text: qsTr("不同意")
                                type: "outlined"
                                onClicked: {
                                    root.repairController.clearPlan()
                                    root.wizardResultMessage = qsTr("修复已取消，没有执行任何更改。")
                                    root.wizardStage = "handoff"
                                }
                            }
                            MeoButton {
                                text: qsTr("同意并修复")
                                icon.name: "check_circle"
                                type: "filled"
                                vibrant: true
                                enabled: (root.visualPreview || root.repairController.readyToExecute)
                                         && root.wizardPlanHasWriteAction()
                                         && !root.workflowBusy
                                onClicked: {
                                    if (!root.visualPreview)
                                        root.approveWizardAiRepair()
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        visible: root.wizardStage === "repairing"
                        spacing: root.dp(18)
                        WizardIcon {
                            Layout.alignment: Qt.AlignHCenter
                            icon: "build"
                        }
                        MeoText {
                            Layout.fillWidth: true
                            text: qsTr("正在修复并复查")
                            horizontalAlignment: Text.AlignHCenter
                            typeRole: "title"; typeSize: "medium"; emphasized: true
                            color: MeoTheme.contentOnSurface
                        }
                        MeoProgressBar {
                            Layout.fillWidth: true
                            indeterminate: true; vibrant: true; isThick: true
                        }
                        MeoText {
                            Layout.fillWidth: true
                            text: root.selectedCategory === "audio"
                                  ? (root.repairController.audioRecoveryMessage.length > 0
                                     ? root.repairController.audioRecoveryMessage : root.audioRepairMessage)
                                  : root.selectedCategory === "display"
                                    ? root.repairController.displayRecoveryMessage
                                    : (root.repairController.executionLog.length > 0
                                       ? root.repairController.executionLog
                                       : root.repairController.aiMessage)
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            typeRole: "body"; typeSize: "small"
                            color: MeoTheme.contentOnSurfaceVariant
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        visible: root.wizardStage === "display_confirm"
                        spacing: root.dp(16)
                        WizardIcon {
                            Layout.alignment: Qt.AlignHCenter
                            icon: "timer"
                        }
                        MeoText {
                            Layout.fillWidth: true
                            text: qsTr("你能在第二个显示器上看到画面吗？")
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            typeRole: "title"; typeSize: "medium"; emphasized: true
                            color: MeoTheme.contentOnSurface
                        }
                        MeoText {
                            Layout.fillWidth: true
                            text: qsTr("请在 %1 秒内回答；没有回答会自动还原。").arg(
                                      root.repairController.displayRecoverySeconds)
                            horizontalAlignment: Text.AlignHCenter
                            typeRole: "body"; typeSize: "medium"
                            color: MeoTheme.contentOnSurfaceVariant
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            Item { Layout.fillWidth: true }
                            MeoButton {
                                text: qsTr("否，还原")
                                type: "outlined"
                                onClicked: root.repairController.revertDisplayRecovery()
                            }
                            MeoButton {
                                text: qsTr("是，保留")
                                type: "filled"
                                onClicked: root.repairController.keepDisplayRecovery()
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        visible: root.wizardStage === "verify"
                        spacing: root.dp(16)
                        WizardIcon {
                            Layout.alignment: Qt.AlignHCenter
                            icon: root.selectedCategory === "audio" ? "hearing" : "task_alt"
                        }
                        MeoText {
                            Layout.fillWidth: true
                            text: root.selectedCategory === "audio"
                                  ? qsTr("现在能听到声音吗？") : qsTr("问题现在解决了吗？")
                            horizontalAlignment: Text.AlignHCenter
                            typeRole: "title"; typeSize: "medium"; emphasized: true
                            color: MeoTheme.contentOnSurface
                        }
                        MeoButton {
                            Layout.alignment: Qt.AlignHCenter
                            visible: root.selectedCategory === "audio"
                            text: root.repairController.audioTestState === "playing"
                                  ? qsTr("正在播放测试声音……")
                                  : root.repairController.audioTestState === "idle"
                                    ? qsTr("播放测试声音") : qsTr("再次播放测试声音")
                            icon.name: "play_arrow"
                            type: "tonal"
                            enabled: root.repairController.audioTestState !== "playing"
                                     && !root.workflowBusy
                            onClicked: root.repairController.playAudioTestTone()
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            Item { Layout.fillWidth: true }
                            MeoButton {
                                text: qsTr("否")
                                type: "outlined"
                                onClicked: {
                                    if (root.selectedCategory === "audio"
                                            && SystemState.audioOutputDevices.length > 1) {
                                        root.wizardResultMessage = qsTr("这个输出仍然没有声音。请选择另一个扬声器、耳机或 HDMI 输出继续测试。")
                                        root.wizardStage = "repair"
                                    } else {
                                        root.wizardResultMessage = root.selectedCategory === "audio"
                                                ? qsTr("声音服务和输出状态正常，但实际听感仍未恢复。请查看详细诊断，或检查线缆、蓝牙连接和设备本身。")
                                                : qsTr("固定动作和状态复查已经完成，但你确认问题仍然存在。请查看详细诊断或交给人工继续处理。")
                                        root.wizardStage = "handoff"
                                    }
                                }
                            }
                            MeoButton {
                                text: qsTr("是")
                                type: "filled"
                                onClicked: {
                                    root.wizardResultMessage = root.selectedCategory === "audio"
                                            ? qsTr("声音已恢复，并且修复后的状态复查通过。")
                                            : qsTr("问题已解决，固定动作的状态复查也已通过。")
                                    root.wizardStage = "done"
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        visible: root.wizardStage === "done" || root.wizardStage === "handoff"
                        spacing: root.dp(16)
                        WizardIcon {
                            Layout.alignment: Qt.AlignHCenter
                            icon: root.wizardStage === "done" ? "check_circle" : "support_agent"
                            iconColor: root.wizardStage === "done"
                                       ? MeoTheme.contentOnPrimaryContainer
                                       : MeoTheme.contentOnSurfaceVariant
                        }
                        MeoText {
                            Layout.fillWidth: true
                            text: root.wizardStage === "done" ? qsTr("问题已解决") : qsTr("需要下一步帮助")
                            horizontalAlignment: Text.AlignHCenter
                            typeRole: "title"; typeSize: "medium"; emphasized: true
                            color: MeoTheme.contentOnSurface
                        }
                        MeoText {
                            Layout.fillWidth: true
                            text: root.wizardResultMessage.length > 0
                                  ? root.wizardResultMessage
                                  : root.repairController.guidedHandoffMessage
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            typeRole: "body"; typeSize: "medium"
                            color: MeoTheme.contentOnSurfaceVariant
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            Item { Layout.fillWidth: true }
                            MeoButton {
                                text: qsTr("重新开始")
                                type: "outlined"
                                enabled: !root.workflowBusy
                                onClicked: root.resetWizard()
                            }
                            MeoButton {
                                visible: root.wizardStage === "handoff"
                                text: qsTr("查看详细诊断")
                                icon.name: "tune"
                                type: "filled"
                                onClicked: root.advancedMode = true
                            }
                            MeoButton {
                                visible: root.wizardStage === "done"
                                text: qsTr("关闭")
                                type: "filled"
                                onClicked: Qt.quit()
                            }
                        }
                    }
                }
            }

            MeoText {
                Layout.fillWidth: true
                text: root.repairController.liveEnvironment
                      ? qsTr("修复只使用固定动作；Live 模式不会向 AI 或本应用索取管理员密码。")
                      : qsTr("需要管理员权限时，密码只输入到系统 Polkit 窗口，不会交给 AI。")
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                typeRole: "body"; typeSize: "small"
                color: MeoTheme.contentOnSurfaceVariant
            }
            Item { Layout.preferredHeight: root.dp(18) }
        }
    }

    RowLayout {
        visible: root.advancedMode
        enabled: root.advancedMode
        anchors.left: parent.left; anchors.right: parent.right
        anchors.top: statusStrip.bottom; anchors.bottom: parent.bottom
        anchors.leftMargin: root.dp(20); anchors.rightMargin: root.dp(20)
        anchors.topMargin: root.dp(12); anchors.bottomMargin: root.dp(20)
        spacing: root.dp(18)

        MeoSettingsSidebar {
            id: helpSidebar
            visible: !root.compactLayout
            Layout.preferredWidth: root.compactLayout ? 0 : root.dp(286)
            Layout.maximumWidth: root.compactLayout ? 0 : root.dp(286)
            Layout.minimumWidth: 0
            Layout.fillHeight: !root.compactLayout
            title: qsTr("查找帮助")
            searchPlaceholder: qsTr("搜索声音、显示器、网络……")
            groups: root.helpCategoryGroups
            searchResults: root.categorySearchResults(searchText)
            selectedRoute: "category:" + root.selectedCategory
            onRouteActivated: function(route, row) {
                if (route.indexOf("category:") !== 0)
                    return
                root.investigateCategory(route.substring(9), true)
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

                RowLayout {
                    Layout.fillWidth: true
                    spacing: root.dp(14)
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        MeoText {
                            text: root.categoryMetadata(root.selectedCategory).title
                            typeRole: "title"; typeSize: "big"; emphasized: true
                            color: MeoTheme.contentOnSurface
                        }
                        MeoText {
                            Layout.fillWidth: true
                            text: root.categoryMetadata(root.selectedCategory).description
                            wrapMode: Text.WordWrap
                            typeRole: "body"; typeSize: "medium"
                            color: MeoTheme.contentOnSurfaceVariant
                        }
                    }
                    MeoLoadingIndicator {
                        visible: root.workflowBusy
                        size: "m"
                        withContainer: true
                    }
                }

                MeoBanner {
                    Layout.fillWidth: true
                    title: root.diagnosticSubjectLabel(root.selectedCategory)
                    text: root.diagnosticSubjectDescription(root.selectedCategory)
                    icon: root.categoryMetadata(root.selectedCategory).scope === "target"
                          ? "hard_drive"
                          : root.categoryMetadata(root.selectedCategory).scope === "live"
                            ? "usb"
                            : root.categoryMetadata(root.selectedCategory).scope === "mixed"
                              ? "splitscreen"
                              : "desktop_windows"
                    tone: root.categoryMetadata(root.selectedCategory).scope === "target"
                          && !root.repairController.mountedTargetAvailable
                          ? "warning" : "tonal"
                }

                MeoGroupedList {
                    Layout.fillWidth: true
                    visible: root.compactLayout
                    title: qsTr("问题分类")
                    model: root.categoryRows(["audio", "display", "network", "boot",
                                              "packages", "storage", "graphics", "security"])
                    selectedIndex: {
                        const ids = ["audio", "display", "network", "boot",
                                     "packages", "storage", "graphics", "security"]
                        return ids.indexOf(root.selectedCategory)
                    }
                    onClicked: function(index) {
                        const ids = ["audio", "display", "network", "boot",
                                     "packages", "storage", "graphics", "security"]
                        if (index >= 0 && index < ids.length)
                            root.investigateCategory(ids[index], true)
                    }
                }

                MeoCard {
                    Layout.fillWidth: true
                    type: "filled"
                    padding: root.dp(20)
                    RowLayout {
                        width: parent.width
                        spacing: root.dp(16)
                        WizardIcon { icon: root.categoryIcon(root.selectedCategory) }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            MeoText {
                                text: root.repairController.auditState === "running"
                                      ? qsTr("正在检查系统状态")
                                      : qsTr("自动检查%1问题").arg(root.categoryLabel(root.selectedCategory))
                                typeRole: "title"; typeSize: "medium"; emphasized: true
                                color: MeoTheme.contentOnSurface
                            }
                            MeoText {
                                Layout.fillWidth: true
                                text: root.repairController.auditState === "running"
                                      ? qsTr("正在读取服务、设备和配置状态；完成后 AI 会根据结构化证据准备下一步。")
                                      : root.auditComplete
                                        ? root.repairController.auditSummary
                                        : qsTr("无需先输入文字。选择分类后即可读取状态并定位常见问题。")
                                wrapMode: Text.WordWrap
                                typeRole: "body"; typeSize: "small"
                                color: MeoTheme.contentOnSurfaceVariant
                            }
                        }
                        MeoButton {
                            text: root.auditComplete ? qsTr("重新检查") : qsTr("开始检查")
                            icon.name: "troubleshoot"
                            type: "filled"
                            loading: root.repairController.auditState === "running"
                            enabled: !root.workflowBusy
                            onClicked: root.investigateCategory(root.selectedCategory, true)
                        }
                    }
                }

                MeoBanner {
                    Layout.fillWidth: true
                    visible: root.repairController.accountConfigured
                             && !root.repairController.signedIn
                    title: qsTr("登录 MeoArch Account，使用已配置的 AI 帮助")
                    text: qsTr("未登录也可以完成所有本地检查。登录后，可使用账号中的模型连接准备和复核修复方案。")
                    icon: "account_circle"
                }

                MeoCard {
                    Layout.fillWidth: true
                    visible: root.selectedCategory === "network"
                    type: "elevated"
                    padding: root.dp(20)

                    ColumnLayout {
                        width: parent.width
                        spacing: root.dp(12)

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: root.dp(12)
                            MeoIcon {
                                icon: SystemState.networkConnected ? "wifi" : "wifi_off"
                                size: 30
                                color: SystemState.networkConnected ? MeoTheme.primary
                                                                     : MeoTheme.contentOnSurfaceVariant
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0
                                MeoText {
                                    text: qsTr("网络连接")
                                    typeRole: "title"; typeSize: "small"; emphasized: true
                                    color: MeoTheme.contentOnSurface
                                }
                                MeoText {
                                    Layout.fillWidth: true
                                    text: SystemState.networkConnected
                                          ? (SystemState.networkName.length > 0
                                             ? qsTr("已连接：") + SystemState.networkName + " · " + SystemState.networkStatus
                                             : qsTr("已有活动网络连接 · ") + SystemState.networkStatus)
                                          : qsTr("可以直接在这里连接 Wi‑Fi；以太网会自动显示为活动连接。")
                                    wrapMode: Text.WordWrap
                                    typeRole: "body"; typeSize: "small"
                                    color: MeoTheme.contentOnSurfaceVariant
                                }
                            }
                            MeoSwitch {
                                checked: SystemState.wirelessAvailable && SystemState.wirelessEnabled
                                enabled: SystemState.wirelessAvailable && !SystemState.networkBusy
                                Accessible.name: qsTr("Wi‑Fi")
                                onToggled: checkedState => { SystemState.wirelessEnabled = checkedState }
                            }
                            MeoIconButton {
                                icon.name: "refresh"
                                type: "tonal"
                                Accessible.name: qsTr("扫描 Wi‑Fi 网络")
                                enabled: SystemState.wirelessAvailable
                                         && SystemState.wirelessEnabled
                                         && !SystemState.wifiScanning
                                         && !SystemState.networkBusy
                                onClicked: SystemState.requestWifiScan()
                            }
                        }

                        MeoBanner {
                            Layout.fillWidth: true
                            visible: !SystemState.wirelessAvailable
                            title: qsTr("没有检测到 Wi‑Fi")
                            text: SystemState.networkConnected
                                  ? qsTr("当前可能通过以太网连接；无需 Wi‑Fi。")
                                  : qsTr("连接以太网，或接入系统支持的 Wi‑Fi 适配器。")
                            icon: "lan"
                        }

                        MeoBanner {
                            Layout.fillWidth: true
                            visible: SystemState.operationError.length > 0
                            title: qsTr("网络操作失败")
                            text: SystemState.operationError
                            icon: "error"
                            tone: "error"
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            visible: SystemState.wifiScanning || SystemState.networkBusy
                            MeoLoadingIndicator { indeterminate: true; size: "s" }
                            MeoText {
                                Layout.fillWidth: true
                                text: SystemState.wifiScanning ? qsTr("正在扫描 Wi‑Fi……") : qsTr("正在连接……")
                                typeRole: "body"; typeSize: "small"
                                color: MeoTheme.contentOnSurfaceVariant
                            }
                        }

                        Repeater {
                            model: SystemState.wirelessAvailable && SystemState.wirelessEnabled
                                   ? SystemState.wifiNetworks : []
                            delegate: MeoCard {
                                id: repairWifiCard
                                required property var modelData
                                Layout.fillWidth: true
                                type: modelData.connected ? "filled" : "outlined"
                                compact: true
                                padding: root.dp(12)

                                RowLayout {
                                    width: parent.width
                                    spacing: root.dp(10)
                                    MeoIcon {
                                        icon: root.networkSignalIcon(repairWifiCard.modelData.strength)
                                        size: 22
                                        color: repairWifiCard.modelData.connected
                                               ? MeoTheme.primary : MeoTheme.contentOnSurfaceVariant
                                    }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 0
                                        MeoText {
                                            text: repairWifiCard.modelData.ssid
                                            typeRole: "body"; typeSize: "medium"; emphasized: true
                                            color: MeoTheme.contentOnSurface
                                        }
                                        MeoText {
                                            text: repairWifiCard.modelData.connected ? qsTr("已连接")
                                                  : repairWifiCard.modelData.connecting ? qsTr("连接中……")
                                                  : repairWifiCard.modelData.saved ? qsTr("已保存 · ") + repairWifiCard.modelData.securityLabel
                                                  : repairWifiCard.modelData.securityLabel
                                            typeRole: "body"; typeSize: "small"
                                            color: MeoTheme.contentOnSurfaceVariant
                                        }
                                    }
                                    MeoButton {
                                        text: repairWifiCard.modelData.connected ? qsTr("断开")
                                              : repairWifiCard.modelData.saved || !repairWifiCard.modelData.secured
                                                ? qsTr("连接") : qsTr("输入密码")
                                        type: repairWifiCard.modelData.connected ? "outlined" : "tonal"
                                        enabled: !root.visualPreview && !SystemState.networkBusy
                                        onClicked: {
                                            SystemState.clearOperationError()
                                            if (repairWifiCard.modelData.connected) {
                                                SystemState.disconnectWifi()
                                            } else if (repairWifiCard.modelData.saved || !repairWifiCard.modelData.secured) {
                                                SystemState.connectWifi(repairWifiCard.modelData.ssid, "")
                                            } else {
                                                wifiPasswordDialog.ssid = repairWifiCard.modelData.ssid
                                                wifiPasswordDialog.open()
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        MeoButton {
                            visible: SystemState.wirelessAvailable
                                     && SystemState.wirelessEnabled
                                     && SystemState.wifiNetworks.length === 0
                            text: SystemState.wifiScanning ? qsTr("正在扫描……") : qsTr("扫描网络")
                            type: "tonal"
                            loading: SystemState.wifiScanning
                            enabled: !SystemState.wifiScanning && !SystemState.networkBusy
                            onClicked: SystemState.requestWifiScan()
                        }
                    }
                }

                MeoCard {
                    Layout.fillWidth: true
                    visible: root.selectedCategory === "audio"
                             && (root.auditComplete || root.visualPreview)
                             && (root.visualPreview || root.repairController.selectedCategory === "audio")
                    type: "elevated"
                    padding: root.dp(20)

                    ColumnLayout {
                        width: parent.width
                        spacing: root.dp(12)
                        RowLayout {
                            Layout.fillWidth: true
                            MeoIcon { icon: "volume_up"; size: 30; color: MeoTheme.primary }
                            ColumnLayout {
                                Layout.fillWidth: true; spacing: 0
                                MeoText {
                                    text: qsTr("声音快速修复")
                                    typeRole: "title"; typeSize: "small"; emphasized: true
                                    color: MeoTheme.contentOnSurface
                                }
                                MeoText {
                                    Layout.fillWidth: true
                                    text: SystemState.audioAvailable
                                          ? qsTr("当前输出：") + SystemState.audioDevice + " · "
                                            + SystemState.volumePercent + "%"
                                          : qsTr("当前用户会话没有可用的音频服务；请先查看上面的诊断发现。")
                                    wrapMode: Text.WordWrap
                                    typeRole: "body"; typeSize: "small"
                                    color: MeoTheme.contentOnSurfaceVariant
                                }
                            }
                            MeoButton {
                                visible: SystemState.audioAvailable
                                text: SystemState.audioMuted || SystemState.volumePercent === 0
                                      ? qsTr("解除静音并恢复音量") : qsTr("音量状态正常")
                                icon.name: SystemState.audioMuted ? "volume_off" : "volume_up"
                                type: SystemState.audioMuted || SystemState.volumePercent === 0 ? "filled" : "outlined"
                                enabled: !root.visualPreview
                                         && root.repairController.audioGuidedRepairAllowed
                                         && (SystemState.audioMuted || SystemState.volumePercent === 0)
                                         && !root.workflowBusy
                                onClicked: {
                                    root.repairController.clearPlan()
                                    SystemState.clearOperationError()
                                    root.pendingAudioAction = "unmute"
                                    root.audioPostCheckAttempts = 0
                                    root.audioRepairMessage = qsTr("正在应用当前用户的音量设置并复查……")
                                    SystemState.audioMuted = false
                                    if (SystemState.volumePercent === 0)
                                        SystemState.volumePercent = 50
                                    audioPostCheck.restart()
                                }
                            }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            visible: root.repairController.audioServiceRepairAvailable
                                     || root.repairController.audioRecoveryMessage.length > 0
                            spacing: root.dp(10)
                            MeoText {
                                Layout.fillWidth: true
                                text: root.repairController.audioRecoveryMessage.length > 0
                                      ? root.repairController.audioRecoveryMessage
                                      : qsTr("诊断发现当前用户的 PipeWire 服务异常。重启会短暂中断正在播放和录音的应用。")
                                wrapMode: Text.WordWrap
                                typeRole: "body"; typeSize: "small"
                                color: root.repairController.audioRecoveryState === "error"
                                       ? MeoTheme.error : MeoTheme.contentOnSurfaceVariant
                            }
                            MeoButton {
                                visible: root.repairController.audioServiceRepairAvailable
                                         && root.repairController.audioRecoveryState !== "complete"
                                text: root.repairController.audioRecoveryState === "running"
                                      ? qsTr("正在重启……") : qsTr("重启声音服务")
                                type: "filled"
                                icon.name: "restart_alt"
                                enabled: root.repairController.audioGuidedRepairAllowed
                                         && root.repairController.audioRecoveryState !== "running"
                                         && !root.workflowBusy
                                onClicked: root.repairController.restartAudioServices()
                            }
                        }
                        MeoText {
                            Layout.fillWidth: true
                            visible: root.audioRepairMessage.length > 0
                            text: root.audioRepairMessage
                            wrapMode: Text.WordWrap
                            typeRole: "body"; typeSize: "small"; emphasized: true
                            color: MeoTheme.primary
                        }
                        MeoText {
                            Layout.fillWidth: true
                            visible: SystemState.audioAvailable
                            text: qsTr("选择你真正想听到声音的设备")
                            typeRole: "label"; typeSize: "medium"; emphasized: true
                            color: MeoTheme.contentOnSurface
                        }
                        Repeater {
                            model: SystemState.audioAvailable ? SystemState.audioOutputDevices : []
                            delegate: MeoCard {
                                id: audioDeviceCard
                                required property var modelData
                                Layout.fillWidth: true
                                type: "outlined"
                                compact: true
                                padding: root.dp(12)
                                RowLayout {
                                    width: parent.width
                                    spacing: root.dp(10)
                                    MeoIcon {
                                        icon: audioDeviceCard.modelData.formFactor === "bluetooth"
                                              ? "bluetooth_audio" : "speaker"
                                        size: 22
                                        color: audioDeviceCard.modelData.active
                                               ? MeoTheme.primary : MeoTheme.contentOnSurfaceVariant
                                    }
                                    MeoText {
                                        Layout.fillWidth: true
                                        text: audioDeviceCard.modelData.name
                                        typeRole: "body"; typeSize: "medium"
                                        color: MeoTheme.contentOnSurface
                                    }
                                    MeoButton {
                                        text: audioDeviceCard.modelData.active ? qsTr("当前输出") : qsTr("切换并复查")
                                        type: audioDeviceCard.modelData.active ? "tonal" : "outlined"
                                        enabled: !root.visualPreview && !audioDeviceCard.modelData.active
                                                 && root.repairController.audioGuidedRepairAllowed
                                                 && !SystemState.operationBusy
                                                 && !root.workflowBusy
                                        onClicked: {
                                            root.repairController.clearPlan()
                                            SystemState.clearOperationError()
                                            root.pendingAudioAction = "output"
                                            root.pendingAudioDeviceId = audioDeviceCard.modelData.id
                                            root.audioPostCheckAttempts = 0
                                            root.audioRepairMessage = qsTr("正在切换默认输出并复查……")
                                            SystemState.setDefaultAudioOutput(audioDeviceCard.modelData.id)
                                            audioPostCheck.restart()
                                        }
                                    }
                                }
                            }
                        }
                        MeoText {
                            Layout.fillWidth: true
                            visible: SystemState.operationError.length > 0
                            text: SystemState.operationError
                            wrapMode: Text.WordWrap
                            typeRole: "body"; typeSize: "small"
                            color: MeoTheme.error
                        }
                    }
                }

                MeoCard {
                    Layout.fillWidth: true
                    visible: root.selectedCategory === "display"
                             && (root.auditComplete || root.visualPreview)
                             && (root.visualPreview || root.repairController.selectedCategory === "display")
                    type: "elevated"
                    padding: root.dp(20)

                    ColumnLayout {
                        width: parent.width
                        spacing: root.dp(12)
                        RowLayout {
                            Layout.fillWidth: true
                            MeoIcon { icon: "desktop_windows"; size: 30; color: MeoTheme.primary }
                            ColumnLayout {
                                Layout.fillWidth: true; spacing: 0
                                MeoText {
                                    text: qsTr("第二个显示器快速修复")
                                    typeRole: "title"; typeSize: "small"; emphasized: true
                                    color: MeoTheme.contentOnSurface
                                }
                                MeoText {
                                    Layout.fillWidth: true
                                    text: qsTr("只允许启用“已连接但被禁用”的屏幕。更改前先建立独立安全计时器；15 秒内未确认或应用退出都会还原。")
                                    wrapMode: Text.WordWrap
                                    typeRole: "body"; typeSize: "small"
                                    color: MeoTheme.contentOnSurfaceVariant
                                }
                            }
                            MeoButton {
                                text: qsTr("重新读取")
                                type: "outlined"
                                icon.name: "refresh"
                                enabled: !root.visualPreview
                                         && !root.workflowBusy
                                onClicked: root.repairController.refreshDisplayOutputs()
                            }
                        }
                        Repeater {
                            model: root.visualPreview ? [
                                { "id": "1", "name": "eDP-1", "enabled": true,
                                  "connected": true, "mode": "3200x2000@60", "primary": true },
                                { "id": "2", "name": "HDMI-A-1", "enabled": false,
                                  "connected": true, "mode": "", "primary": false }
                            ] : root.repairController.displayOutputs
                            delegate: MeoCard {
                                id: displayCard
                                required property var modelData
                                Layout.fillWidth: true
                                type: "outlined"
                                compact: true
                                padding: root.dp(12)
                                RowLayout {
                                    width: parent.width
                                    spacing: root.dp(10)
                                    MeoIcon {
                                        icon: displayCard.modelData.enabled ? "monitor" : "desktop_access_disabled"
                                        size: 22
                                        color: displayCard.modelData.enabled
                                               ? MeoTheme.primary : MeoTheme.contentOnSurfaceVariant
                                    }
                                    ColumnLayout {
                                        Layout.fillWidth: true; spacing: 0
                                        MeoText {
                                            text: displayCard.modelData.name
                                                  + (displayCard.modelData.primary ? qsTr(" · 主显示器") : "")
                                            typeRole: "body"; typeSize: "medium"; emphasized: true
                                            color: MeoTheme.contentOnSurface
                                        }
                                        MeoText {
                                            text: displayCard.modelData.enabled
                                                  ? qsTr("已启用") + (displayCard.modelData.mode ? " · " + displayCard.modelData.mode : "")
                                                  : qsTr("已连接，但当前布局中被禁用")
                                            typeRole: "body"; typeSize: "small"
                                            color: MeoTheme.contentOnSurfaceVariant
                                        }
                                    }
                                    MeoButton {
                                        visible: !displayCard.modelData.enabled
                                        text: qsTr("临时启用")
                                        type: "filled"
                                        icon.name: "visibility"
                                        enabled: !root.visualPreview
                                                 && root.repairController.displayGuidedRepairAllowed
                                                 && !root.workflowBusy
                                        onClicked: root.repairController.beginDisplayRecovery(displayCard.modelData.id)
                                    }
                                }
                            }
                        }
                        MeoBanner {
                            Layout.fillWidth: true
                            title: root.repairController.displayRecoveryState === "awaiting_confirmation"
                                   ? qsTr("你能看到新屏幕吗？剩余 %1 秒").arg(root.repairController.displayRecoverySeconds)
                                   : qsTr("显示器状态")
                            text: root.visualPreview
                                  ? qsTr("已找到一个连接但未启用的显示器；可以安全临时启用并等待确认。")
                                  : root.repairController.displayRecoveryMessage
                            icon: root.repairController.displayRecoveryState === "awaiting_confirmation"
                                  ? "timer" : "info"
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            visible: root.repairController.displayRecoveryState === "awaiting_confirmation"
                            Item { Layout.fillWidth: true }
                            MeoButton {
                                text: qsTr("立即还原")
                                type: "outlined"
                                onClicked: root.repairController.revertDisplayRecovery()
                            }
                            MeoButton {
                                text: qsTr("保留此显示器")
                                type: "filled"
                                onClicked: root.repairController.keepDisplayRecovery()
                            }
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
                            spacing: root.dp(12)
                            MeoIcon { icon: "chat"; size: 30; color: MeoTheme.primary }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0
                                MeoText {
                                    text: qsTr("哪里出了问题？")
                                    typeRole: "title"; typeSize: "small"; emphasized: true
                                    color: MeoTheme.contentOnSurface
                                }
                                MeoText {
                                    Layout.fillWidth: true
                                    text: qsTr("直接用自己的话描述。分类在本机完成；先运行只读检查，不会因为一句话就执行命令。")
                                    wrapMode: Text.WordWrap
                                    typeRole: "body"; typeSize: "small"
                                    color: MeoTheme.contentOnSurfaceVariant
                                }
                            }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: root.dp(10)
                            MeoTextField {
                                id: problemField
                                Layout.fillWidth: true
                                label: qsTr("例如：为什么没有声音？第二个显示器为什么不亮？")
                                type: "outlined"
                            }
                            MeoButton {
                                text: qsTr("定位问题")
                                icon.name: "search"
                                type: "filled"
                                enabled: problemField.text.trim().length > 0
                                         && !root.workflowBusy
                                         && !root.visualPreview
                                onClicked: {
                                    root.investigateProblem(problemField.text)
                                    problemField.text = ""
                                }
                            }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: root.dp(8)
                            MeoButton {
                                text: qsTr("没有声音")
                                type: "outlined"
                                onClicked: problemField.text = qsTr("为什么没有声音？")
                            }
                            MeoButton {
                                text: qsTr("第二个显示器不亮")
                                type: "outlined"
                                onClicked: problemField.text = qsTr("第二个显示器连接了但不显示")
                            }
                            Item { Layout.fillWidth: true }
                            MeoText {
                                text: root.selectedCategory === "all"
                                      ? qsTr("尚未分类")
                                      : qsTr("将检查：") + root.categoryLabel(root.selectedCategory)
                                typeRole: "label"; typeSize: "small"
                                color: MeoTheme.contentOnSurfaceVariant
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
                                text: qsTr("密码只交给操作系统；AI 不能控制 Shell")
                                typeRole: "title"; typeSize: "small"; emphasized: true
                                color: MeoTheme.contentOnSurface
                            }
                            MeoText {
                                Layout.fillWidth: true
                                text: root.repairController.liveEnvironment
                                      ? qsTr("普通音频和显示修复使用 live 用户权限。物理启动的 Live 修复会话只通过系统 Polkit 免密授权四个固定维护脚本；没有任意 Shell、命令或参数入口。")
                                      : qsTr("普通音频和显示修复使用当前用户权限。需要管理员权限时，只能由系统 Polkit 窗口收取密码，本应用和 AI 都看不到密码。AI 只能选择程序内固定动作 ID。")
                                wrapMode: Text.WordWrap
                                typeRole: "body"; typeSize: "small"
                                color: MeoTheme.contentOnSurfaceVariant
                            }
                        }
                    }
                }

                MeoCard {
                    Layout.fillWidth: true
                    // Questions are not a standing form. This remains hidden
                    // until the Agent protocol gains an explicit needs_input
                    // state tied to a validated question schema.
                    visible: false
                    type: "outlined"
                    padding: root.dp(20)

                    ColumnLayout {
                        width: parent.width
                        spacing: root.dp(14)
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: root.dp(10)
                            MeoIcon { icon: "quiz"; size: 28; color: MeoTheme.primary }
                            ColumnLayout {
                                Layout.fillWidth: true; spacing: 0
                                MeoText {
                                    text: qsTr("用几个简单选择缩小范围")
                                    typeRole: "title"; typeSize: "small"; emphasized: true
                                    color: MeoTheme.contentOnSurface
                                }
                                MeoText {
                                    Layout.fillWidth: true
                                    text: qsTr("答案只保存在本次应用状态中，会进入结构化诊断上下文；它不会直接授权任何修复。")
                                    wrapMode: Text.WordWrap
                                    typeRole: "body"; typeSize: "small"
                                    color: MeoTheme.contentOnSurfaceVariant
                                }
                            }
                        }
                        Repeater {
                            model: root.guidedQuestions
                            delegate: ColumnLayout {
                                id: guidedQuestion
                                required property var modelData
                                Layout.fillWidth: true
                                spacing: root.dp(7)
                                MeoText {
                                    Layout.fillWidth: true
                                    text: guidedQuestion.modelData.label
                                    wrapMode: Text.WordWrap
                                    typeRole: "label"; typeSize: "medium"; emphasized: true
                                    color: MeoTheme.contentOnSurface
                                }
                                Flow {
                                    Layout.fillWidth: true
                                    spacing: root.dp(8)
                                    Repeater {
                                        model: guidedQuestion.modelData.options
                                        delegate: MeoButton {
                                            id: guidedOption
                                            required property var modelData
                                            text: guidedOption.modelData.label
                                            type: root.repairController.guidedAnswers[guidedQuestion.modelData.id]
                                                  === guidedOption.modelData.id ? "tonal" : "outlined"
                                            selected: root.repairController.guidedAnswers[guidedQuestion.modelData.id]
                                                      === guidedOption.modelData.id
                                            enabled: !root.workflowBusy
                                            onClicked: root.repairController.setGuidedAnswer(
                                                guidedQuestion.modelData.id, guidedOption.modelData.id)
                                        }
                                    }
                                }
                            }
                        }
                        MeoBanner {
                            Layout.fillWidth: true
                            visible: root.repairController.guidedHandoffMessage.length > 0
                            title: qsTr("此情况不适合自动更改")
                            text: root.repairController.guidedHandoffMessage
                            icon: "support_agent"
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
                                    text: qsTr("1 · 快速检查：%1").arg(root.selectedCategoryMeta().title)
                                    typeRole: "title"; typeSize: "small"; emphasized: true
                                    color: MeoTheme.contentOnSurface
                                }
                                MeoText {
                                    Layout.fillWidth: true
                                    text: root.localizedAuditSummary()
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
                                         && (root.repairController.auditState === "running"
                                             || !root.workflowBusy)
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
                            model: root.visualPreview ? root.previewFindings()
                                                      : root.firstItems(root.repairController.auditFindings, 6)
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
                            text: root.visualPreview ? root.previewCheckLog()
                                                     : root.repairController.checkLog
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
                                    text: qsTr("2 · 选择 AI 来源")
                                    typeRole: "title"; typeSize: "small"; emphasized: true
                                    color: MeoTheme.contentOnSurface
                                }
                                MeoText {
                                    text: qsTr("选择本次会话密钥、KWallet，或 MeoArch Account。")
                                    typeRole: "body"; typeSize: "small"
                                    color: MeoTheme.contentOnSurfaceVariant
                                }
                            }
                            MeoSegmentedButtons {
                                Layout.preferredWidth: Math.min(root.dp(390), Math.max(root.dp(270), root.width * 0.35))
                                Layout.minimumWidth: root.dp(270)
                                model: [
                                    { "label": qsTr("本机密钥"), "icon": "key" },
                                    { "label": qsTr("MeoArch Account"), "icon": "account_circle" }
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
                                enabled: !root.visualPreview
                                         && root.repairController.auditState === "complete"
                                         && !root.workflowBusy
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
                                         && !root.workflowBusy
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

    Connections {
        target: SystemState
        function onNetworkChanged() {
            root.repairController.refreshEnvironmentState()
        }
    }

    MeoMotionPopup {
        id: wifiPasswordDialog
        presentation: MeoMotionPopup.Dialog
        property string ssid: ""
        anchors.centerIn: Overlay.overlay
        width: Math.min(root.dp(500), Overlay.overlay ? Overlay.overlay.width - root.dp(48) : root.dp(500))
        padding: root.dp(28)
        closePolicy: Popup.CloseOnEscape

        contentItem: ColumnLayout {
            spacing: root.dp(16)
            MeoText {
                Layout.fillWidth: true
                text: qsTr("连接到 %1").arg(wifiPasswordDialog.ssid)
                typeRole: "title"; typeSize: "medium"; emphasized: true
                color: MeoTheme.contentOnSurface
            }
            MeoTextField {
                id: repairWifiPassword
                Layout.fillWidth: true
                type: "outlined"
                size: "l"
                label: qsTr("Wi‑Fi 密码")
                echoMode: TextInput.Password
                isPassword: true
            }
            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }
                MeoButton {
                    text: qsTr("取消")
                    type: "text"
                    onClicked: {
                        repairWifiPassword.clear()
                        wifiPasswordDialog.close()
                    }
                }
                MeoButton {
                    text: qsTr("连接")
                    type: "filled"
                    enabled: repairWifiPassword.text.length > 0 && !SystemState.networkBusy
                    onClicked: {
                        SystemState.clearOperationError()
                        SystemState.connectWifi(wifiPasswordDialog.ssid, repairWifiPassword.text)
                        repairWifiPassword.clear()
                        wifiPasswordDialog.close()
                    }
                }
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
                    MeoText { Layout.fillWidth: true; text: qsTr("目标：") + String(root.consentSummary.destination || qsTr("Meo Account 服务")); wrapMode: Text.WrapAnywhere; color: MeoTheme.contentOnSurfaceVariant }
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

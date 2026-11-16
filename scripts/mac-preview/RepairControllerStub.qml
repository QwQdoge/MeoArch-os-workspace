import QtQuick
// macOS preview stub for the native RepairController. Properties default to an
// idle live-ISO session; override via PREVIEW_* in PreviewRepair.qml if needed.
QtObject {
    signal aiConsentReady(var summary)
    signal authChanged()
    signal auditChanged()
    signal aiChanged()
    signal executionChanged()
    signal guidedChanged()
    signal displayRecoveryChanged()

    property bool liveEnvironment: true
    property bool mountedTargetAvailable: false
    property bool accountConfigured: false
    property string accountConnectionState: "idle"
    property string accountEmail: ""
    property string aiMessage: ""
    property string aiSource: "local"
    property string aiState: "idle"
    property bool audioGuidedRepairAllowed: true
    property string audioRecoveryMessage: ""
    property string audioRecoveryState: "idle"
    property bool audioServiceRepairAvailable: true
    property string audioTestState: "idle"
    property var auditFindings: []
    property string auditState: "idle"
    property string auditSummary: ""
    property string authMessage: ""
    property string authState: "signedOut"
    property string bootHealthMessage: "启动项正常。"
    property string bootHealthState: "ok"
    property var checkCategories: ["audio", "display", "network", "graphics", "security", "boot", "packages", "storage"]
    property string checkLog: ""
    property string confirmationPhrase: ""
    property string credentialMessage: ""
    property string credentialState: "idle"
    property var credentials: []
    property bool diagnosticTtyAvailable: false
    property string diagnosticTtyMessage: ""
    property bool displayGuidedRepairAllowed: true
    property var displayOutputs: []
    property string displayRecoveryMessage: ""
    property int displayRecoverySeconds: 0
    property string displayRecoveryState: "idle"
    property string executionLog: ""
    property string executionState: "idle"
    property var guidedAnswers: ({})
    property string guidedHandoffMessage: ""
    property bool hasLocalCredential: false
    property bool hasSessionCredential: false
    property string localEndpoint: "http://127.0.0.1:11434/v1"
    property string localProposalModel: ""
    property string localProvider: "ollama"
    property string localReviewerModel: ""
    property bool mfaRequired: false
    property string networkConnectionMessage: "已连接到 MeoNet。"
    property string networkConnectionState: "online"
    property string planSha256: ""
    property string powerHealthMessage: "电源状态正常。"
    property string powerHealthState: "ok"
    property string proposalCredentialId: ""
    property string proposalJson: ""
    property bool readyToExecute: false
    property string reviewerCredentialId: ""
    property string riskReviewJson: ""
    property string selectedCategory: "all"
    property bool signedIn: false
    property string storageHealthMessage: "磁盘空间充足，SMART 状态正常。"
    property string storageHealthState: "ok"
    property string timeHealthMessage: "系统时间已同步。"
    property string timeHealthState: "ok"

    function beginDisplayRecovery() {}
    function cancelQuickCheck() {}
    function classifyProblem(text) { return "all" }
    function clearPlan() {}
    function clearSessionCredential() {}
    function configureLocalAi() {}
    function deleteLocalCredential() {}
    function executeConfirmedPlan() {}
    function guidedQuestionsForCategory(c) { return [] }
    function keepDisplayRecovery() {}
    function openDiagnosticTty() {}
    function playAudioTestTone() {}
    function prepareGuidedCategory(c) {}
    function refreshCredentials() {}
    function refreshDisplayOutputs() {}
    function refreshEnvironmentState() {}
    function requestAiPlan() {}
    function resolveAiConsent(ok) {}
    function restartAudioServices() {}
    function revertDisplayRecovery() {}
    function saveLocalCredential() {}
    function setAiSource(s) { aiSource = s }
    function setGuidedAnswer(k, v) {}
    function setProposalCredentialId(i) { proposalCredentialId = i }
    function setReviewerCredentialId(i) { reviewerCredentialId = i }
    function setUserProblem(t) {}
    function signIn() {}
    function signOut() {}
    function startQuickCheck(c) {}
    function verifyTotp(c) {}
}

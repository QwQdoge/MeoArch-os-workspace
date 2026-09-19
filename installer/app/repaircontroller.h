#pragma once

#include <QJsonObject>
#include <QNetworkAccessManager>
#include <QObject>
#include <QProcess>
#include <QTimer>
#include <QUrl>
#include <QVariantList>
#include <QVariantMap>
#include "sessionjournal.h"
#include "agentstate.h"
#include <functional>

class RepairController final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool accountConfigured READ accountConfigured CONSTANT)
    Q_PROPERTY(bool liveEnvironment READ liveEnvironment CONSTANT)
    Q_PROPERTY(QVariantList checkCategories READ checkCategories CONSTANT)
    Q_PROPERTY(QString selectedCategory READ selectedCategory NOTIFY auditChanged)
    Q_PROPERTY(QString checkLog READ checkLog NOTIFY auditChanged)
    Q_PROPERTY(QString authState READ authState NOTIFY authChanged)
    Q_PROPERTY(QString authMessage READ authMessage NOTIFY authChanged)
    Q_PROPERTY(QString accountEmail READ accountEmail NOTIFY authChanged)
    Q_PROPERTY(bool signedIn READ signedIn NOTIFY authChanged)
    Q_PROPERTY(bool mfaRequired READ mfaRequired NOTIFY authChanged)
    Q_PROPERTY(QVariantList credentials READ credentials NOTIFY credentialsChanged)
    Q_PROPERTY(QString proposalCredentialId READ proposalCredentialId NOTIFY credentialsChanged)
    Q_PROPERTY(QString reviewerCredentialId READ reviewerCredentialId NOTIFY credentialsChanged)
    Q_PROPERTY(QString auditState READ auditState NOTIFY auditChanged)
    Q_PROPERTY(QString auditSummary READ auditSummary NOTIFY auditChanged)
    Q_PROPERTY(QVariantList auditFindings READ auditFindings NOTIFY auditChanged)
    Q_PROPERTY(QString aiState READ aiState NOTIFY aiChanged)
    Q_PROPERTY(QString aiMessage READ aiMessage NOTIFY aiChanged)
    Q_PROPERTY(QString proposalJson READ proposalJson NOTIFY aiChanged)
    Q_PROPERTY(QString riskReviewJson READ riskReviewJson NOTIFY aiChanged)
    Q_PROPERTY(QString planSha256 READ planSha256 NOTIFY aiChanged)
    Q_PROPERTY(QString confirmationPhrase READ confirmationPhrase NOTIFY aiChanged)
    Q_PROPERTY(bool readyToExecute READ readyToExecute NOTIFY aiChanged)
    Q_PROPERTY(QString executionState READ executionState NOTIFY executionChanged)
    Q_PROPERTY(QString executionLog READ executionLog NOTIFY executionChanged)
    Q_PROPERTY(QString aiSource READ aiSource NOTIFY aiConfigurationChanged)
    Q_PROPERTY(QString localProvider READ localProvider NOTIFY aiConfigurationChanged)
    Q_PROPERTY(QString localEndpoint READ localEndpoint NOTIFY aiConfigurationChanged)
    Q_PROPERTY(QString localProposalModel READ localProposalModel NOTIFY aiConfigurationChanged)
    Q_PROPERTY(QString localReviewerModel READ localReviewerModel NOTIFY aiConfigurationChanged)
    Q_PROPERTY(bool hasLocalCredential READ hasLocalCredential NOTIFY credentialChanged)
    Q_PROPERTY(bool hasSessionCredential READ hasSessionCredential NOTIFY credentialChanged)
    Q_PROPERTY(QString credentialState READ credentialState NOTIFY credentialChanged)
    Q_PROPERTY(QString credentialMessage READ credentialMessage NOTIFY credentialChanged)
    Q_PROPERTY(bool diagnosticTtyAvailable READ diagnosticTtyAvailable NOTIFY diagnosticTtyChanged)
    Q_PROPERTY(QString diagnosticTtyMessage READ diagnosticTtyMessage NOTIFY diagnosticTtyChanged)
    Q_PROPERTY(QString userProblem READ userProblem NOTIFY guidedChanged)
    Q_PROPERTY(QVariantMap guidedAnswers READ guidedAnswers NOTIFY guidedChanged)
    Q_PROPERTY(QString guidedHandoffMessage READ guidedHandoffMessage NOTIFY guidedChanged)
    Q_PROPERTY(bool audioGuidedRepairAllowed READ audioGuidedRepairAllowed NOTIFY guidedChanged)
    Q_PROPERTY(bool displayGuidedRepairAllowed READ displayGuidedRepairAllowed NOTIFY guidedChanged)
    Q_PROPERTY(bool audioServiceRepairAvailable READ audioServiceRepairAvailable NOTIFY auditChanged)
    Q_PROPERTY(QString audioTestState READ audioTestState NOTIFY audioTestChanged)
    Q_PROPERTY(QString audioTestMessage READ audioTestMessage NOTIFY audioTestChanged)
    Q_PROPERTY(QString audioRecoveryState READ audioRecoveryState NOTIFY guidedChanged)
    Q_PROPERTY(QString audioRecoveryMessage READ audioRecoveryMessage NOTIFY guidedChanged)
    Q_PROPERTY(QVariantList displayOutputs READ displayOutputs NOTIFY displayRecoveryChanged)
    Q_PROPERTY(QString displayRecoveryState READ displayRecoveryState NOTIFY displayRecoveryChanged)
    Q_PROPERTY(QString displayRecoveryMessage READ displayRecoveryMessage NOTIFY displayRecoveryChanged)
    Q_PROPERTY(int displayRecoverySeconds READ displayRecoverySeconds NOTIFY displayRecoveryChanged)

public:
    explicit RepairController(QObject *parent = nullptr);
    ~RepairController() override;

    bool accountConfigured() const;
    bool liveEnvironment() const { return m_liveEnvironment; }
    QVariantList checkCategories() const { return m_checkCategories; }
    QString selectedCategory() const { return m_selectedCategory; }
    QString checkLog() const { return m_checkLog; }
    QString authState() const { return m_authState; }
    QString authMessage() const { return m_authMessage; }
    QString accountEmail() const { return m_accountEmail; }
    bool signedIn() const { return m_authState == QStringLiteral("signed_in"); }
    bool mfaRequired() const { return m_authState == QStringLiteral("mfa_required"); }
    QVariantList credentials() const { return m_credentials; }
    QString proposalCredentialId() const { return m_proposalCredentialId; }
    QString reviewerCredentialId() const { return m_reviewerCredentialId; }
    QString auditState() const { return m_auditState; }
    QString auditSummary() const { return m_auditSummary; }
    QVariantList auditFindings() const { return m_auditFindings; }
    QString aiState() const { return m_aiState; }
    QString aiMessage() const { return m_aiMessage; }
    QString proposalJson() const { return m_proposalJson; }
    QString riskReviewJson() const { return m_riskReviewJson; }
    QString planSha256() const { return m_planSha256; }
    QString confirmationPhrase() const { return m_confirmationPhrase; }
    bool readyToExecute() const { return m_readyToExecute; }
    QString executionState() const { return m_executionState; }
    QString executionLog() const { return m_executionLog; }
    QString aiSource() const { return m_aiSource; }
    QString localProvider() const { return m_localProvider; }
    QString localEndpoint() const { return m_localEndpoint; }
    QString localProposalModel() const { return m_localProposalModel; }
    QString localReviewerModel() const { return m_localReviewerModel; }
    bool hasLocalCredential() const { return m_hasLocalCredential; }
    bool hasSessionCredential() const
    {
        return !m_sessionApiKey.isEmpty() && m_sessionCredentialProvider == m_localProvider;
    }
    QString credentialState() const { return m_credentialState; }
    QString credentialMessage() const { return m_credentialMessage; }
    bool diagnosticTtyAvailable() const { return m_diagnosticTtyAvailable; }
    QString diagnosticTtyMessage() const { return m_diagnosticTtyMessage; }
    QString userProblem() const { return m_userProblem; }
    QVariantMap guidedAnswers() const { return m_guidedAnswers; }
    QString guidedHandoffMessage() const;
    bool audioGuidedRepairAllowed() const;
    bool displayGuidedRepairAllowed() const;
    bool audioServiceRepairAvailable() const;
    QString audioTestState() const { return m_audioTestState; }
    QString audioTestMessage() const { return m_audioTestMessage; }
    QString audioRecoveryState() const { return m_audioRecoveryState; }
    QString audioRecoveryMessage() const { return m_audioRecoveryMessage; }
    QVariantList displayOutputs() const { return m_displayOutputs; }
    QString displayRecoveryState() const { return m_displayRecoveryState; }
    QString displayRecoveryMessage() const { return m_displayRecoveryMessage; }
    int displayRecoverySeconds() const { return m_displayRecoverySeconds; }

    Q_INVOKABLE void signIn(const QString &email, const QString &password);
    Q_INVOKABLE void verifyTotp(const QString &code);
    Q_INVOKABLE void signOut();
    Q_INVOKABLE void refreshCredentials();
    Q_INVOKABLE void setProposalCredentialId(const QString &id);
    Q_INVOKABLE void setReviewerCredentialId(const QString &id);
    Q_INVOKABLE void setAiSource(const QString &source);
    Q_INVOKABLE void configureLocalAi(const QString &provider, const QString &endpoint,
                                      const QString &proposalModel, const QString &reviewerModel);
    Q_INVOKABLE void saveLocalCredential(const QString &secret, bool sessionOnly);
    Q_INVOKABLE void deleteLocalCredential();
    Q_INVOKABLE void clearSessionCredential();
    Q_INVOKABLE QString classifyProblem(const QString &problem) const;
    Q_INVOKABLE void setUserProblem(const QString &problem);
    Q_INVOKABLE QVariantList guidedQuestionsForCategory(const QString &categoryId) const;
    Q_INVOKABLE void prepareGuidedCategory(const QString &categoryId);
    Q_INVOKABLE void setGuidedAnswer(const QString &questionId, const QString &optionId);
    Q_INVOKABLE void startQuickCheck(const QString &categoryId);
    Q_INVOKABLE void cancelQuickCheck();
    Q_INVOKABLE void openDiagnosticTty();
    Q_INVOKABLE void startAudit();
    Q_INVOKABLE void requestAiPlan();
    Q_INVOKABLE void resolveAiConsent(bool approved);
    Q_INVOKABLE void executeConfirmedPlan(const QString &confirmation);
    Q_INVOKABLE void clearPlan();
    Q_INVOKABLE void playAudioTestTone();
    Q_INVOKABLE void restartAudioServices();
    Q_INVOKABLE void refreshDisplayOutputs();
    Q_INVOKABLE void beginDisplayRecovery(const QString &outputId);
    Q_INVOKABLE void keepDisplayRecovery();
    Q_INVOKABLE void revertDisplayRecovery();

signals:
    void authChanged();
    void credentialsChanged();
    void auditChanged();
    void aiChanged();
    void executionChanged();
    void aiConfigurationChanged();
    void credentialChanged();
    void diagnosticTtyChanged();
    void guidedChanged();
    void audioTestChanged();
    void displayRecoveryChanged();
    void quickCheckFinished(int exitCode);
    void aiConsentReady(const QVariantMap &summary);

private:
    using JsonCallback = std::function<void(int, const QJsonObject &)>;

    void postJson(const QUrl &url, const QJsonObject &payload,
                  const QString &bearer, JsonCallback callback);
    QUrl authUrl(const QString &path) const;
    QUrl functionUrl() const;
    QString jsonError(const QJsonObject &object, const QString &fallback) const;
    void acceptSession(const QJsonObject &session, const QString &emailFallback);
    void finishAuthentication();
    void setAuth(const QString &state, const QString &message = {});
    void setAi(const QString &state, const QString &message = {});
    void setExecution(const QString &state, const QString &message = {});
    void callBroker(const QJsonObject &payload, JsonCallback callback);
    QVariantMap credentialById(const QString &id) const;
    void prepareInference(const QString &stage, const QString &credentialId,
                          const QString &purpose, const QStringList &categories,
                          const QString &systemPrompt, const QString &userPrompt);
    void prepareLocalInference(const QString &stage, const QString &purpose,
                               const QStringList &categories,
                               const QString &systemPrompt, const QString &userPrompt);
    void invokePreparedInference();
    void invokeLocalInference();
    void invokeLocalInferenceWithKey(QString apiKey);
    void handleInferenceResult(const QString &stage, const QString &text);
    void prepareRiskReview();
    QJsonObject extractJsonObject(const QString &text) const;
    bool validatePlan(const QJsonObject &plan, QString *error) const;
    bool validateReview(const QJsonObject &review, QString *error) const;
    void parseCheckOutput(const QString &output);
    void consumeCheckOutput(const QString &output, bool finalChunk = false);
    void rebuildAiAuditReport();
    void runNextApprovedAction();
    QString credentialModel(const QString &id) const;
    QString checkScriptPath(const QString &categoryId) const;
    QString actionScriptPath(const QString &kind) const;
    QString knowledgeText(const QString &fileName, const QString &fallback = {}) const;
    QString runbookText(const QString &categoryId) const;
    bool actionSupportedByEvidence(const QString &kind) const;
    bool hasBlockingOperation() const;
    bool runKscreen(const QStringList &arguments, QByteArray *output, QString *error) const;
    bool scheduleDisplayRollback(const QString &outputId, QString *error);
    bool cancelDisplayRollback(QString *error);
    QString providerDisplayName(const QString &provider) const;
    QUrl accountProviderUrl(const QVariantMap &credential, const QString &model) const;
    QUrl localProviderUrl(const QString &provider, const QString &model) const;
    QString localResponseText(const QString &provider, const QJsonObject &object) const;
    bool validLocalConfiguration(QString *error) const;
    void loadAccountEnvironmentFile();
    void updateCredentialMarker();
    void clearPendingInference();
    void beginAudioServicePostCheck();
    void beginAudioOutputPostCheck();
    QString computeEvidenceSnapshotId() const;
    bool bindCurrentPlan(QString *error);
    bool currentPlanBindingValid(QString *error) const;
    void appendExecutionJournal(const QString &state, const QString &actionId = {});
    bool dispatchPrivilegedServiceAction(const QString &kind, const QString &actionId);

    QNetworkAccessManager m_network;
    QString m_supabaseUrl;
    QString m_publishableKey;
    QString m_accessToken;
    QString m_refreshToken;
    QString m_accountEmail;
    QString m_mfaFactorId;
    QString m_authState = QStringLiteral("signed_out");
    QString m_authMessage;
    QVariantList m_credentials;
    QString m_proposalCredentialId;
    QString m_reviewerCredentialId;

    QProcess *m_auditProcess = nullptr;
    bool m_liveEnvironment = false;
    QVariantList m_checkCategories;
    QString m_selectedCategory = QStringLiteral("all");
    QString m_userProblem;
    QString m_guidedCategory;
    QVariantMap m_guidedAnswers;
    QString m_audioTestState = QStringLiteral("idle");
    QString m_audioTestMessage;
    QProcess *m_audioTestProcess = nullptr;
    QString m_audioRecoveryState = QStringLiteral("idle");
    QString m_audioRecoveryMessage;
    QProcess *m_audioRecoveryProcess = nullptr;
    int m_audioOutputPostCheckAttempts = 0;
    QString m_checkLog;
    QString m_checkParseBuffer;
    QString m_auditState = QStringLiteral("idle");
    QString m_auditSummary = QStringLiteral("Run the read-only audit before asking AI for a plan.");
    QVariantList m_auditFindings;
    QString m_auditReport;
    QString m_evidenceSnapshotId;

    QString m_aiState = QStringLiteral("idle");
    QString m_aiMessage;
    QString m_pendingStage;
    QJsonObject m_pendingRequest;
    QJsonObject m_pendingConsent;
    QJsonObject m_plan;
    QString m_proposalJson;
    QString m_riskReviewJson;
    QString m_planSha256;
    QString m_confirmationPhrase;
    bool m_readyToExecute = false;
    QJsonObject m_planBinding;
    QString m_planExpiryUtc;
    QString m_sessionNonce;

    QString m_executionState = QStringLiteral("idle");
    QString m_executionLog;
    QVariantList m_executionActions;
    int m_executionIndex = 0;
    bool m_executionFailed = false;
    QProcess *m_executionProcess = nullptr;
    QObject *m_privilegedCallWatcher = nullptr;

    QString m_aiSource = QStringLiteral("local");
    QString m_localProvider = QStringLiteral("openai");
    QString m_localEndpoint;
    QString m_localProposalModel = QStringLiteral("gpt-5");
    QString m_localReviewerModel = QStringLiteral("gpt-5-mini");
    QString m_sessionApiKey;
    QString m_sessionCredentialProvider;
    bool m_hasLocalCredential = false;
    QString m_credentialState = QStringLiteral("idle");
    QString m_credentialMessage;
    bool m_diagnosticTtyAvailable = false;
    QString m_diagnosticTtyMessage;
    QVariantList m_displayOutputs;
    QString m_displayRecoveryState = QStringLiteral("idle");
    QString m_displayRecoveryMessage;
    QString m_displayRollbackId;
    QString m_displayRollbackUnit;
    int m_displayRecoverySeconds = 0;
    QTimer m_displayRecoveryTimer;
    MeoRepair::SessionJournal m_sessionJournal;
    MeoRepair::AgentStateMachine m_agentState;
};

#pragma once

#include <QJsonObject>
#include <QNetworkAccessManager>
#include <QObject>
#include <QProcess>
#include <QUrl>
#include <QVariantList>
#include <QVariantMap>
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
    Q_INVOKABLE void startQuickCheck(const QString &categoryId);
    Q_INVOKABLE void cancelQuickCheck();
    Q_INVOKABLE void openDiagnosticTty();
    Q_INVOKABLE void startAudit();
    Q_INVOKABLE void requestAiPlan();
    Q_INVOKABLE void resolveAiConsent(bool approved);
    Q_INVOKABLE void executeConfirmedPlan(const QString &confirmation);
    Q_INVOKABLE void clearPlan();

signals:
    void authChanged();
    void credentialsChanged();
    void auditChanged();
    void aiChanged();
    void executionChanged();
    void aiConfigurationChanged();
    void credentialChanged();
    void diagnosticTtyChanged();
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
    void parseLynisReport();
    void parseCheckOutput(const QString &output);
    void rebuildAiAuditReport();
    void runNextApprovedAction();
    QString credentialModel(const QString &id) const;
    QString checkScriptPath(const QString &categoryId) const;
    QString actionScriptPath(const QString &kind) const;
    QString providerDisplayName(const QString &provider) const;
    QUrl accountProviderUrl(const QVariantMap &credential, const QString &model) const;
    QUrl localProviderUrl(const QString &provider, const QString &model) const;
    QString localResponseText(const QString &provider, const QJsonObject &object) const;
    bool validLocalConfiguration(QString *error) const;
    void loadAccountEnvironmentFile();
    void updateCredentialMarker();
    void clearPendingInference();

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
    QString m_checkLog;
    QString m_auditState = QStringLiteral("idle");
    QString m_auditSummary = QStringLiteral("Run the read-only audit before asking AI for a plan.");
    QVariantList m_auditFindings;
    QString m_auditReport;

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

    QString m_executionState = QStringLiteral("idle");
    QString m_executionLog;
    QVariantList m_executionActions;
    int m_executionIndex = 0;
    bool m_executionFailed = false;
    QProcess *m_executionProcess = nullptr;

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
};

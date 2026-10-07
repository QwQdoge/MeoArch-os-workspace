#include "systemtransactionservice.h"

#include "transactionvalidator.h"

SystemTransactionService::SystemTransactionService(QObject *parent)
    : QObject(parent)
{
}

QVariantMap SystemTransactionService::Inspect(const QString &kind, const QVariantMap &request) const
{
    return TransactionValidator::inspect(kind, request);
}

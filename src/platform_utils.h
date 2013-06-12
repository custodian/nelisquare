#ifndef PLATFORMUTILS_H
#define PLATFORMUTILS_H

#include <QObject>
#include <QString>
#include <QVariant>
#include <QMap>
#include "cache.h"

class PlatformUtils : public QObject
{
    Q_OBJECT
protected:
    Cache *m_cache;
    QMap<QString,qlonglong> m_items;

public:
    explicit PlatformUtils(QObject *parent = 0, Cache *cache = 0);
    
    // Create a system notification based on eventType
    Q_INVOKABLE void addNotification(const QString &eventType, const QString &summary, const QString &body,
                                         const int count);

    // Clear system notifications based on eventType
    Q_INVOKABLE void removeNotification(const QString &eventType);

    // Clear event feed
    Q_INVOKABLE void clearFeed();

    // Add new item to feed
    Q_INVOKABLE void addFeedItem(QVariant item);

    // Add update item at feed
    Q_INVOKABLE void updateFeedItem(QVariant item);

    // Remove item from feed
    Q_INVOKABLE void removeFeedItem(QVariant item);

signals:

public slots:
    
private slots:
    //void onDownloadFinished(QNetworkReply *);
};

#endif // PLATFORMUTILS_H

#ifndef QMLCACHE_H
#define QMLCACHE_H

#include <QObject>
#include <QString>
#include <QVariant>
#include <QMap>
#include <QtNetwork/QNetworkAccessManager>

class Cache : public QObject
{
    Q_OBJECT
protected:
    QNetworkAccessManager * manager;

    QString md5(QString data);
    QString makeCachedURL(QString url);

    QString m_path;
    QMap<QString,QString> m_cachemap;
    QMap<QString, QVariantList> m_cachequeue;
    bool m_cacheonly;

    bool queueCacheUpdate(QVariant url, QVariant callback);
    void makeCallbackAll(bool status, QVariant url);
    void makeCallback(QVariant callback, bool status, QVariant url);

public:
    explicit Cache(QObject *parent = 0);
    
    Q_INVOKABLE QVariant get(QVariant url, QVariant callback);

    Q_INVOKABLE QVariant remove(QVariant url);

    Q_INVOKABLE QVariant info();

    Q_INVOKABLE QVariant reset();

    Q_INVOKABLE QVariant loadtype(QVariant type);

signals:
    void cacheUpdated(QVariant callback, QVariant status, QVariant url);

public slots:
    
private slots:
    void onDownloadFinished(QNetworkReply *);

};

#endif // QMLCACHE_H

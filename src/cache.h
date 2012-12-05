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
    bool m_cacheonly;

public:
    explicit Cache(QObject *parent = 0);
    
    Q_INVOKABLE QVariant get(QVariant url);

    Q_INVOKABLE QVariant remove(QVariant url);

    Q_INVOKABLE QVariant info();

    Q_INVOKABLE QVariant reset();

    Q_INVOKABLE QVariant loadtype(QVariant type);

signals:

public slots:
    
private slots:
    void onDownloadFinished(QNetworkReply *);

};

#endif // QMLCACHE_H

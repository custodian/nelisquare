#ifndef QMLCACHE_H
#define QMLCACHE_H

#include <QObject>
#include <QString>
#include <QVariant>
#include <QtNetwork/QNetworkAccessManager>

class Cache : public QObject
{
    Q_OBJECT
protected:
    QNetworkAccessManager * manager;

    QString md5(QString data);

    QString m_path;

public:
    explicit Cache(QObject *parent = 0);
    
    Q_INVOKABLE QVariant get(QVariant url);

    Q_INVOKABLE QVariant info();

    Q_INVOKABLE QVariant reset();

signals:

public slots:
    
private slots:
    void onDownloadFinished(QNetworkReply *);

};

#endif // QMLCACHE_H

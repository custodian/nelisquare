#include "cache.h"
#include <QUrl>
#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkRequest>
#include <QtNetwork/QNetworkReply>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QByteArray>
#include <QCryptographicHash>
#include <QDesktopServices>
#include <QDebug>

Cache::Cache(QObject *parent) :
    QObject(parent)
{
    QDesktopServices dirs;
    m_path = dirs.storageLocation(QDesktopServices::CacheLocation);
    qDebug() << "Cache location: " << m_path;

    if (m_path.length()) {
        QDir dir;
        if (!dir.mkpath(m_path))
            qDebug () << "Error creating cache directory";
    }

    manager = new QNetworkAccessManager (this);
    connect(manager,SIGNAL(finished(QNetworkReply*)),SLOT(onDownloadFinished(QNetworkReply*)));
}

void Cache::onDownloadFinished(QNetworkReply * reply){
    QByteArray data = reply->readAll();
    QString url = reply->request().url().toString();
    QString name = m_path + "/" + md5(url);

    //qDebug() << "Got url:"  << url << "Name:" << name;

    QFile file(name);
    file.open(QFile::WriteOnly);
    file.write(data);
}

QString Cache::md5(QString data)
{
    QCryptographicHash hash(QCryptographicHash::Md5);
    hash.addData(data.toAscii());
    return hash.result().toHex();
}

QVariant Cache::get(QVariant data)
{
    QString url = data.toString();
    if (url.size()) {
        QString name = m_path + "/" + md5(url);
        QFileInfo file(name);
        //qDebug() << "Hash:" << name << "Status:" << file.exists() << "URL:" << url;
        if (file.exists()) {
            return QVariant(name);
        } else {
            //post and download query
            manager->get(QNetworkRequest(QUrl(url)));
            return data;
        }
    }
    return data;
}

QVariant Cache::info()
{
    return QVariant("empty");
}

QVariant Cache::reset()
{
    return QVariant(true);
}

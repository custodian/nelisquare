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
#include <QString>
#include <QDebug>

Cache::Cache(QObject *parent) :
    QObject(parent)
{
    QDesktopServices dirs;
    m_path = dirs.storageLocation(QDesktopServices::CacheLocation);
    m_path += "/nelisquare/";
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
    qint64 total = 0;
    QDir dir(m_path);
    dir.setFilter(QDir::Files | QDir::Hidden | QDir::NoSymLinks);
    QFileInfoList list = dir.entryInfoList();
    for (int i=0; i<list.size();i++) {
        total += list.at(i).size();
    }

    {
        //TODO: remove legacy code
        // Due to error in 0.4.1 will be there until 0.5.0 is out
        QDir dir2(m_path+"/../");
        dir2.setFilter(QDir::Files | QDir::Hidden | QDir::NoSymLinks);
        dir2.setNameFilters(QStringList("????????????????????????????????"));
        QFileInfoList list2 = dir2.entryInfoList();
        for (int i=0; i<list2.size();i++) {
            total += list2.at(i).size();
        }
    }

    double result = double(total) / 1000000;
    return QVariant(QString("%1 MB").arg(result,0,'g',3));
}

QVariant Cache::reset()
{
    QDir dir(m_path);
    dir.setFilter(QDir::Files | QDir::Hidden | QDir::NoSymLinks);
    QFileInfoList list = dir.entryInfoList();
    for (int i=0; i<list.size();i++) {
        QFile(list.at(i).absoluteFilePath()).remove();
    }

    {
        //TODO: remove legacy code
        // Due to error in 0.4.1 will be there until 0.5.0 is out
        QDir dir2(m_path+"/../");
        dir2.setFilter(QDir::Files | QDir::Hidden | QDir::NoSymLinks);
        dir2.setNameFilters(QStringList("????????????????????????????????"));
        QFileInfoList list2 = dir2.entryInfoList();
        for (int i=0; i<list2.size();i++) {
            QFile(list2.at(i).absoluteFilePath()).remove();
        }
    }

    return QVariant(true);
}

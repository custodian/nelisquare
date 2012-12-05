#include "cache.h"
#include <QUrl>
#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkRequest>
#include <QtNetwork/QNetworkReply>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QDateTime>
#include <QByteArray>
#include <QCryptographicHash>
#include <QDesktopServices>
#include <QString>
#include <QDebug>

Cache::Cache(QObject *parent) :
    QObject(parent)
{
    m_cacheonly = false;

    QDesktopServices dirs;
    m_path = dirs.storageLocation(QDesktopServices::CacheLocation);
    m_path += "/nelisquare/";
    //qDebug() << "Cache location: " << m_path;

    if (m_path.length()) {
        QDir dir;
        if (!dir.mkpath(m_path))
            qDebug () << "Error creating cache directory";
    }

    manager = new QNetworkAccessManager (this);
    connect(manager,SIGNAL(finished(QNetworkReply*)),SLOT(onDownloadFinished(QNetworkReply*)));
}

QVariant Cache::loadtype(QVariant _type) {
    QString type = _type.toString();
    if (type == "all") {
        m_cacheonly = false;
    } else {
        m_cacheonly = true;
    }
    return QVariant(true);
}

void Cache::onDownloadFinished(QNetworkReply * reply){
    QByteArray data = reply->readAll();
    QString url = reply->request().url().toString();
    QString name = makeCachedURL(url);

    QFile file(name);
    file.open(QFile::WriteOnly);
    file.write(data);

    m_cachemap.insert(url,name);
    //qDebug() << "cache update";
}

QString Cache::md5(QString data)
{
    QCryptographicHash hash(QCryptographicHash::Md5);
    hash.addData(data.toAscii());
    return hash.result().toHex();
}

QString Cache::makeCachedURL(QString url)
{
    QString ext = url.right(url.size() - url.lastIndexOf("."));
    return m_path + "/" + md5(url) + ext;
}

QVariant Cache::remove(QVariant data)
{
    QString url = data.toString();
    if (url.size()) {
        m_cachemap.remove(url);
        QFile::remove(makeCachedURL(url));
    }
}

QVariant Cache::get(QVariant data)
{
    QString url = data.toString();
    if (url.size()) {
        QMap<QString,QString>::iterator it = m_cachemap.find(url);
        if (it!=m_cachemap.end()) {
            //qDebug() << "cache hit";
            data = it.value();
        } else {
            //qDebug() << "cache miss";
            QString name = makeCachedURL(url);
            QFileInfo file(name);
            //qDebug() << "Hash:" << name << "Status:" << file.exists() << "URL:" << url;
            if (file.exists()) {
                data = QVariant(name);
            } else {
                if (m_cacheonly) {
                    data = QVariant("");
                } else {
                    //post and download query
                    manager->get(QNetworkRequest(QUrl(url)));
                }
            }
        }
    }
    return data;
}

QVariant Cache::info()
{
    QDateTime today;
    today = QDateTime::currentDateTime();
    qint64 total = 0;
    QDir dir(m_path);
    dir.setFilter(QDir::Files | QDir::Hidden | QDir::NoSymLinks);
    QFileInfoList list = dir.entryInfoList();
    for (int i=0; i<list.size();i++) {
        QDateTime modif = list.at(i).lastModified();
        if (modif.daysTo(today) > 14) {
            QFile(list.at(i).absoluteFilePath()).remove();
        }
        else {
            total += list.at(i).size();
        }
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
    m_cachemap.clear();

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

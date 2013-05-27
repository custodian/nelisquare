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
    if (reply->error() != QNetworkReply::NoError) {
        qDebug() << "Error downloading: " << reply->errorString();
        return;
    }
    QByteArray data = reply->readAll();
    if (data.size() == 0) {
        qDebug() << "Empty data packet";
        return;
    }
    QString url = reply->request().url().toString();
    QString name = makeCachedURL(url);

    {
        QFile file(name);
        file.open(QFile::WriteOnly);
        file.write(data);
    }

    m_cachemap_lock.lockForWrite();
    m_cachemap.insert(url,name);
    m_cachemap_lock.unlock();
    makeCallbackAll(true,url);
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

QVariant Cache::removeUrl(QVariant data)
{
    QString url = data.toString();
    if (url.size()) {
        m_cachemap_lock.lockForWrite();
        m_cachemap.remove(url);
        m_cachemap_lock.unlock();
        QFile::remove(makeCachedURL(url));
    }
    return QVariant(true);
}

void Cache::queueObject(QVariant data, QObject *callback)
{
    //qDebug() << "QueueObject callback: " << callback;
    QString url = data.toString();
    if (url.size()) {
        m_cachemap_lock.lockForRead();
        QMap<QString,QString>::iterator it = m_cachemap.find(url);
        if (it!=m_cachemap.end()) {
            //qDebug() << "cache hit" << url;
            data = it.value();
            m_cachemap_lock.unlock();
            makeCallback(callback,true,data);
        } else {
            //qDebug() << "cache miss" << url;
            QString name = makeCachedURL(url);
            QFileInfo file(name);
            //qDebug() << "Hash:" << name << "Status:" << file.exists() << "URL:" << url;
            if (file.exists()) {
                data = QVariant(name);
                m_cachemap_lock.unlock();
                m_cachemap_lock.lockForWrite();
                m_cachemap.insert(url,name);
                m_cachemap_lock.unlock();
                makeCallback(callback,true,data);
            } else {
                if (m_cacheonly) {
                    data = QVariant("");
                } else {
                    //add to queue, post and download query
                    if (queueCacheUpdate(data, callback)) {
                        //qDebug() << "download " << url;
                        manager->get(QNetworkRequest(QUrl(url)));
                    }
                }
                m_cachemap_lock.unlock();
            }            
        }
    }
}

void Cache::dequeueObject(QVariant url, QObject* callback)
{
    //qDebug() << "Removing callback from queue" << callback << url;
    CCacheQueue::iterator it;
    m_cachequeue_lock.lockForWrite();
    it = m_cachequeue.find(url.toString());
    if (it == m_cachequeue.end()) {
        m_cachequeue_lock.unlock();
        //qDebug() << "Callback not found";
        //qDebug() << m_cachequeue;
        return;
    }
    CCallbackList &callbacks = *it;
    //qDebug() << "Remove callback from queue" << callback;
    callbacks.remove(callback); //return removing callback
    m_cachequeue_lock.unlock();
}

bool Cache::queueCacheUpdate(QVariant url, QObject* callback) {
    bool fresh = false;
    //qDebug() << "Adding callback to queue" << callback << url;
    m_cachequeue_lock.lockForWrite();
    CCacheQueue::iterator it;
    it = m_cachequeue.find(url.toString());
    if (it == m_cachequeue.end()) {
        m_cachequeue.insert(url.toString(),CCallbackList());
        it = m_cachequeue.find(url.toString());
        fresh = true;
    };
    it->insert(callback);
    m_cachequeue_lock.unlock();
    return fresh;
}

void Cache::makeCallbackAll(bool status, QVariant url)
{
    //qDebug() << "make all callback" << url;
    CCacheQueue::iterator it;
    m_cachequeue_lock.lockForRead();
    it = m_cachequeue.find(url.toString());
    if (it == m_cachequeue.end()) {
        m_cachequeue_lock.unlock();
        return;
    }
    CCallbackList &callbacks = *it;
    CCallbackList::iterator itc = callbacks.begin();
    while(itc!=callbacks.end()) {
        makeCallback(*itc,status,url.toString());
        itc++;
    }
    m_cachequeue_lock.unlock();
    m_cachequeue_lock.lockForWrite();
    m_cachequeue.remove(url.toString());
    m_cachequeue_lock.unlock();
}

void Cache::makeCallback(QObject* callback, bool status, QVariant url)
{
    //qDebug() << "makecallback: " << callback;
    emit cacheUpdated(QVariant::fromValue(callback), QVariant(status), url);
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

    return QVariant(true);
}

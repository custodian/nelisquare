#include "picturehelper.h"
#include <QUrl>
#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkRequest>
#include <QtNetwork/QNetworkReply>
#include <QFile>
#include <QByteArray>
#include <QDebug>

#include "extras/formpost.h"

PictureHelper::PictureHelper(QObject *parent) :
    QObject(parent)
{
    manager = new QNetworkAccessManager (this);
    connect(manager,SIGNAL(finished(QNetworkReply*)),SLOT(onFinished(QNetworkReply*)));
}


QVariant PictureHelper::upload(QVariant url, QVariant path)
{
    //TODO: check for 5MB limit
    FormPost *formPost = new FormPost("nelisquare");
    formPost->setFile("photo", path.toString(), "image/jpeg");

    formPost->setNetworkAccessManager(manager);
    QNetworkReply *reply = formPost->postData(url.toString());
    formPost->setParent(reply);

    return QVariant(true);
}

void PictureHelper::onFinished(QNetworkReply * reply){
    QByteArray data = reply->readAll();
    emit pictureUploaded(QVariant(QString(data)));
}

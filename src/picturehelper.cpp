#include "picturehelper.h"
#include <QtGui/QImage>
#include <QtGui/QStyleOptionGraphicsItem>
#include <QtGui/QPainter>
#include <QtGui/QDesktopServices>
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

QVariant PictureHelper::upload(QVariant url, QVariant path, QVariant window)
{
    m_window = window;
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
    emit pictureUploaded(QVariant(QString(data)), m_window);
}

QString PictureHelper::saveImage(QDeclarativeItem *imageObject)
{
    QString fileName = "nelisquare_" + QDateTime::currentDateTime().toString("d-M-yy_h-m-s") + ".png";
    QString filePath = QDesktopServices::storageLocation(QDesktopServices::PicturesLocation) + "/" + fileName;

    QImage img(imageObject->boundingRect().size().toSize(), QImage::Format_ARGB32);
    img.fill(QColor(0,0,0,0).rgba());
    QPainter painter(&img);
    QStyleOptionGraphicsItem styleOption;
    imageObject->paint(&painter, &styleOption, 0);
    bool saved = img.save(filePath, "PNG");

    if (!saved) {
        qWarning("QMLUtils::saveImage: Failed to save image to %s", qPrintable(filePath));
        return "";
    }

    return filePath;
}

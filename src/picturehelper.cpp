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
#include <QFileInfo>
#include <QByteArray>
#include <QDebug>

#include "extras/formpost.h"

PictureHelper::PictureHelper(QObject *parent) :
    QObject(parent)
{
    manager = new QNetworkAccessManager (this);
    connect(manager,SIGNAL(finished(QNetworkReply*)),SLOT(onFinished(QNetworkReply*)));
}

QVariant PictureHelper::upload(QVariant url, QVariant path, QVariant window, QVariant maxsize)
{
    m_window = window;
    QString filepath = path.toString();
    QFileInfo fileinfo(filepath);
    if (fileinfo.size()/1024 > maxsize.toInt()) {
        //Scale image to fit maxsize
        QImage pic(filepath);
        int width = pic.width() * maxsize.toInt() * 1.5 / (fileinfo.size()/1024.) ;
        filepath += ".scaled." + fileinfo.suffix();
        QImage scpic = pic.scaledToWidth(width);
        scpic.save(filepath);
    }

    QString mime = "image/jpeg";
    if (fileinfo.suffix() == "png") {
        mime = "image/png";
    };
    FormPost *formPost = new FormPost("nelisquare");
    formPost->setFile("photo", filepath, mime);
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

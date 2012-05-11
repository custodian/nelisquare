#ifndef QMLPICTUREUPLOADER_H
#define QMLPICTUREUPLOADER_H

#include <QObject>
#include <QVariant>
#include <QtNetwork/QNetworkAccessManager>

class PictureHelper : public QObject
{
    Q_OBJECT
protected:
    QNetworkAccessManager * manager;

public:
    explicit PictureHelper(QObject *parent = 0);
    
    Q_INVOKABLE QVariant upload(QVariant url, QVariant path);

signals:
    void pictureUploaded(QVariant result);

public slots:
    
private slots:
    void onFinished(QNetworkReply * reply);
};

#endif // QMLPICTUREUPLOADER_H

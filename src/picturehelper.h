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
    QVariant m_window;

public:
    explicit PictureHelper(QObject *parent = 0);
    
    Q_INVOKABLE QVariant upload(QVariant url, QVariant path, QVariant window);

signals:
    void pictureUploaded(QVariant result, QVariant page);

public slots:
    
private slots:
    void onFinished(QNetworkReply * reply);
};

#endif // QMLPICTUREUPLOADER_H

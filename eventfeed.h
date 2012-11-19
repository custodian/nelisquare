#ifndef EVENTFEED_H
#define EVENTFEED_H

#include <QObject>
#include <QString>
#include <QVariant>
#include <QMap>

class EventFeed : public QObject
{
    Q_OBJECT
protected:

public:
    explicit EventFeed(QObject *parent = 0);
    
    //Q_INVOKABLE QVariant addToFeed(QVariant url);

signals:

public slots:
    
private slots:
    //void onDownloadFinished(QNetworkReply *);
};

#endif // EVENTFEED_H

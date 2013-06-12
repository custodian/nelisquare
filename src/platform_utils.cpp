#include "platform_utils.h"

#include <QStringList>
#include <QString>
#include <QUrl>
#include <QMap>
#include <QDateTime>
#include <QDebug>

#include "cache.h"

#if defined(Q_OS_HARMATTAN) || defined(Q_OS_MAEMO)
#include <QtDBus/QDBusConnection>
#include <QtDBus/QDBusInterface>
#include <QtDBus/QDBusConnectionInterface>
#include <QtDBus/QDBusReply>
#if defined(Q_OS_HARMATTAN)
#include <MNotification>
#include <MRemoteAction>
#include <meventfeed.h>
//#else
//#include <libnotify/notify.h>
//#include <libnotifymm/init.h>
//#include <libnotifymm/notification.h>
#endif
#endif

PlatformUtils::PlatformUtils(QObject *parent, Cache *cache) :
    QObject(parent),m_cache(cache)
{
    clearFeed();
}

void PlatformUtils::addNotification(const QString &eventType, const QString &summary, const QString &body,
                                         const int count)
{
#if defined(Q_OS_HARMATTAN)
    //nelisquare.notification - >notification
    QString identifier = eventType.mid(11);

    MNotification notification(eventType, summary, body);
    notification.setCount(count);
    notification.setIdentifier(identifier);
    QList<QVariant> args;
    args.append(QVariant("summary"));
    MRemoteAction action("com.nelisquare", "/com/nelisquare", "com.nelisquare", "notification", args);
    notification.setAction(action);
    notification.publish();
#elif defined(Q_OS_MAEMO)
    Q_UNUSED(eventType);
    Q_UNUSED(summary);
    Q_UNUSED(body);
    Q_UNUSED(count);
#else
    Q_UNUSED(eventType);
    Q_UNUSED(summary);
    Q_UNUSED(body);
    Q_UNUSED(count);
#endif
}

void PlatformUtils::removeNotification(const QString &eventType)
{
#if defined(Q_OS_HARMATTAN)
    QList<MNotification*> activeNotifications = MNotification::notifications();
    QMutableListIterator<MNotification*> i(activeNotifications);
    while(i.hasNext()){
        MNotification* notification = i.next();
        if(notification->eventType() == eventType)
            notification->remove();
    }
#else
    Q_UNUSED(eventType);
#endif
}

void PlatformUtils::clearFeed()
{
#if defined(Q_OS_HARMATTAN)
    MEventFeed::instance()->removeItemsBySourceName(QString("nelisquare"));
#endif
}

void PlatformUtils::addFeedItem(QVariant item)
{
    QMap<QString, QVariant> content = item.toMap();
    QMap<QString, QVariant> params = content["content"].toMap();

    QStringList imagesList;
    if (params["venuePhotoCached"].toString().size()>0) {
        QVariant photo = params["venuePhotoCached"];
        imagesList.append(photo.toString());
    }
    QString eventid;
    QString eventtype;
    QUrl callback;
    eventtype = content["type"].toString();
    eventid = params["id"].toString();

    callback = QUrl(QString("nelisquare://%1/%2").arg(eventtype).arg(eventid));

    QVariant icon = params["photoCached"];

    //TODO: Format eventTitle, eventText by eventtype; (as Feed Elements)
    QString eventTitle;
    QString eventText;

    eventTitle = params["userName"].toString();
    QString eventTitle2 = params["venueName"].toString();
    if (eventTitle2.length()>0) {
        eventTitle += (" @ " + eventTitle2);
    }
    eventText = QString(params["shout"].toString());

    QString statusText;
    int count;
    count = params["commentsCount"].toInt();
    if (count) {
        statusText += QString("comments: %1").arg(count);
    }
    count = params["likesCount"].toInt();
    if (count) {
        if (statusText.size()) statusText += " | ";
        statusText += QString("likes: %1").arg(count);
    }
    count = params["photosCount"].toInt();
    if (count) {
        if (statusText.size()) statusText += " | ";
        statusText += QString("photos: %1").arg(count);
    }
    qlonglong feedid = -1;
#if defined(Q_OS_HARMATTAN)
    feedid = MEventFeed::instance()->addItem(icon.toString(),
        eventTitle,
        eventText,
        imagesList,
        QDateTime::fromTime_t(params["timestamp"].toLongLong()),
        statusText,
        false,
        callback,
        QString("nelisquare"),
        QString("Nelisquare"));
#elif defined(Q_OS_MAEMO)
    /*
    //TODO: maemo bug at add toEvent
    QDBusMessage m = QDBusMessage::createMethodCall("com.maemo.eventFeed",
                                                  "/",
                                                  "com.maemo.eventFeed",
                                                  "addEvent");
    QList<QVariant> args;
    args.append("nelisquare");
    args.append("Nelisquare");
    args.append(icon);
    args.append(QString(params["user"].toString() + " @ " + params["venueName"].toString()));
    args.append(params["shout"]);
    args.append(imagesList);
    args.append(statusText);
    QDateTime time = QDateTime::fromTime_t(params["timestamp"].toLongLong());
    args.append(time.toMSecsSinceEpoch());
    args.append("");
    m.setArguments(args);
    //m.ReplyMessage()

    QDBusMessage reply = QDBusConnection::sessionBus().call(m);
    qDebug() << "reply" << reply;
    //feedid=reply.arguments().at(0).toLongLong();
    */
    feedid = 0;
#endif
    if (feedid == -1) {
        //qDebug() << "Error adding to feed:" << eventtype << "id" << eventid << item;
    } else {
        m_items[eventid] = feedid;
    }
}

void PlatformUtils::updateFeedItem(QVariant item)
{
    removeFeedItem(item);
    addFeedItem(item);
}

void PlatformUtils::removeFeedItem(QVariant item)
{
    QMap<QString, QVariant> content = item.toMap();
    QMap<QString, QVariant> params = content["content"].toMap();
    QString eventid;
    eventid = params["id"].toString();
    QMap<QString,qlonglong>::iterator it = m_items.find(eventid);
    if (it!=m_items.end()) {
        //BUG: not working
        //MEventFeed::instance()->removeItem(it.value());
        //using DBus instead
#if defined(Q_OS_HARMATTAN)
        QDBusMessage m = QDBusMessage::createMethodCall("com.nokia.home.EventFeed",
                                                      "/eventfeed",
                                                      "com.nokia.home.EventFeed",
                                                      "removeItem");
        QList<QVariant> args;
        args.append(it.value());
        m.setArguments(args);
        QDBusConnection::sessionBus().send(m);
#elif defined(Q_OS_MAEMO)
        ;
#else
        ;
#endif

        m_items.erase(it);
    }
}

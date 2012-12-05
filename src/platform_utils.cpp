#include "platform_utils.h"

#include <QString>
#include <QMap>
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
#ifdef Q_OS_HARMATTAN
    MEventFeed::instance()->removeItemsBySourceName("nelisquare");
#endif
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

void PlatformUtils::addFeedItem(QVariant item)
{
#if defined(Q_OS_HARMATTAN)
    QMap<QString, QVariant> params = item.toMap();
    QStringList imagesList;
    if (params["venuePhoto"].toString().size()>0) {
        QVariant photo = m_cache->get(params["venuePhoto"]);
        if (photo.toString().indexOf("http")==-1)
            imagesList.append(photo.toString());
    }
    QString eventid;
    QUrl callback;
    if (params["id"].toString().size()>0) {
        eventid = params["id"].toString();
        callback = QUrl(QString("nelisquare://checkin/%1").arg(eventid));
    } else {
        eventid = params["userID"].toString();
        callback = QUrl(QString("nelisquare://user/%1").arg(eventid));
    }
    QVariant icon = m_cache->get(params["photo"]);//QString("icon-m-service-nelisquare-notification"),
    if (icon.toString().indexOf("http")!=-1)
        icon = "icon-m-service-nelisquare-notification";
    int count;
    QString statusText;
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
    qlonglong feedid = MEventFeed::instance()->addItem(icon.toString(),
        QString(params["user"].toString() + " @ " + params["venueName"].toString()), //title
        QString(params["shout"].toString()),
        imagesList,
        QDateTime::fromTime_t(params["timestamp"].toLongLong()),
        statusText,
        false,
        callback,
        QString("nelisquare"),
        QString("Nelisquare"));
    m_items[eventid] = feedid;
#else
    Q_UNUSED(item)
#endif
}

void PlatformUtils::updateFeedItem(QVariant item)
{
    removeFeedItem(item);
    addFeedItem(item);
}

void PlatformUtils::removeFeedItem(QVariant item)
{
#if defined(Q_OS_HARMATTAN)
    QMap<QString, QVariant> params = item.toMap();
    QString eventid;
    if (params["id"].toString().size()>0) {
        eventid = params["id"].toString();
    } else {
        eventid = params["userID"].toString();
    }
    QMap<QString,qlonglong>::iterator it = m_items.find(eventid);
    if (it!=m_items.end()) {
        //BUG: not working
        //MEventFeed::instance()->removeItem(it.value());
        //using DBus instead
        QDBusMessage m = QDBusMessage::createMethodCall("com.nokia.home.EventFeed",
                                                      "/eventfeed",
                                                      "com.nokia.home.EventFeed",
                                                      "removeItem");
        QList<QVariant> args;
        args.append(it.value());
        m.setArguments(args);
        QDBusConnection::sessionBus().send(m);
        m_items.erase(it);
    }
#else
    Q_UNUSED(item)
#endif
}

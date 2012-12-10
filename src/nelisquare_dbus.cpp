#include "nelisquare_dbus.h"

#include <QtGui/QApplication>
#include <QtDeclarative/QDeclarativeView>
#include <QtDeclarative/QDeclarativeItem>
#include <QtDBus/QDBusConnection>
#include <QDebug>

NelisquareDbus::NelisquareDbus(QApplication *parent, QDeclarativeView *view) :
    QDBusAbstractAdaptor(parent), m_view(view)
{
    QDBusConnection bus = QDBusConnection::sessionBus();
    bus.registerService("com.nelisquare");
    bus.registerObject("/com/nelisquare", parent);

    QObject *rootObject = qobject_cast<QObject*>(view->rootObject());
    rootObject->connect(this,SIGNAL(processUINotification(QVariant)),SLOT(processUINotification(QVariant)));
    rootObject->connect(this,SIGNAL(processURI(QVariant)),SLOT(processURI(QVariant)));
}

void NelisquareDbus::loadURI(const QStringList &url)
{
    m_view->activateWindow();
    if (url.size()) {
        QString param = url.at(0);
        emit processURI(QVariant(param.replace("nelisquare://","")));
    }
}

void NelisquareDbus::notification(QString identificator)
{
    m_view->activateWindow();
    emit processUINotification(QVariant(identificator));
}

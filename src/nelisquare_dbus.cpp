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
#if defined(Q_OS_HARMATTAN)
    bus.registerObject("/com/nelisquare", parent);
#elif defined(Q_OS_MAEMO)
    bus.registerObject("/com/nelisquare", this, QDBusConnection::ExportScriptableSlots);
#endif


    QObject *rootObject = qobject_cast<QObject*>(view->rootObject());
    rootObject->connect(this,SIGNAL(processUINotification(QVariant)),SLOT(processUINotification(QVariant)));
    rootObject->connect(this,SIGNAL(processURI(QVariant)),SLOT(processURI(QVariant)));
}

void NelisquareDbus::top_application() {
    m_view->show();
    m_view->activateWindow();
}

void NelisquareDbus::loadURI(const QStringList &url)
{
    top_application();
    if (url.size()) {
        QString param = url.at(0);
        emit processURI(QVariant(param.replace("nelisquare://","")));
    }
}

void NelisquareDbus::notification(QString identificator)
{
    top_application();
    emit processUINotification(QVariant(identificator));
}

#include <QtGui/QApplication>
#include <QtDeclarative>
#include <QDeclarativeContext>
#include <QDeclarativeEngine>
#include <QGraphicsObject>
#include <QInputContext>
#include <QSplashScreen>
#include "qmlapplicationviewer.h"
#include "picturehelper.h"
#include "windowhelper.h"
#include "cache.h"
#include "molome.h"
#include "apptranslator.h"
#include "httpuploader.h"
#include "debuglogger.h"

#include <qplatformdefs.h>

#if defined(Q_OS_HARMATTAN) || defined(Q_WS_SIMULATOR) || defined(Q_OS_MAEMO)
#include "platform_utils.h"
#endif

#if defined(Q_OS_HARMATTAN) || defined(Q_OS_MAEMO)
#include "nelisquare_dbus.h"
#endif

#if defined(Q_OS_HARMATTAN)
#include <MDeclarativeCache>
#endif

class EventDisabler : public QObject
{
protected:
    bool eventFilter(QObject *, QEvent *) {
        return true;
    }
private:
    QWidget *prevFocusWidget;
};

class EventFilter : public QObject
{
protected:
    bool eventFilter(QObject *obj, QEvent *event) {
        QInputContext *ic = qApp->inputContext();
        if (ic) {
            if (ic->focusWidget() == 0 && prevFocusWidget) {
                QEvent closeSIPEvent(QEvent::CloseSoftwareInputPanel);
                ic->filterEvent(&closeSIPEvent);
            } else if (prevFocusWidget == 0 && ic->focusWidget()) {
                QEvent openSIPEvent(QEvent::RequestSoftwareInputPanel);
                ic->filterEvent(&openSIPEvent);
            }
            prevFocusWidget = ic->focusWidget();
        }
        return QObject::eventFilter(obj,event);
    }

private:
    QWidget *prevFocusWidget;
};

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    DebugLogger::installLogger();

#if defined(Q_WS_SIMULATOR)
    QSslConfiguration config = QSslConfiguration::defaultConfiguration();
    config.setProtocol(QSsl::SslV3);
    QSslConfiguration::setDefaultConfiguration(config);
#endif

    QApplication *app = createApplication(argc, argv);

    AppTranslator *appTranslator = new AppTranslator(app);

    //Enable before stable release, after remastering settings
    //Also check if app hangs on new install without database
    app->setApplicationName("Nelisquare");
    app->setOrganizationName("net.thecust");

    QmlApplicationViewer viewer;

#if defined(Q_OS_MAEMO)
    QPixmap pixmap("/opt/nelisquare/qml/pics/splash-turned.png");
    QSplashScreen splash(pixmap);
    EventDisabler eventDisabler;
    splash.installEventFilter(&eventDisabler);
    splash.showFullScreen();
#endif

#if defined(Q_OS_MAEMO)
    viewer.addImportPath(QString("/opt/qtm12/imports"));
    viewer.engine()->addImportPath(QString("/opt/qtm12/imports"));
    viewer.engine()->addPluginPath(QString("/opt/qtm12/plugins"));
#endif

#if defined(Q_WS_SIMULATOR)
    viewer.engine()->addImportPath(QString("aui/harmattan"));
    viewer.engine()->addImportPath(QString("c:/source/nelisquare/nelisquare/aui/harmattan"));

#elif defined(Q_OS_HARMATTAN) || defined(Q_OS_MAEMO)
    viewer.engine()->addImportPath(QString("/opt/nelisquare/qml/aui"));
#endif

    QCoreApplication::addLibraryPath(QString("/opt/nelisquare/plugins"));

    qmlRegisterType<DebugLogger>("net.thecust.utils", 1, 0, "DebugLogger");
    qmlRegisterType<Molome>("net.thecust.utils", 1, 0, "MoloMe");
    qmlRegisterType<PictureHelper>("net.thecust.utils", 1, 0, "PictureHelper");

    qmlRegisterUncreatableType<HttpPostField>("HttpUp", 1, 0, "HttpPostField", "Can't touch this");
    qmlRegisterType<HttpPostFieldValue>("HttpUp", 1, 0, "HttpPostFieldValue");
    qmlRegisterType<HttpPostFieldFile>("HttpUp", 1, 0, "HttpPostFieldFile");
    qmlRegisterType<HttpUploader>("HttpUp", 1, 0, "HttpUploader");

    viewer.setAttribute(Qt::WA_OpaquePaintEvent);
    viewer.setAttribute(Qt::WA_NoSystemBackground);
    viewer.viewport()->setAttribute(Qt::WA_OpaquePaintEvent);
    viewer.viewport()->setAttribute(Qt::WA_NoSystemBackground);

    WindowHelper *windowHelper = new WindowHelper(&viewer);
    Cache *cache = new Cache();
    viewer.rootContext()->setContextProperty("windowHelper", windowHelper);
    viewer.rootContext()->setContextProperty("cache", cache);
    viewer.rootContext()->setContextProperty("translator", appTranslator);

#if defined(Q_OS_HARMATTAN) || defined(Q_WS_SIMULATOR) || defined(Q_OS_MAEMO)
    //TODO: mo to qmlRegisterType
    PlatformUtils platformUtils(app,cache);
    viewer.rootContext()->setContextProperty("platformUtils", &platformUtils);
#endif

#if defined(Q_OS_MAEMO) || defined(Q_OS_HARMATTAN)
    viewer.installEventFilter(windowHelper);
#endif

    viewer.setMainQmlFile(QLatin1String("qml/main.qml"));
    /*
    QObject *rootObject = qobject_cast<QObject*>(viewer.rootObject());
    rootObject->connect(cache,SIGNAL(cacheUpdated(QVariant,QVariant,QVariant)),SLOT(onCacheUpdated(QVariant,QVariant,QVariant)));
    */

#if defined(Q_OS_HARMATTAN) || defined(Q_OS_MAEMO)
    //TODO: move to qmlRegisterType
    new NelisquareDbus(app, &viewer);
#endif

#if defined(Q_OS_MAEMO)
    viewer.showFullScreen();
#elif defined(Q_OS_HARMATTAN)
    viewer.showExpanded();
#else
    viewer.showExpanded();
#endif

#if defined(Q_OS_MAEMO)
    splash.finish(&viewer);
#endif

    return app->exec();
}

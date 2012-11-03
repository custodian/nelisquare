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

#include <qplatformdefs.h>

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
#ifdef Q_OS_SYMBIAN
    QApplication::setGraphicsSystem(QLatin1String("openvg"));
#elif defined(Q_WS_MAEMO_5) || defined(Q_WS_MAEMO_6) || defined(MEEGO_EDITION_HARMATTAN)
    QApplication::setGraphicsSystem(QLatin1String("opengl"));
#endif

    QApplication app(argc, argv);

#if defined(VS_ENABLE_SPLASH) && defined(Q_WS_MAEMO_5)
    QPixmap pixmap("/opt/nelisquare/qml/resources/pics/splash-turned.png");
    QSplashScreen splash(pixmap);
    EventDisabler eventDisabler;
    splash.installEventFilter(&eventDisabler);
    //Qt::WidgetAttribute attribute;
    //attribute = Qt::WA_LockPortraitOrientation;
    //splash.setAttribute(attribute, true);
    splash.showFullScreen();
    //splash.showMessage("Initializating...",Qt::AlignHCenter|Qt::AlignVCenter, Qt::white);
    //app.processEvents();
#endif

    QmlApplicationViewer viewer;
#if defined(Q_WS_MAEMO_5) || defined(Q_WS_MAEMO_6)
    viewer.addImportPath(QString("/opt/qtm12/imports"));
    viewer.engine()->addPluginPath(QString("/opt/qtm12/plugins"));
#endif

    viewer.setAttribute(Qt::WA_OpaquePaintEvent);
    viewer.setAttribute(Qt::WA_NoSystemBackground);
    viewer.viewport()->setAttribute(Qt::WA_OpaquePaintEvent);
    viewer.viewport()->setAttribute(Qt::WA_NoSystemBackground);

    /*
    qmlRegisterType<QGraphicsBlurEffect>("Effects",1,0,"Blur");
    qmlRegisterType<QGraphicsColorizeEffect>("Effects",1,0,"Colorize");
    qmlRegisterType<QGraphicsDropShadowEffect>("Effects",1,0,"DropShadow");
    qmlRegisterType<QGraphicsOpacityEffect>("Effects",1,0,"OpacityEffect");
    */

    WindowHelper *windowHelper = new WindowHelper(&viewer);
    PictureHelper *pictureHelper = new PictureHelper();
    Cache *cache = new Cache();
    Molome *molome = new Molome();
    viewer.rootContext()->setContextProperty("windowHelper", windowHelper);
    viewer.rootContext()->setContextProperty("pictureHelper", pictureHelper);
    viewer.rootContext()->setContextProperty("cache", cache);
    viewer.rootContext()->setContextProperty("molome", molome);
    viewer.setOrientation(QmlApplicationViewer::ScreenOrientationAuto);

#if defined(VS_ENABLE_SPLASH) && defined(Q_WS_MAEMO_5)
    //splash.showMessage("Loading...",Qt::AlignHCenter|Qt::AlignVCenter, Qt::white);
    //app.processEvents();
#endif

#if defined(Q_WS_MAEMO_5) || defined(Q_WS_MAEMO_6)
    viewer.setMainQmlFile(QLatin1String("qml/resources/Maemo.qml"));
#elif defined(MEEGO_EDITION_HARMATTAN)
    viewer.setMainQmlFile(QLatin1String("qml/resources/Meego.qml"));
#else
    viewer.setMainQmlFile(QLatin1String("qml/resources/Meego.qml"));
#endif

#if defined(Q_WS_MAEMO_5) || defined(Q_WS_MAEMO_6)
    viewer.installEventFilter(windowHelper);
#elif defined(MEEGO_EDITION_HARMATTAN)
    EventFilter ef;
    viewer.installEventFilter(&ef);
#endif

    QObject *rootObject = qobject_cast<QObject*>(viewer.rootObject());
    rootObject->connect(pictureHelper,SIGNAL(pictureUploaded(QVariant, QVariant)),SLOT(onPictureUploaded(QVariant, QVariant)));
    rootObject->connect(molome,SIGNAL(infoUpdated(QVariant,QVariant)),SLOT(onMolomeInfoUpdate(QVariant,QVariant)));
    rootObject->connect(molome,SIGNAL(photoRecieved(QVariant,QVariant)),SLOT(onMolomePhoto(QVariant,QVariant)));
#if defined(Q_WS_MAEMO_5) || defined(Q_WS_MAEMO_6)
    rootObject->connect(windowHelper,SIGNAL(visibilityChanged(QVariant)), SLOT(onVisibililityChange(QVariant)));
    viewer.showFullScreen();
#elif defined(MEEGO_EDITION_HARMATTAN)
    rootObject->connect(windowHelper,SIGNAL(lockOrientation(QVariant)),SLOT(onLockOrientation(QVariant)));
    viewer.showExpanded();
#else
    viewer.showExpanded();
#endif
#if defined(VS_ENABLE_SPLASH) && defined(Q_WS_MAEMO_5)
    splash.finish(&viewer);
#endif

    return app.exec();
}

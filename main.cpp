#include <QtGui/QApplication>
#include <QDeclarativeContext>
#include <QDeclarativeEngine>
#include <QGraphicsObject>
#include "qmlapplicationviewer.h"
#include "picturehelper.h"
#include "windowhelper.h"
#include <QInputContext>

#include <qplatformdefs.h>

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

    QmlApplicationViewer viewer;
#if defined(Q_WS_MAEMO_5) || defined(Q_WS_MAEMO_6)
    viewer.addImportPath(QString("/opt/qtm11/imports"));
#endif

    WindowHelper *windowHelper = new WindowHelper(&viewer);
    PictureHelper *pictureHelper = new PictureHelper();
    viewer.rootContext()->setContextProperty("windowHelper", windowHelper);
    viewer.rootContext()->setContextProperty("pictureHelper", pictureHelper);
    viewer.setOrientation(QmlApplicationViewer::ScreenOrientationAuto);

#if defined(Q_WS_MAEMO_5) || defined(Q_WS_MAEMO_6)
    viewer.setMainQmlFile(QLatin1String("qml/resources/Maemo.qml"));
#elif defined(MEEGO_EDITION_HARMATTAN)
    viewer.setMainQmlFile(QLatin1String("qml/resources/Meego.qml"));
#else
    viewer.setMainQmlFile(QLatin1String("qml/resources/Maemo.qml"));
#endif

#if defined(Q_WS_MAEMO_5) || defined(Q_WS_MAEMO_6)
    viewer.installEventFilter(windowHelper);
#elif defined(MEEGO_EDITION_HARMATTAN)
    EventFilter ef;
    viewer.installEventFilter(&ef);
#endif

    QObject *rootObject = qobject_cast<QObject*>(viewer.rootObject());
    rootObject->connect(pictureHelper,SIGNAL(pictureUploaded(QVariant)),SLOT(onPictureUploaded(QVariant)));
#if defined(Q_WS_MAEMO_5) || defined(Q_WS_MAEMO_6)
    rootObject->connect(windowHelper,SIGNAL(visibilityChanged(QVariant)), SLOT(onVisibililityChange(QVariant)));
    viewer.showFullScreen();
#elif defined(MEEGO_EDITION_HARMATTAN)
    rootObject->connect(windowHelper,SIGNAL(lockOrientation(QVariant)),SLOT(onLockOrientation(QVariant)));
    viewer.showExpanded();
#else
    viewer.showExpanded();
#endif

    return app.exec();

}

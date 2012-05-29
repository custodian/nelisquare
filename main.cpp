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

int main(int argc, char *argv[])
{
#ifdef Q_OS_SYMBIAN
    QApplication::setGraphicsSystem(QLatin1String("openvg"));
#elif defined(Q_WS_MAEMO_5) || defined(Q_WS_MAEMO_6) || defined(MEEGO_EDITION_HARMATTAN)
    QApplication::setGraphicsSystem(QLatin1String("opengl"));
#endif

    QApplication app(argc, argv);
    //app.setProperty("NoMStyle", true);

    QmlApplicationViewer viewer;
#if defined(Q_WS_MAEMO_5) || defined(Q_WS_MAEMO_6)
    viewer.addImportPath(QString("/opt/qtm11/imports"));
    //viewer.engine()->addPluginPath(QString("/opt/qtm11/plugins"));
#endif
    WindowHelper *windowHelper = new WindowHelper(&viewer);
    PictureHelper *pictureHelper = new PictureHelper();
    viewer.rootContext()->setContextProperty("windowHelper", windowHelper);
    viewer.rootContext()->setContextProperty("pictureHelper", pictureHelper);
    viewer.setOrientation(QmlApplicationViewer::ScreenOrientationAuto);
#if defined(Q_WS_MAEMO_5) || defined(Q_WS_MAEMO_6)
    viewer.setMainQmlFile(QLatin1String("qml/Nelisquare/MainWindow.qml"));
#elif defined(MEEGO_EDITION_HARMATTAN)
    viewer.setMainQmlFile(QLatin1String("qml/Nelisquare/Meego.qml"));
#else
    viewer.setMainQmlFile(QLatin1String("qml/Nelisquare/MainWindow.qml"));
#endif

    EventFilter ef;
    viewer.installEventFilter(&ef);

    QObject *rootObject = qobject_cast<QObject*>(viewer.rootObject());
    rootObject->connect(pictureHelper,SIGNAL(pictureUploaded(QVariant)),SLOT(onPictureUploaded(QVariant)));
#if defined(MEEGO_EDITION_HARMATTAN)
    rootObject->connect(windowHelper,SIGNAL(lockOrientation(QVariant)),SLOT(onLockOrientation(QVariant)));
#endif

    viewer.showExpanded();

    return app.exec();

}

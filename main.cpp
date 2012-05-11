#include <QtGui/QApplication>
#include <QDeclarativeContext>
#include <QDeclarativeEngine>
#include <QGraphicsObject>
#include "qmlapplicationviewer.h"
#include "picturehelper.h"
#include "windowhelper.h"

int main(int argc, char *argv[])
{
#ifdef Q_OS_SYMBIAN
    QApplication::setGraphicsSystem(QLatin1String("openvg"));
#elif defined(Q_WS_MAEMO_5) || defined(Q_WS_MAEMO_6)
    QApplication::setGraphicsSystem(QLatin1String("opengl"));
#endif

    QApplication app(argc, argv);
    //app.setProperty("NoMStyle", true);

    QmlApplicationViewer viewer;
#if defined(Q_WS_MAEMO_5) || defined(Q_WS_MAEMO_6)
    viewer.addImportPath(QString("/opt/qtm11/imports"));
    //viewer.engine()->addPluginPath(QString("/opt/qtm11/plugins"));
#endif
    WindowHelper *windowHelper = new WindowHelper();
    PictureHelper *pictureHelper = new PictureHelper();
    viewer.rootContext()->setContextProperty("windowHelper", windowHelper);
    viewer.rootContext()->setContextProperty("pictureHelper", pictureHelper);
    viewer.setOrientation(QmlApplicationViewer::ScreenOrientationAuto);
    viewer.setMainQmlFile(QLatin1String("qml/Nelisquare/main.qml"));
    viewer.installEventFilter(windowHelper);

    QObject *rootObject = qobject_cast<QObject*>(viewer.rootObject());
    rootObject->connect(windowHelper,SIGNAL(visibilityChanged(QVariant)), SLOT(onVisibililityChange(QVariant)));
    rootObject->connect(pictureHelper,SIGNAL(pictureUploaded(QVariant)),SLOT(onPictureUploaded(QVariant)));

    viewer.showFullScreen();

    return app.exec();
}

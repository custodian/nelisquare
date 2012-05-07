#include <QtGui/QApplication>
#include <QDeclarativeContext>
#include <QDeclarativeEngine>
#include "qmlapplicationviewer.h"
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
    viewer.rootContext()->setContextProperty("windowHelper", windowHelper);
    viewer.setOrientation(QmlApplicationViewer::ScreenOrientationAuto);
    viewer.setMainQmlFile(QLatin1String("qml/Nelisquare/main.qml"));
    viewer.showFullScreen();

    return app.exec();
}

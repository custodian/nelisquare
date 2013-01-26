#ifndef NELISQUAREDBUS_H
#define NELISQUAREDBUS_H

#include <QtDBus/QDBusAbstractAdaptor>

class QApplication;
class QDeclarativeView;

class NelisquareDbus : public QDBusAbstractAdaptor
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "com.nelisquare")
public:
    explicit NelisquareDbus(QApplication *parent, QDeclarativeView *view);

public slots:
    void notification(QString identificator);
    void loadURI(const QStringList &url);
    Q_SCRIPTABLE void top_application();

signals:
    void processUINotification(QVariant id);
    void processURI(QVariant url);

private:
    QDeclarativeView *m_view;
};

#endif // NELISQUAREDBUS_H

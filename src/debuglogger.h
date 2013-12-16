#ifndef DEBUGLOGGER_H
#define DEBUGLOGGER_H

#include <QObject>
#include <QVariant>

class DebugLoggerInternal: public QObject
{
    Q_OBJECT
private:
    static DebugLoggerInternal *m_instance;
    QVariantList m_data;

public:
    explicit DebugLoggerInternal(QObject *parent = 0);
    static void messageOutput(QtMsgType type, const char *msg);
    static DebugLoggerInternal *getInstance();

    QVariant getData();

signals:
    void dataLogged(QString msg);
public slots:
    void appendData(QString msg);
};

class DebugLogger : public QObject
{
    Q_OBJECT
public:
    explicit DebugLogger(QObject *parent = 0);
    static void installLogger();
    
signals:
    void dataLogged(QString msg);
    
public slots:
    QVariant getData();
    void dataRecieved(QString msg);
    void initLogger();

};

#endif // DEBUGLOGGER_H

#include <QString>
#include <QDateTime>
#include <QVariant>

#include <stdlib.h>
#include <iostream>

#include "debuglogger.h"

DebugLoggerInternal *DebugLoggerInternal::m_instance = NULL;

DebugLoggerInternal::DebugLoggerInternal(QObject *parent) :
    QObject(parent)
{
#ifndef Q_WS_SIMULATOR
    qInstallMsgHandler(DebugLoggerInternal::messageOutput);
#endif
    connect(this,SIGNAL(dataLogged(QString)),SLOT(appendData(QString)));
}

DebugLoggerInternal * DebugLoggerInternal::getInstance()
{
    if (m_instance == NULL) {
        m_instance = new DebugLoggerInternal();
    }
    return m_instance;
}

void DebugLoggerInternal::messageOutput(QtMsgType type, const char *msg)
{
    QString msgtype;
    switch (type) {
    case QtDebugMsg:
        msgtype = "DBG";
        break;
    case QtWarningMsg:
        msgtype = "WRN";
        break;
    case QtCriticalMsg:
        msgtype = "CRT";
        break;
    case QtFatalMsg:
        msgtype = "FTL";
    }
    QString msgtime = QDateTime::currentDateTimeUtc().toString("hh:mm:ss.zzz");
    QString message = QString("%1 [%2] %3").arg(msgtype).arg(msgtime).arg(msg);
    std::cerr << message.toLocal8Bit().data() << std::endl;
    emit m_instance->dataLogged(message);
    if (type == QtFatalMsg) {
        abort();
    }
}
QVariant DebugLoggerInternal::getData() {
    return m_data;
}

void DebugLoggerInternal::appendData(QString msg) {
    m_data.push_back(msg);
    if (m_data.size()>100) {
        m_data.pop_front();
    }
}

DebugLogger::DebugLogger(QObject *parent) :
    QObject(parent)
{
    initLogger();
}

void DebugLogger::initLogger() {
    DebugLoggerInternal *instance = DebugLoggerInternal::getInstance();
    connect(instance,SIGNAL(dataLogged(QString)),SLOT(dataRecieved(QString)));
}

void DebugLogger::installLogger() {
    DebugLoggerInternal::getInstance();
}

QVariant DebugLogger::getData() {
    return DebugLoggerInternal::getInstance()->getData();
}

void DebugLogger::dataRecieved(QString msg) {
    emit dataLogged(msg);
}



#ifndef WINDOWHELPER_H
#define WINDOWHELPER_H

#include <QObject>

class WindowHelper : public QObject
{
    Q_OBJECT
public:
    explicit WindowHelper(QObject *parent = 0);
    Q_INVOKABLE void minimize();
    Q_INVOKABLE bool isMaemo();

signals:

public slots:

};

#endif // WINDOWHELPER_H

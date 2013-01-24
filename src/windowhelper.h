#ifndef WINDOWHELPER_H
#define WINDOWHELPER_H

#include <QObject>
#include <QVariant>
#include "qmlapplicationviewer.h"

class WindowHelper : public QObject
{
    Q_OBJECT

private:
    QmlApplicationViewer * m_viewer;
    bool m_swypedisabled;

protected:
    bool eventFilter(QObject *obj, QEvent *event);

public:
    explicit WindowHelper(QmlApplicationViewer *viewer, QObject *parent = 0);

    Q_INVOKABLE void minimize();
    Q_INVOKABLE bool isMaemo();
    Q_INVOKABLE void setOrientation(QVariant orientation);
    Q_INVOKABLE void disableSwype(QVariant disabled);

signals:
    void visibilityChanged(QVariant foregroud);
    //void lockOrientation(QVariant result);
};

#endif // WINDOWHELPER_H

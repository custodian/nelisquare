#ifndef WINDOWHELPER_H
#define WINDOWHELPER_H

#include <QObject>
#include <QVariant>

class WindowHelper : public QObject
{
    Q_OBJECT

protected:
    bool eventFilter(QObject *obj, QEvent *event);

public:
    explicit WindowHelper(QObject *parent = 0);
    Q_INVOKABLE void minimize();
    Q_INVOKABLE bool isMaemo();

signals:
    void visibilityChanged(QVariant foregroud);

public slots:

};

#endif // WINDOWHELPER_H

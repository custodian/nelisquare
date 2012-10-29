#ifndef QMLMOLOME_H
#define QMLMOLOME_H

#include <QObject>
#include <QString>
#include <QVariant>
#include <QProcess>

class Molome : public QObject
{
    Q_OBJECT
protected:
    QProcess m_molo;

    bool m_present;
    bool m_installed;
    QString m_molome_target;
    QString m_molome_base;
    QString m_molome_bin;

    QString m_lastphoto;

    void copyFolder(QString sourceFolder, QString destFolder);
    void removeFolder(QString sourceFolder);

    void molome_install();
    void molome_uninstall();

    QString getlastphoto();

public:
    explicit Molome(QObject *parent = 0);
    
    Q_INVOKABLE void updateinfo();

    Q_INVOKABLE QVariant install();

    Q_INVOKABLE QVariant uninstall();

    Q_INVOKABLE QVariant getphoto();

signals:
    void infoUpdated(QVariant present, QVariant installed);
    void photoRecieved(QVariant status, QVariant photopath);

public slots:
    
private slots:
    void moloFinished(int);

};

#endif // QMLMOLOME_H

#include "molome.h"
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QByteArray>
#include <QDesktopServices>
#include <QString>
#include <QDebug>
#include <QProcess>
#include <QtConcurrentRun>

Molome::Molome(QObject *parent) :
    QObject(parent)
{
    m_present = false;
    m_installed = false;

    m_molome_base = "/opt/MOLOME/";
    m_molome_bin = "/bin/MOLOME";

    connect(&m_molo,SIGNAL(finished(int)),SLOT(moloFinished(int)));

    updateinfo();
}

void Molome::updateinfo() {
    if (QFileInfo(m_molome_base + m_molome_bin).exists()) {
        m_present = true;
    } else {
        m_present = false;
    }
    QDesktopServices dirs;
    QString cache = dirs.storageLocation(QDesktopServices::CacheLocation);
    cache += "/nelisquare/molome";
    m_molome_target = cache;
    if (QFileInfo(m_molome_target+m_molome_bin).exists()) {
        m_installed = true;
    } else {
        m_installed = false;
    }
    //qDebug() << "Molome present:" <<  m_present << "installed:" << m_installed;
    emit infoUpdated(QVariant(m_present),QVariant(m_installed));
}

QVariant Molome::install(){
    //qDebug() << "install pressed";
    if (!m_present)
        return QVariant(false);

    QtConcurrent::run(this, &Molome::molome_install);
    return QVariant(true);
}

void Molome::molome_install() {
    copyFolder(m_molome_base,m_molome_target);

    //qDebug() << "Remove"
    //         <<
    QFile::remove(m_molome_target+"/qml/ui/mainM.qml");
    //qDebug() << "mainM.qml"
    //         <<
    QFile::copy("/opt/nelisquare/qml/resources/assets/mainM.qml",
                m_molome_target+"/qml/ui/mainM.qml");

    //qDebug() << "Remove"
    //         <<
    QFile::remove(m_molome_target+"/qml/ui/Screen/FilterSelectionScreen.qml");
    //qDebug() << "FilterSelectionScreen"
    //         <<
    QFile::copy("/opt/nelisquare/qml/resources/assets/FilterSelectionScreen.qml",
                m_molome_target+"/qml/ui/Screen/FilterSelectionScreen.qml");

    //qDebug() << "Remove"
    //         <<
    QFile::remove(m_molome_target+"/qml/ui/Screen/ZoomCropScreen.qml");
    //qDebug() << "ZoomCropScreen.qml"
    //         <<
    QFile::copy("/opt/nelisquare/qml/resources/assets/ZoomCropScreen.qml",
                m_molome_target+"/qml/ui/Screen/ZoomCropScreen.qml");

    //qDebug() << "Remove"
    //         <<
    QFile::remove(m_molome_target+"/qml/ui/Screen/CaptureScreen.qml");
    //qDebug() << "CaptureScreen.qml"
    //         <<
    QFile::copy("/opt/nelisquare/qml/resources/assets/CaptureScreen.qml",
                m_molome_target+"/qml/ui/Screen/CaptureScreen.qml");

    //qDebug() << "Remove"
    //         <<
    QFile::remove(m_molome_target+"/qml/ui/UIComponents/CameraControlNative.qml");
    //qDebug() << "mainM.qml"
    //         <<
    QFile::copy("/opt/nelisquare/qml/resources/assets/CameraControlNative.qml",
                m_molome_target+"/qml/ui/UIComponents/CameraControlNative.qml");

    updateinfo();
}

QVariant Molome::uninstall() {
    QtConcurrent::run(this,&Molome::molome_uninstall);
    return QVariant(true);
}
void Molome::molome_uninstall() {
    removeFolder(m_molome_target);
    updateinfo();
}

QString Molome::getlastphoto() {
    QDir dir(QDir::currentPath()+"/MyDocs/Pictures/MOLOME");
    QString filename;
    dir.setFilter(QDir::Files);
    dir.setSorting(QDir::Time);
    QFileInfoList list = dir.entryInfoList();
    if (list.size())
        filename = list.at(0).absoluteFilePath();
    qDebug() << "last pic filename" << filename;
    return filename;
}

QVariant Molome::getphoto(){
    m_molo.start(m_molome_target+m_molome_bin);
    m_lastphoto = getlastphoto();
    return QVariant(true);
}

void Molome::moloFinished(int) {
    qDebug() << "Molo stdout:";
    qDebug() << m_molo.readAllStandardOutput();
    qDebug() << "Molo stderr:";
    qDebug() << m_molo.readAllStandardError();
    QString lastphoto = getlastphoto();
    if (m_lastphoto != lastphoto) {
        emit photoRecieved(QVariant(true),QVariant(lastphoto));
    } else {
        emit photoRecieved(QVariant(false),QVariant(""));
    }
    m_lastphoto = lastphoto;
}

void Molome::removeFolder(QString sourceFolder) {
    QDir sourceDir(sourceFolder);
    if(!sourceDir.exists())
        return;
    QStringList files = sourceDir.entryList(QDir::AllDirs | QDir::NoDotAndDotDot);
    for(int i = 0; i< files.count(); i++)
    {
        QString srcName = sourceFolder + "/" + files[i];
        removeFolder(srcName);
        qDebug() << "remove dir" << srcName;
    }
    files.clear();
    files = sourceDir.entryList(QDir::Files);
    for(int i = 0; i< files.count(); i++)
    {
        QString srcName = sourceFolder + "/" + files[i];
        QFile::remove(srcName);
        qDebug() << "remove file" << srcName;
    }
    sourceDir.rmdir(sourceFolder);
}

void Molome::copyFolder(QString sourceFolder, QString destFolder)
{
    QDir sourceDir(sourceFolder);
    if(!sourceDir.exists())
        return;

    QDir destDir(destFolder);
    if(!destDir.exists())
    {
        destDir.mkdir(destFolder);
    }
    QStringList files = sourceDir.entryList(QDir::Files);
    for(int i = 0; i< files.count(); i++)
    {
        QString srcName = sourceFolder + "/" + files[i];
        QString destName = destFolder + "/" + files[i];
        QFile::copy(srcName, destName);
        qDebug() << "copy file" << srcName << destName;
    }
    files.clear();
    files = sourceDir.entryList(QDir::AllDirs | QDir::NoDotAndDotDot);
    for(int i = 0; i< files.count(); i++)
    {
        QString srcName = sourceFolder + "/" + files[i];
        QString destName = destFolder + "/" + files[i];
        copyFolder(srcName, destName);
        qDebug() << "copy dir" << srcName << destName;
    }
}

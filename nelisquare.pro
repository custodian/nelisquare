TEMPLATE = app
TARGET = nelisquare

VERSION = 0.4
PACKAGENAME = com.nelisquare

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

symbian {
    TARGET.UID3 = 0xE2C92941
    # Allow network access on Symbian
    TARGET.CAPABILITY += NetworkServices Location LocalServices ReadUserData WriteUserData
}

#!symbian {
#    DEFINES += HAVE_GLWIDGET
#    QT += opengl
#}

QT += network

contains(MEEGO_EDITION,harmattan){
    QT += dbus
    DEFINES += Q_OS_HARMATTAN
    CONFIG += qdeclarative-boostable meegotouch
    # shareuiinterface-maemo-meegotouch share-ui-plugin share-ui-common mdatauri
}
maemo5 {
    DEFINES += Q_OS_MAEMO
}

# If your application uses the Qt Mobility libraries, uncomment
# the following lines and add the respective components to the
# MOBILITY variable.
maemo5 {
  CONFIG += mobility12 qdbus
}
contains(MEEGO_EDITION,harmattan){
  CONFIG += mobility meegotouchevents
  MOBILITY += feedback
}
symbian {
  CONFIG += qt-components
}
MOBILITY += location

DEFINES += QT_USE_FAST_CONCATENATION QT_USE_FAST_OPERATOR_PLUS
DEFINES += VS_ENABLE_SPLASH

win32 {
    # Define QMLJSDEBUGGER to allow debugging of QML in debug builds
    # (This might significantly increase build time)
    QMLJSDEBUGGER_PATH = C:\QtSDK\QtCreator\share\qtcreator\qml\qmljsdebugger
    DEFINES += QMLJSDEBUGGER
}

SOURCES += $$PWD/src/main.cpp \
    $$PWD/src/windowhelper.cpp \
    $$PWD/src/picturehelper.cpp \
    $$PWD/src/cache.cpp \
    $$PWD/src/molome.cpp \
    $$PWD/src/extras/formpost.cpp \
    $$PWD/src/extras/httppostsendbuffer.cpp

HEADERS += \
    $$PWD/src/windowhelper.h \
    $$PWD/src/picturehelper.h \
    $$PWD/src/cache.h \
    $$PWD/src/molome.h \
    $$PWD/src/extras/formpost.h \
    $$PWD/src/extras/httppostsendbuffer.h

maemo5|simulator|contains(MEEGO_EDITION,harmattan){
    HEADERS += $$PWD/src/platform_utils.h
    SOURCES += $$PWD/src/platform_utils.cpp

    !simulator{
        SOURCES += $$PWD/src/nelisquare_dbus.cpp
        HEADERS += $$PWD/src/nelisquare_dbus.h
    }
}

contains(MEEGO_EDITION,harmattan){
    include(plugins/meego/notifications/notifications.pri)
    include(plugins/meego/uri-scheme/uri-scheme.pri)
    #include(plugins/icons/icons.pri)
}
maemo5 {
    #CONFIG += link_pkgconfig
    #PKGCONFIG += libnotifymm-1.0 gtkmm-2.4
    #CONFIG += link_pkgconfig
    #PKGCONFIG += libnotify libnotifymm-1.0 gtkmm-2 hildonmm
}

# Add more folders to ship with the application, here
unix {
    folder_01.source = $$PWD/qml/resources
} else: win32 {
    folder_01.source = qml/resources
}
folder_01.target = qml
DEPLOYMENTFOLDERS = folder_01

#Geoservices providers
unix {
    #maemo5 {
    #    folder_02.source = $$PWD/plugins/maemo/geoservices
    #}
    contains(MEEGO_EDITION,harmattan) {
        folder_02.source = $$PWD/plugins/meego/geoservices
        folder_02.target = plugins
        DEPLOYMENTFOLDERS += folder_02
    }

}

# Please do not modify the following two lines. Required for deployment.
include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()

OTHER_FILES += \
    qtc_packaging/debian_fremantle/rules \
    qtc_packaging/debian_fremantle/README \
    qtc_packaging/debian_fremantle/copyright \
    qtc_packaging/debian_fremantle/control \
    qtc_packaging/debian_fremantle/compat \
    qtc_packaging/debian_fremantle/changelog \
    qtc_packaging/debian_harmattan/rules \
    qtc_packaging/debian_harmattan/README \
    qtc_packaging/debian_harmattan/manifest.aegis \
    qtc_packaging/debian_harmattan/copyright \
    qtc_packaging/debian_harmattan/control \
    qtc_packaging/debian_harmattan/postinst \
    qtc_packaging/debian_harmattan/postrm \
    qtc_packaging/debian_harmattan/prerm \
    qtc_packaging/debian_harmattan/compat \
    qtc_packaging/debian_harmattan/changelog

OTHER_FILES += \
    nelisquare_maemo.desktop \
    nelisquare_meego.desktop

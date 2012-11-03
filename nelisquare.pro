# Add more folders to ship with the application, here
unix {
    folder_01.source = $$PWD/qml/resources
} else: win32 {
    folder_01.source = qml/resources
}
    folder_01.target = qml
    DEPLOYMENTFOLDERS = folder_01


# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

symbian:TARGET.UID3 = 0xE2C92941

# Allow network access on Symbian
symbian:TARGET.CAPABILITY += NetworkServices Location LocalServices ReadUserData WriteUserData

!symbian: {
    DEFINES += HAVE_GLWIDGET
    QT += opengl
}

QT += network

DEFINES += QT_USE_FAST_CONCATENATION QT_USE_FAST_OPERATOR_PLUS
DEFINES += VS_ENABLE_SPLASH

VERSION = 0.4.6
PACKAGENAME = com.thecust.nelisquare

win32 {
    # Define QMLJSDEBUGGER to allow debugging of QML in debug builds
    # (This might significantly increase build time)
    QMLJSDEBUGGER_PATH = C:\QtSDK\QtCreator\share\qtcreator\qml\qmljsdebugger
    DEFINES += QMLJSDEBUGGER
}

# If your application uses the Qt Mobility libraries, uncomment
# the following lines and add the respective components to the 
# MOBILITY variable. 
maemo5 {
  CONFIG += mobility11 qdbus
} else {
  CONFIG += mobility
}
MOBILITY += location

SOURCES += $$PWD/main.cpp \
    $$PWD/windowhelper.cpp \
    $$PWD/picturehelper.cpp \
    $$PWD/cache.cpp \
    $$PWD/molome.cpp \
    $$PWD/extras/formpost.cpp \
    $$PWD/extras/httppostsendbuffer.cpp

HEADERS += \
    $$PWD/windowhelper.h \
    $$PWD/picturehelper.h \
    $$PWD/cache.h \
    $$PWD/molome.h \
    $$PWD/extras/formpost.h \
    $$PWD/extras/httppostsendbuffer.h

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
    qtc_packaging/debian_harmattan/compat \
    qtc_packaging/debian_harmattan/changelog


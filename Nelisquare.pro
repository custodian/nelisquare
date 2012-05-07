# Add more folders to ship with the application, here
folder_01.source = qml/Nelisquare
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

VERSION = 0.2.6
PACKAGENAME = com.substanceofcode.nelisquare

# Define QMLJSDEBUGGER to allow debugging of QML in debug builds
# (This might significantly increase build time)
# DEFINES += QMLJSDEBUGGER

# If your application uses the Qt Mobility libraries, uncomment
# the following lines and add the respective components to the 
# MOBILITY variable. 
maemo5 {
  CONFIG += mobility11 qdbus
} else {
  CONFIG += mobility
}
MOBILITY += location

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp \
    windowhelper.cpp

# Please do not modify the following two lines. Required for deployment.
include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()

HEADERS += \
    windowhelper.h

OTHER_FILES += \
    qtc_packaging/debian_fremantle/rules \
    qtc_packaging/debian_fremantle/README \
    qtc_packaging/debian_fremantle/copyright \
    qtc_packaging/debian_fremantle/control \
    qtc_packaging/debian_fremantle/compat \
    qtc_packaging/debian_fremantle/changelog

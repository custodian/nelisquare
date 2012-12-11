/*
    Copyright 2011 - Tommi Laukkanen (www.substanceofcode.com)

    This file is part of TwimGo.

    NewsFlow is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Foobar is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with NewsFlow. If not, see <http://www.gnu.org/licenses/>.
*/

#include "windowhelper.h"
#include <QEvent>
#include <QList>
#include <QVariant>
#include <QDebug>
#if defined(Q_OS_MAEMO)
#include <QtDBus>
#include <QDBusConnection>
#include <QDBusMessage>
#endif
#include "qmlapplicationviewer.h"

#include <qplatformdefs.h>

WindowHelper::WindowHelper(QmlApplicationViewer *viewer, QObject *parent) :
    QObject(parent)
{
    m_viewer = viewer;
}

Q_INVOKABLE void WindowHelper::minimize()
{
#if defined(Q_OS_MAEMO)
    QDBusConnection c = QDBusConnection::sessionBus();
    QDBusMessage m = QDBusMessage::createSignal("/", "com.nokia.hildon_desktop", "exit_app_view");
    c.send(m);
    c.send(m);
#endif
}

Q_INVOKABLE bool WindowHelper::isMaemo()
{
#if defined(Q_OS_MAEMO)
    return true;
#else
    return false;
#endif
}

bool WindowHelper::eventFilter(QObject *obj, QEvent *event) {
    switch(event->type()) {
        case QEvent::WindowActivate:
            emit visibilityChanged(QVariant(true));
            return true;
        case QEvent::WindowDeactivate:
            emit visibilityChanged(QVariant(false));
            return true;
        default:
        return false;
    }
}

Q_INVOKABLE void WindowHelper::setOrientation(QVariant value) {
#if defined(Q_OS_MAEMO)
    //TODO: Maemo Orientation bug
    /*
    QString orientation = value.toString();
    QmlApplicationViewer::ScreenOrientation type = QmlApplicationViewer::ScreenOrientationAuto;
    if (orientation == "landscape") {
        type = QmlApplicationViewer::ScreenOrientationLockLandscape;
    } else if (orientation == "portrait") {
        type = QmlApplicationViewer::ScreenOrientationLockPortrait;
    }
    m_viewer->setOrientation(type);
    */
#elif defined(Q_OS_HARMATTAN)
    emit lockOrientation(value);
#endif
}

void WindowHelper::showNelisquare(const QUrl &url) {
    qDebug() << "URL CALL:" << url.toString();
}

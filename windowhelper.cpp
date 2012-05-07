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
#ifdef Q_WS_MAEMO_5
#include <QtDBus>
#include <QDBusConnection>
#include <QDBusMessage>
#endif

WindowHelper::WindowHelper(QObject *parent) :
    QObject(parent)
{
}

Q_INVOKABLE void WindowHelper::minimize()
{
#ifdef Q_WS_MAEMO_5 
    QDBusConnection c = QDBusConnection::sessionBus();
    QDBusMessage m = QDBusMessage::createSignal("/", "com.nokia.hildon_desktop", "exit_app_view");
    c.send(m);
    c.send(m);
#endif
}

Q_INVOKABLE bool WindowHelper::isMaemo()
{
#ifdef Q_WS_MAEMO_5 
    return true;
#else
    return false;
#endif
}


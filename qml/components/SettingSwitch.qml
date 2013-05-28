/*
    Copyright (C) 2012 Dickson Leong
    This file is part of Tweetian.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 1.1
import com.nokia.meego 1.0

Item{
    id: root

    property string text: ""
    property alias enabled: switchItem.enabled
    property alias checked: switchItem.checked
    property bool infoButtonVisible: false
    signal infoClicked

    width: parent.width
    height: switchItem.height + 2 * switchItem.anchors.topMargin

    Text{
        anchors{
            left: parent.left
            right: infoButtonVisible ? infoIconLoader.left : switchItem.left
            margins: mytheme.paddingMedium
            verticalCenter: parent.verticalCenter
        }
        font.pixelSize: mytheme.fontSizeLarge
        maximumLineCount: 2
        color: mytheme.colors.textColorOptions
        wrapMode: Text.Wrap
        elide: Text.ElideRight
        text: root.text
    }

    Loader{
        id: infoIconLoader
        anchors.right: switchItem.left
        anchors.rightMargin: mytheme.paddingLarge
        anchors.verticalCenter: parent.verticalCenter
        sourceComponent: infoButtonVisible ? infoIcon : undefined

        MouseArea{
            anchors.fill: parent
            onClicked: root.infoClicked()
        }
    }

    Component{
        id: infoIcon

        Image{
            source: settings.invertedTheme ? "image://theme/icon-m-content-description"
                                           : "image://theme/icon-m-content-description-inverse"
            sourceSize.width: mytheme.graphicSizeSmall + mytheme.paddingMedium
            sourceSize.height: mytheme.graphicSizeSmall + mytheme.paddingMedium
            cache: false
        }
    }

    Switch{
        id: switchItem
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: mytheme.paddingXLarge
        anchors.rightMargin: mytheme.paddingXLarge
    }
}

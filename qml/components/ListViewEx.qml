import QtQuick 1.1
import com.nokia.meego 1.0

ListView {
    id: root

    property int latency: 600
    property int rotationThreshold: 90//135
    property string pullMessageString: qsTr("Pull and hold to refresh...")
    property string releaseMessageString: qsTr("Release to refresh...")
    property bool platformInverted: false

    // Private
    property bool __wasAtYBeginning: false
    property int __initialContentY: 0
    property bool __toBeRefresh: false

    signal pulledDown()

    onMovementStarted: {
        __wasAtYBeginning = atYBeginning
        __initialContentY = contentY
    }
    onMovementEnded: {
        if (__toBeRefresh) {
            pulledDown()
            __toBeRefresh = false
        }
    }
    onContentYChanged: detectPullDownTimer.running = true

    Item {
        id: pull
        width: parent.width
        opacity: -pullImage.rotation / root.rotationThreshold
        y: -(root.contentY + pullImage.height + labelRow.spacing)

        Row {
            id: labelRow
            anchors.left: parent.left
            anchors.leftMargin: spacing
            spacing: pullImage.width / 2
            width: pullImage.width + pullLabel.width + spacing

            Image {
                id: pullImage
                smooth: true
                source: handleIconSource("toolbar-refresh") //privateStyle.toolBarIconPath("toolbar-refresh", root.platformInverted)
                rotation: 2 * 360 * root.contentY / root.height

                function handleIconSource(iconId) {
                    var prefix = "icon-m-"
                    var inverse = "-white";
                    if (iconId.indexOf("toolbar") === -1)
                        inverse = "-inverse";
                    if (iconId.indexOf(prefix) !== 0)
                        iconId =  prefix.concat(iconId).concat(theme.inverted ? inverse : "");
                    return "image://theme/" + iconId;
                }
            }

            Label {
                id: pullLabel
                text: __toBeRefresh ? root.releaseMessageString : root.pullMessageString
            }
        }
    }

    Timer {
        id: detectPullDownTimer
        interval: latency
        onTriggered: if (__wasAtYBeginning && __initialContentY - contentY > 100) __toBeRefresh = true
    }
}

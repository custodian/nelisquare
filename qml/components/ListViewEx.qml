import QtQuick 1.1
import com.nokia.meego 1.0

ListView {
    id: root

    property int latency: 600
    property int rotationThreshold: 90//135
    property string pullMessageString: "Pull and hold to refresh..."
    property string releaseMessageString: "Release to refresh..."
    property bool platformInverted: false

    signal refreshEvent()

    Item {
        property bool __puller : false

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
                onRotationChanged: {
                    if (pullImage.rotation < -root.rotationThreshold){
                        if (!pullTimer.running && !pull.__puller)
                            pullTimer.restart()
                    }
                    else if (pullImage.rotation > -root.rotationThreshold){
                        if (!pullTimer.running && pull.__puller)
                            pullTimer.restart()
                    }
                }

                function handleIconSource(iconId) {
                    var prefix = "icon-m-"
                    var inverse = "-white";
                    if (iconId.indexOf("toolbar") === -1)
                        inverse = "-inverse";
                    if (iconId.indexOf(prefix) !== 0)
                        iconId =  prefix.concat(iconId).concat(theme.inverted ? inverse : "");
                    return "image://theme/" + iconId;
                }

                Timer{
                    id: pullTimer
                    interval: root.latency

                    onTriggered: {
                        if(pullImage.rotation < -root.rotationThreshold)
                            pull.__puller = true
                        else
                            pull.__puller = false
                    }
                }
            }

            Label {
                id: pullLabel
                text: {
                    if (pull.__puller)
                        return root.releaseMessageString

                    return root.pullMessageString
                }
            }
        }
    }

    onMovementEnded: {
        if (pull.__puller)
            root.refreshEvent()

        pull.__puller = false
        pullTimer.stop()
    }
}

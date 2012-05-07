import Qt 4.7

Rectangle {
    width: parent.width - 20
    x: 10
    height: copyTexts.height + 20
    color: "#40B3DF"
    radius: 5
    border.color: "#17649A"
    border.width: 2

    Column {
        id: copyTexts
        y: 10
        width: parent.width

        Text {
            text: "NeliSquare 0.2.4"
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#333"
            font.pixelSize: 22
        }

        Text {
            text: "© 2011 Tommi Laukkanen\nTwitter: @tlaukkanen\nhttp://nelisquare.com"
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#666"
            font.pixelSize: 22
        }
    }

}

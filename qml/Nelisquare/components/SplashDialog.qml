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
            text: "Nelisquare 0.2.7"
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#333"
            font.pixelSize: 22
        }

        Text {
            text: "© 2012 Basil Semuonov\n© 2011 Tommi Laukkanen\nTwitter: @basil_s\nhttp://nelisquare.com"
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#666"
            font.pixelSize: 22
        }
    }

}

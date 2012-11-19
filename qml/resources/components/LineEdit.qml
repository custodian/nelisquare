import Qt 4.7

Rectangle {
    signal accepted()

    property alias text: searchText.text
    property string textDefault: text

    id: textContainer
    height: 40
    width: parent.width - 10
    x: 10

    gradient: theme.gradientTextBox
    border.width: 1
    border.color: theme.colors.textboxBorderColor
    smooth: true

    function hideKeyboard() {
        searchText.closeSoftwareInputPanel();
        window.focus = true;
    }

    TextInput {
        id: searchText
        text: textContainer.text
        width: parent.width - 10
        height: parent.height - 10
        x: 5
        y: 5
        color: theme.colors.textColor
        font.pixelSize: 24

        onAccepted: {
            hideKeyboard();
            textContainer.accepted()
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                searchText.focus = true;
                if(searchText.text===textDefault) {
                    searchText.text = "";
                }
                if (searchText.text != "") {
                    searchText.cursorPosition = searchText.positionAt(mouseX,mouseY);
                }
            }
        }
    }
}

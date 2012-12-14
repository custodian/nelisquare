import Qt 4.7
import com.nokia.meego 1.0

Item {
    id: button
    width: 100
    height: 50

    property bool pressed: false
    property string label: "-"

    property string prefix: ""
    property string suffix: ""

    /*property string background: ""
    property string foreground: ""

    property string __foreground: ""

    onForegroundChanged: {
        __foreground = foreground + "-"
    }

    onBackgroundChanged: {
        buttonStyle.__colorString = color + "-";
    }*/

    signal clicked()

    onPressedChanged: {
        if (pressed) {
            realButton.checkable = true;
            realButton.checked = true;
        } else {
            realButton.checkable = true;
            realButton.checked = false;
        }
    }
    Button {
        id: realButton
        //checked: pressed//(pressed)?"on":"off"
        //checkable: true
        text: label
        //platformStyle: ButtonStyle { id: buttonStyle }
        platformStyle: ButtonStyle {
            background: "image://theme/meegotouch-button"+((prefix!="" && !theme.inverted)?"-"+prefix:"")+__invertedString+"-background"+(suffix?"-"+suffix:"")+(position?"-"+position:"")
            checkedBackground: "image://theme/meegotouch-button"+((prefix!="" && !theme.inverted)?"-"+prefix:"")+__invertedString+"-background"+(suffix?"-"+suffix:"")+((suffix!="")?"":"-selected")+(position?"-"+position:"")
            pressedBackground: "image://theme/meegotouch-button"+((prefix!="" && !theme.inverted)?"-"+prefix:"")+__invertedString+"-background"+(suffix?"-"+suffix:"")+((suffix!="")?"":"-pressed")+(position?"-"+position:"")
        }

        /*platformStyle: ButtonStyle {
            id: buttonStyle
            background: "image://theme/" + __foreground + "meegotouch-button" + __invertedString + "-background" + (position ? "-" + position : "")
            pressedBackground: "image://theme/" + __colorString + "meegotouch-button" + __invertedString + "-background-pressed" + (position ? "-" + position : "")
            disabledBackground: "image://theme/" + __foreground + "meegotouch-button" + __invertedString + "-background-disabled" + (position ? "-" + position : "")
            checkedBackground: "image://theme/" + __colorString + "meegotouch-button" + __invertedString + "-background-selected" + (position ? "-" + position : "")
            checkedDisabledBackground: "image://theme/" + __colorString + "meegotouch-button" + __invertedString + "-background-disabled-selected" + (position ? "-" + position : "")
        }*/

        anchors.fill: parent
        onClicked: {
            button.clicked();
            button.pressedChanged();
        }
    }
}

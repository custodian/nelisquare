import Qt 4.7
import com.nokia.meego 1.0

Button {
    id: realButton
    width: 100
    height: 50

    property string label: "-"
    property string prefix: ""
    property string suffix: ""

    text: label

    platformStyle: ButtonStyle {
        background: "image://theme/meegotouch-button"+((prefix!="" && !theme.inverted)?"-"+prefix:"")+__invertedString+"-background"+(suffix?"-"+suffix:"")+(position?"-"+position:"")
        checkedBackground: "image://theme/meegotouch-button"+((prefix!="" && !theme.inverted)?"-"+prefix:"")+__invertedString+"-background"+(suffix!=""?"-"+suffix:"")+((suffix!="")?"":"-selected")+(position?"-"+position:"")
        pressedBackground: "image://theme/meegotouch-button"+((prefix!="" && !theme.inverted)?"-"+prefix:"")+__invertedString+"-background"+(suffix!=""?"-"+suffix:"")+((suffix!="")?"":"-pressed")+(position?"-"+position:"")
    }

    /*platformStyle: ButtonStyle {
        id: buttonStyle
        background: "image://theme/" + __foreground + "meegotouch-button" + __invertedString + "-background" + (position ? "-" + position : "")
        pressedBackground: "image://theme/" + __colorString + "meegotouch-button" + __invertedString + "-background-pressed" + (position ? "-" + position : "")
        disabledBackground: "image://theme/" + __foreground + "meegotouch-button" + __invertedString + "-background-disabled" + (position ? "-" + position : "")
        checkedBackground: "image://theme/" + __colorString + "meegotouch-button" + __invertedString + "-background-selected" + (position ? "-" + position : "")
        checkedDisabledBackground: "image://theme/" + __colorString + "meegotouch-button" + __invertedString + "-background-disabled-selected" + (position ? "-" + position : "")
    }*/
}

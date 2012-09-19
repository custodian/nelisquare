import QtQuick 1.1

Item {
    id: theme
    property string backGroundColor: "#EEEEEE"
    property string textColor: "#222"
    property string toolbarDarkColor: "#17649A"
    property string toolbarLightColor: "#40B3DF" // 40B3DF
    property string buttonColor: "#A8CB17"
    property string highlightColor: "#8fd400" //green
    property string menuSeparator: "#ccc"
    property string menuActiveBGColor: "#ccc"
    property string menuInactiveBGColor: "#dedfdf"

    property string textColorButton: "white"
    property string textColorButtonInactive: "gray"

    property string textColorSign: "white"

    property string blueButtonBorderColor: "#18518c"
    property string blueButtonBorderColorPressed: "#2778b3"

    property string backgroundBlueDark: "#176095"
    property string backgroundSettings: "#1377a8"

    property int menuFontSize: 20
    property int menuSubFontSize: 14

    property string textHelp1: "© Design by Kim Venetvirta\n© 2012 Basil Semuonov\n© 2011 Tommi Laukkanen"
    property string textHelp2: "\nIf any problems, tweet @basil_s\n"
    property string textHelp3: "www.nelisquare.com"

    property string textSplash: "Loading..."

    Gradient {
        id: gradientGreen
        GradientStop{position: 0; color: "#57a800"; }
        GradientStop{position: 1.0; color: "#a0d800"; }
    }
    property alias gradientGreen: gradientGreen

    FontLoader {
        id: font;
        source: "TitilliumText25L001.otf"
        property int sizeDefault: 24
        property int sizeToolbar: sizeDefault + 1
        property int sizeSettigs: sizeDefault + 4
        property int sizeSigns: sizeDefault - 2
        property int sizeHelp: sizeDefault - 4
    }
    property alias font: font
}

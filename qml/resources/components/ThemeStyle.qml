import QtQuick 1.1

Item {
    id: theme
    property string backGroundColor: "#e8e3dc" //#EEEEEE"
    property string textColor: "#222"
    property string toolbarDarkColor: "#17649A"
    property string toolbarLightColor: "#40B3DF" // 40B3DF
    property string buttonColor: "#A8CB17"
    property string highlightColor: "#8fd400" //green
    property string menuSeparator: "#ccc"
    property string menuActiveBGColor: "#ccc"
    property string menuInactiveBGColor: "#dedfdf"

    property string textColorButton: "#00aad2" // white
    property string textColorButtonInactive: "#938b82" //"gray"

    property string textColorButtonMenu: "white"
    property string textColorButtonMenuInactive: "gray"

    property string textColorSign: "white"
    property string textColorOptions: "#635959"

    property string blueButtonBorderColor: "#18518c"
    property string blueButtonBorderColorPressed: "#2778b3"

    property string greenButtonBorderColor: "#7aac00"

    property string backgroundMain: "#e8e3dc"
    property string backgroundBlueDark: "#176095"
    property string backgroundSettings: "#e8e3dc"

    property string scoreBackgroundColor: "#c1c1c1"
    property string scoreForegroundColor: "#18659c"

    property int menuFontSize: 20
    property int menuSubFontSize: 14

    property string textVersionInfo: "Version: "
    property string textBuildInfo: "Build: "

    property string textHelp1: "© Design by Kim Venetvirta\n© 2012 Basil Semuonov\n© 2011 Tommi Laukkanen"
    property string textHelp2: "\nIf any problems, tweet @basil_s\n"
    property string textHelp3: "http://github.com/custodian/nelisquare"

    property string textSplash: "Loading..."

    property string textDefaultComment: "Add comment"
    property string textSearchVenue: "Type place to search"
    property string textDefaultTip: "Write some cool tip here"

    Gradient {
        id: gradientGreen
        GradientStop{position: 0; color: "#57a800"; }
        GradientStop{position: 1.0; color: "#a0d800"; }
    }
    property alias gradientGreen: gradientGreen

    Gradient {
        id: gradientLightGreen
        GradientStop{position: 0; color: "#c8eB37"; }
        //GradientStop{position: 0.1; color: "#A8CB17"; }
        GradientStop{position: 0.6; color: "#A8CB17"; }
        //GradientStop{position: 1.0; color: "#98bB17"; }
        //GradientStop{position: 1.0; color: "#98bB17"; }
    }
    property alias gradientLightGreen: gradientLightGreen

    Gradient {
        id: gradientDarkBlue
        GradientStop{position: 0; color: "#0a4570"; }
        GradientStop{position: 0.2; color: "#166196"; }
        GradientStop{position: 1.0; color: "#18659c"; }
    }
    property alias gradientDarkBlue: gradientDarkBlue



    FontLoader {
        id: font;
        source: "TitilliumText25L001.otf"
        property int sizeDefault: 24
        property int sizeToolbar: sizeDefault + (windowHelper.isMaemo()?(-1):(1))
        property int sizeSettigs: sizeDefault + 4
        property int sizeSigns: sizeDefault - 2
        property int sizeHelp: sizeDefault - 4
    }
    property alias font: font
}

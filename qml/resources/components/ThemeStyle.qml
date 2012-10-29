import QtQuick 1.1

Item {
    id: theme

    property string platform: windowHelper.isMaemo() ? "maemo" : "meego"

    property string textColor: "#111"
    property string textColorAlarm: "#d66"

    property string notificationBackground: "#18659c"

    property string checktapBackground: "#05416d"
    property string checktapBackgroundActive: "#555"
    property string checktapBorderColor: "#444"

    property string toolbarDarkColor: "#17649A"
    property string toolbarLightColor: "#40B3DF"

    property string waitingInicatorBackGroun: "#8fd400"

    property string textColorButton: "#35a7d9"
    property string textColorButtonInactive: "#8e857c"

    property string textColorButtonMenu: "#33b5e5"
    property string textColorButtonMenuInactive: "gray"

    property string textColorSign: "white"
    property string textColorOptions: "#635959"
    property string textColorShout: "#555"
    property string textColorTimestamp: "#918980"

    property string blueButtonBorderColor: "#18518c"
    property string blueButtonBorderColorPressed: "#2778b3"

    property string greenButtonBorderColor: "#7aac00"

    property string grayButtonBorderColor: "#999"
    property string grayButtonBorderColorPressed: "#666"

    property string textboxBorderColor: "#aaa"

    property string photoBorderColor: "#ccc"
    property string photoBackground: "#fff"

    property string backgroundMain: "#e8e3dc"
    property string backgroundMenubar: "#404040"
    property string backgroundBlueDark: "#176095"
    property string backgroundSettings: "#e8e3dc"
    property string backgroundSplash: "#00aedb"

    property string backgroundSand: "#dcd4ca"

    property string scoreBackgroundColor: "#dcd4ca"
    property string scoreForegroundColor: "#0072b1"

    property int menuFontSize: 20
    property int menuSubFontSize: 14

    property string textVersionInfo: "Version: "
    property string textBuildInfo: "Build: "

    property string textHelp1: "© Design by Kim Venetvirta\n© 2012 Basil Semuonov\n© 2011 Tommi Laukkanen"
    property string textHelp2: "\nIf any problems, tweet @basil_s\n"
    property string textHelp3: "http://github.com/custodian/nelisquare\n"

    property string textSplash: "Loading..."

    property string textDefaultComment: "Add comment"
    property string textSearchVenue: "Type place to search"
    property string textDefaultTip: "Write some cool tip here"

    Gradient {
        id: gradientTextBox
        GradientStop { position: 0.0; color: "#ccc" }
        GradientStop { position: 0.1; color: "#fafafa" }
        GradientStop { position: 1.0; color: "#fff" }
    }
    property alias gradientTextBox: gradientTextBox

    Gradient{
        id: gradientToolbar
        GradientStop{position: 0; color: "#3098c7"; }
        GradientStop{position: 1.0; color: "#1477a8"; }
    }
    property alias gradientToolbar: gradientToolbar

    Gradient {
        id: gradientGreen
        GradientStop{position: 0; color: "#57a800"; }
        GradientStop{position: 1.0; color: "#a0d800"; }
    }
    property alias gradientGreen: gradientGreen

    Gradient {
        id: gradientGreenPressed
        GradientStop{position: 0; color: "#666"; }
        GradientStop{position: 0.1; color: "#aaa"; }
        GradientStop{position: 0.6; color: "#888"; }
        GradientStop{position: 0.9; color: "#777"; }
    }
    property alias gradientGreenPressed: gradientGreenPressed

    Gradient {
        id: gradientLightGreen
        GradientStop{position: 0; color: "#c8eB37"; }
        GradientStop{position: 0.6; color: "#A8CB17"; }
    }
    property alias gradientLightGreen: gradientLightGreen

    Gradient {
        id: gradientDarkBlue
        GradientStop{position: 0; color: "#0a4570"; }
        GradientStop{position: 0.2; color: "#166196"; }
        GradientStop{position: 1.0; color: "#18659c"; }
    }
    property alias gradientDarkBlue: gradientDarkBlue

    Gradient {
        id: gradientBlue
        GradientStop{position: 0.3; color: "#3784cA"; }
        GradientStop{position: 1; color: "#19548A"; }
    }
    property alias gradientBlue: gradientBlue

    Gradient {
        id: gradientBluePressed
        GradientStop{position: 0; color: "#10446A"; }
        GradientStop{position: 0.1; color: "#17548A"; }
        GradientStop{position: 0.6; color: "#17447A"; }
        GradientStop{position: 0.9; color: "#2060a0"; }
    }
    property alias gradientBluePressed: gradientBluePressed

    Gradient {
        id: gradientGray
        GradientStop{position: 0; color: "#bbb"; }
        GradientStop{position: 0.1; color: "#ccc"; }
        GradientStop{position: 0.6; color: "#aaa"; }
        GradientStop{position: 0.9; color: "#999"; }
    }
    property alias gradientGray: gradientGray

    Gradient {
        id: gradientGrayPressed
        GradientStop{position: 0; color: "#666"; }
        GradientStop{position: 0.1; color: "#aaa"; }
        GradientStop{position: 0.6; color: "#888"; }
        GradientStop{position: 0.9; color: "#777"; }
    }
    property alias gradientGrayPressed: gradientGrayPressed


    FontLoader {
        id: font;
        source: "../fonts/TitilliumText25L001.otf"
        property int sizeDefault: 24
        property int sizeToolbar: sizeDefault + (theme.platform === "maemo"?(-1):(1))
        property int sizeSettigs: sizeDefault + 4
        property int sizeSigns: sizeDefault - 2
        property int sizeHelp: sizeDefault - 4
    }
    property alias font: font
}

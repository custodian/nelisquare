import QtQuick 1.1

Item {
    id: theme

    property string platform: windowHelper.isMaemo() ? "maemo" : "meego"
    property string name: "light"

    property variant colors

    property variant gradientTextBox
    property variant gradientToolbar
    property variant gradientHeader
    property variant gradientGreen
    property variant gradientGreenPressed
    property variant gradientLightGreen
    property variant gradientDarkBlue
    property variant gradientBlue
    property variant gradientBluePressed
    property variant gradientGray
    property variant gradientGrayPressed

    property string textVersionInfo: "Version: "
    property string textBuildInfo: "Build: "

    property string textHelp1: "© Design by Kim Venetvirta\n© 2012 Basil Semuonov\n© 2011 Tommi Laukkanen"
    property string textHelp2: "\nIf any problems, tweet @basil_s\n"
    property string textHelp3: "http://github.com/custodian/nelisquare\n"

    property string textSplash: "Welcome!"

    property string textDefaultComment: "Add comment"
    property string textSearchVenue: "Type place to search"
    property string textDefaultTip: "Write some cool tip here"

    property string textDefaultWait: "ONE MOMENT..."

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

    function loadTheme(type) {
        //console.log("LOADING THEME " + type)
        //actually loading theme
        var factory = Qt.createComponent(Qt.resolvedUrl("../themes/"+type + ".qml"));
        if (factory.status === Component.Ready) {
            var loadedTheme = factory.createObject(theme);
            applyTheme(loadedTheme);
        } else {
            console.log("Theme " + type + " not found!");
        }
    }

    function applyTheme(loadedTheme) {
        //console.log("Apply new theme " + loadedTheme.colors.name);
        //color options
        theme.colors = loadedTheme.colors;
        //gradients
        theme.gradientTextBox = loadedTheme.getGradient("gradientTextBox");
        theme.gradientToolbar = loadedTheme.getGradient("gradientToolbar");
        theme.gradientHeader = loadedTheme.getGradient("gradientHeader");
        theme.gradientGreen = loadedTheme.getGradient("gradientGreen");
        theme.gradientGreenPressed = loadedTheme.getGradient("gradientGreenPressed");
        theme.gradientLightGreen = loadedTheme.getGradient("gradientLightGreen");
        theme.gradientDarkBlue = loadedTheme.getGradient("gradientDarkBlue");
        theme.gradientBlue = loadedTheme.getGradient("gradientBlue");
        theme.gradientBluePressed = loadedTheme.getGradient("gradientBluePressed");
        theme.gradientGray = loadedTheme.getGradient("gradientGray");
        theme.gradientGrayPressed = loadedTheme.getGradient("gradientGrayPressed");

        theme.name = theme.colors.name;
    }
}

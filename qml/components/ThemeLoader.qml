import QtQuick 1.1

Item {
    id: themeLoader
    property string name: "light"

    property variant colors
    property bool inverted: false
    onInvertedChanged: {
        theme.inverted = themeLoader.inverted;
    }
    property string colorString: "red"

    property int borderSizeMedium: 20
    property int headerHeight: inPortrait ? 65 : 55

    // padding size
    property int paddingSmall: 4
    property int paddingMedium: 6
    property int paddingLarge: 8
    property int paddingXLarge: 12
    property int paddingXXLarge: 16

    // font size
    property int fontSizeXSmall: 20
    property int fontSizeSmall: 22
    property int fontSizeMedium: 24
    property int fontSizeLarge: 26
    property int fontSizeXLarge: 28
    property int fontSizeXXLarge: 32

    property int graphicSizeTiny: 24
    property int graphicSizeSmall: 32
    property int graphicSizeMedium: 48
    property int graphicSizeLarge: 72

    property variant gradientTextBox
    property variant gradientToolbar
    property variant gradientHeader
    property variant gradientLightGreen
    property variant gradientDarkBlue

    property string textVersionInfo: "Version: "
    property string textBuildInfo: "Build: "

    property string textHelp1: "© Design by Kim Venetvirta\n© 2012 Basil Semuonov\n© 2011 Tommi Laukkanen"
    property string textHelp2: "\nIf any problems, tweet @basil_s\n"
    property string textHelp3: "http://custodian.github.com/nelisquare"

    property string textSplash: "Welcome!"

    property string textDefaultComment: "New awesome comment"
    property string textDefaultCheckin: "Whats on your mind?"
    property string textSearchVenue: "Type place to search"
    property string textDefaultTip: "Write some cool tip here"

    property string textDefaultWait: "ONE MOMENT..."

    property string textEnterVenueName: "Type venue name..."

    FontLoader {
        id: font;
        source: "../fonts/TitilliumText25L001.otf"
        property int sizeDefault: 24
        property int sizeToolbar: sizeDefault + (configuration.platform === "maemo"?(-1):(1))
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
            var loadedTheme = factory.createObject(themeLoader);
            applyTheme(loadedTheme);
        } else {
            console.log("Theme " + type + " not found!");
        }
    }

    function applyTheme(loadedTheme) {
        //console.log("Apply new theme " + loadedTheme.colors.name);
        //color options
        mytheme.colors = loadedTheme.colors;
        //gradients
        mytheme.gradientTextBox = loadedTheme.getGradient("gradientTextBox");
        mytheme.gradientToolbar = loadedTheme.getGradient("gradientToolbar");
        mytheme.gradientHeader = loadedTheme.getGradient("gradientHeader");
        mytheme.gradientLightGreen = loadedTheme.getGradient("gradientLightGreen");
        mytheme.gradientDarkBlue = loadedTheme.getGradient("gradientDarkBlue");

        mytheme.name = mytheme.colors.name;
        themeLoader.inverted = loadedTheme.inverted;
    }
}

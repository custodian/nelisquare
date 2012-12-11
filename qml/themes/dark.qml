import QtQuick 1.1

Item {
    id: darkTheme
    property variant colors
    property bool inverted: true

    Gradient{
        id: gradientToolbar
        GradientStop{position: 0; color: "#3098c7"; }
        GradientStop{position: 1.0; color: "#1477a8"; }
    }
    property alias gradientToolbar: gradientToolbar

    Gradient {
        id: gradientHeader
        GradientStop{position: 0; color: "#323032"; }
        GradientStop{position: 1; color: "#323032"; }
    }
    property alias gradientHeader: gradientHeader

    Gradient {
        id: gradientDarkBlue
        GradientStop{position: 0; color: "#2f2f2f"; }
        GradientStop{position: 1.0; color: "#2f2f2f"; }
    }
    property alias gradientDarkBlue: gradientDarkBlue

    Gradient {
        id: gradientGreen
        GradientStop{position: 0; color: "#302f30"; }
        GradientStop{position: 1.0; color: "#302f30"; }
    }
    property alias gradientGreen: gradientGreen

    Gradient {
        id: gradientGreenPressed
        GradientStop{position: 0; color: "#232323"; }
        GradientStop{position: 1; color: "#232323"; }
    }
    property alias gradientGreenPressed: gradientGreenPressed

    Gradient {
        id: gradientBlue
        GradientStop{position: 0; color: "#302f30"; }
        GradientStop{position: 1.0; color: "#302f30"; }
    }
    property alias gradientBlue: gradientBlue

    Gradient {
        id: gradientBluePressed
        GradientStop{position: 0; color: "#232323"; }
        GradientStop{position: 1; color: "#232323"; }
    }
    property alias gradientBluePressed: gradientBluePressed

    Gradient {
        id: gradientGray
        GradientStop{position: 0; color: "#302f30"; }
        GradientStop{position: 1.0; color: "#302f30"; }
    }
    property alias gradientGray: gradientGray

    Gradient {
        id: gradientGrayPressed
        GradientStop{position: 0; color: "#232323"; }
        GradientStop{position: 1; color: "#232323"; }
    }
    property alias gradientGrayPressed: gradientGrayPressed

    Gradient {
        id: gradientSingle
        GradientStop{position: 0; color: "#302f30"; }
        GradientStop{position: 1; color: "#302f30"; }
    }

    Component.onCompleted: {
        colors = {
            "name": "dark",
            "iconbg": "",

            "textColor": "#d5d5d5",
            "textColorAlarm": "#d66",

            "notificationBackground": "#171717",

            "checktapBackground": "#222222", //"#05416d",
            "checktapBackgroundActive": "#222222",
            "checktapBorderColor": "#444",

            "toolbarDarkColor": "#121211",
            "toolbarLightColor": "#40B3DF",

            "waitingInicatorBackGround": "#4b4b4b",

            "textButtonText": "#33b5e5",
            "textButtonTextInactive": "#999b99",

            "textButtonTextMenu": "#33b5e5",
            "textButtonTextMenuInactive": "#999b99",

            "textColorSign": "#d3d3d3",
            "textHeader": "#ffffff",
            "textPoints": "#d3d3d3",
            "textColorButton": "#bcbfbc",
            "textColorButtonPressed": "#bcbfbc",
            "textColorOptions": "#d3d3d3",
            "textColorProfile": "#d3d3d3",
            "textColorShout": "#b3b3b3",
            "textColorTimestamp": "#a3a3a3",

            "blueButtonBorderColor": "#494a49",
            "blueButtonBorderColorPressed": "#383938",

            "greenButtonBorderColor": "#494a49",
            "greenButtonBorderColorPressed": "#383938",

            "grayButtonBorderColor": "#494a49",
            "grayButtonBorderColorPressed": "#383938",

            "textboxBorderColor": "#aaa",

            "photoBorderColor": "#4b4b4b",
            "photoBackground": "#4b4b4b",

            "backgroundMain": "#000",
            "backgroundMenubar": "#313131",
            "backgroundBlueDark": "#171717",
            "backgroundSplash": "#00aedb",

            "backgroundSand": "#202020",

            "scoreBackgroundColor": "#202020",
            "scoreForegroundColor": "#023965",
        };
    }

    function getGradient(type) {
        if (darkTheme[type])
            return darkTheme[type];
        return gradientSingle;
    }
}

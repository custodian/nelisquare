import QtQuick 1.1

Item {
    id: lightTheme
    property variant colors
    property bool inverted: false

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
        id: gradientHeader
        GradientStop{position: 0; color: "#57a800"; }
        GradientStop{position: 1.0; color: "#a0d800"; }
    }
    property alias gradientHeader: gradientHeader

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

    Component.onCompleted: {
        colors = {
            "name": "light",
            "iconbg": "bg_",

            "textColor": "#111",
            "textColorAlarm": "#d66",

            "notificationBackground": "#18659c",

            "checktapBackground": "#05416d",
            "checktapBackgroundActive": "#555",
            "checktapBorderColor": "#444",

            "toolbarDarkColor": "#17649A",
            "toolbarLightColor": "#40B3DF",

            "waitingInicatorBackGround": "#dcd4ca",

            "textButtonText": "#35a7d9",
            "textButtonTextInactive": "#8e857c",

            "textButtonTextMenu": "#33b5e5",
            "textButtonTextMenuInactive": "gray",

            "textColorSign": "white",
            "textHeader": "white",
            "textPoints": "white",
            "textColorButton": "white",
            "textColorButtonPressed": "white",
            "textColorOptions": "#635959",
            "textColorProfile": "#635959",
            "textColorShout": "#555555",
            "textColorTimestamp": "#918980",

            "blueButtonBorderColor": "#18518c",
            "blueButtonBorderColorPressed": "#2778b3",

            "greenButtonBorderColor": "#7aac00",
            "greenButtonBorderColorPressed": "#7aac00",

            "grayButtonBorderColor": "#999",
            "grayButtonBorderColorPressed": "#666",

            "textboxBorderColor": "#aaa",

            "photoBorderColor": "#ccc",
            "photoBackground": "#fff",

            "backgroundMain": "#e8e3dc",
            "backgroundMenubar": "#404040",
            "backgroundBlueDark": "#176095",
            "backgroundSplash": "#00aedb",

            "backgroundSand": "#dcd4ca",

            "scoreBackgroundColor": "#dcd4ca",
            "scoreForegroundColor": "#0072b1",
        };
    }

    function getGradient(type) {
        return lightTheme[type];
    }
}

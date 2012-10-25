import Qt 4.7
import "."

Item {
    id: mainWindowStack
    width: 480
    height: 800

    property bool gpsActive: true

    function onPictureUploaded(response, page) {
        window.onPictureUploaded(response, page);
    }

    function onVisibililityChange(state) {
        mainWindowStack.gpsActive = state;
    }

    MainWindow {
        id: window
    }
}

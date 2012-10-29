import Qt 4.7
import "."

Item {
    id: mainWindowStack
    width: 480
    height: 800

    function onPictureUploaded(response, page) {
        window.onPictureUploaded(response, page);
    }

    function onMolomeInfoUpdate(present,installed) {
        window.molome_present = present;
        window.molome_installed = installed;
    }

    function onMolomePhoto(state, photoUrl) {
        window.onMolomePhoto(state,photoUrl);
    }

    function onVisibililityChange(state) {
        window.windowActive = state;
    }

    MainWindow {
        id: window
    }
}

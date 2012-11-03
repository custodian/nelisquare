import Qt 4.7
import QtWebKit 1.0
import "../js/script.js" as Script

Rectangle {
    id: loginDialog
    signal finished(string url)
    signal loadFailed()
    anchors.fill: parent
    color: theme.colors.backgroundMain

    function reset() {
        webView.url = Script.AUTHENTICATE_URL;
        //console.log("Redirecting to " + Script.AUTHENTICATE_URL);
        webView.reload.trigger();
    }

    WebView {
        id: webView
        anchors.fill: parent
        preferredHeight: parent.height
        preferredWidth: parent.width
        url: ""

        onLoadStarted: {
            waiting.show();
        }

        onLoadFinished: {
            //console.log("URL is now " + webView.url);
            waiting.hide();
            loginDialog.finished( webView.url );
        }

        onLoadFailed: {
            waiting.hide();
            loginDialog.loadFailed();
        }

    }
}

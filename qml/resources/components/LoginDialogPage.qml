import Qt 4.7
import QtWebKit 1.0
import "../js/script.js" as Script

Rectangle {
    id: loginDialog
    signal finished(string url)
    signal loadFailed()
    anchors.fill: parent
    color: "#fff"

    function reset() {
        webView.url = Script.AUTHENTICATE_URL;
        //console.log("Redirecting to " + Script.AUTHENTICATE_URL);
        webView.reload.trigger();
    }

    /*Flickable {
        width: parent.width
        height: parent.height
        contentWidth: Math.max(webView.contentsSize.width,480)
        contentHeight: Math.max(webView.contentsSize.height,800)
        pressDelay: 200
        clip: true
        boundsBehavior: Flickable.StopAtBounds*/

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
                loginDialog.loadFailed();
            }

        }
    /*}*/

}

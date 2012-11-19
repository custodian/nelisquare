import Qt 4.7
import QtWebKit 1.0

import "../components"

import "../js/api.js" as Api
import "../js/storage.js" as Storage

Rectangle {
    id: loginDialog
    signal finished(string url)
    signal loadFailed()
    anchors.fill: parent
    color: theme.colors.backgroundMain

    function load() {
        loginDialog.finished.connect(function(url) {
            var token = Api.parseAuth(url, "access_token");
            if (token!==undefined) {
                Storage.setKeyValue("accesstoken", token);
                Api.setAccessToken(token);
                loginStack.clear();
            }
        });
        loginDialog.loadFailed.connect(function() {
            //TODO: error loading page - show some details
        });
        webView.url = Api.AUTHENTICATE_URL;
        //console.log("Redirecting to " + Api.AUTHENTICATE_URL);
        webView.reload.trigger();
    }

    WaitingIndicator {
        id: waitingLogin
        z: 1
    }

    WebView {
        id: webView
        anchors.fill: parent
        preferredHeight: parent.height
        preferredWidth: parent.width
        url: ""

        onLoadStarted: {
            //console.log("URL is now " + webView.url);
            waitingLogin.show();
        }

        onLoadFinished: {
            //console.log("URL is now " + webView.url);
            waitingLogin.hide();
            loginDialog.finished( webView.url );
        }

        onLoadFailed: {
            //console.log("FAILED URL is now " + webView.url);
            waitingLogin.hide();
            loginDialog.loadFailed();
        }
    }
}

import Qt 4.7
import com.nokia.meego 1.0
import QtWebKit 1.0

import "../components"

import "../js/api.js" as Api
import "../js/storage.js" as Storage

//Rectangle {
PageWrapper {
    id: loginDialog
    signal finished(string url)
    signal loadFailed()
    anchors.fill: parent
    //color: mytheme.colors.backgroundMain

    function load() {
        loginDialog.finished.connect(function(url) {
            var token = Api.parseAuth(url, "access_token");
            if (token!==undefined) {
                Storage.setKeyValue("accesstoken", token);
                Api.setAccessToken(token);
            }
        });
        loginDialog.loadFailed.connect(function() {
            //TODO: error loading page - show some details
        });
        reset();
    }

    function reset() {
        webView.url = Api.AUTHENTICATE_URL;
        webView.reload.trigger();
    }

    PageHeader{
        id: header
        headerText: qsTr("Sign In to Foursquare")
        onClicked: {
            reset();
        }
    }

    WebView {
        id: webView
        anchors {top:header.bottom; bottom:parent.bottom; left:parent.left; right:parent.right}
        preferredHeight: height
        preferredWidth: width
        url: ""

        WaitingIndicator {
            id: waitingLogin
            z: 1
        }

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

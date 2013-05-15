import Qt 4.7
import com.nokia.meego 1.0
import QtWebKit 1.0

import "../components"

import "../js/api.js" as Api

//Rectangle {
PageWrapper {
    id: loginDialog
    signal finished(string url)
    signal loadFailed()
    anchors.fill: parent
    //color: mytheme.colors.backgroundMain

    headerText: ""
    //TODO: add some icon (key)
    //headerIcon: "../icons/icon-header-.png"

    function load() {
        loginDialog.finished.connect(function(url) {
            var token = Api.parseAuth(url, "access_token");
            if (token!==undefined) {
                configuration.setAccessToken(token);
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

    //TODO: remove header. use PageWrapper header
    PageHeader{
        id: header
        headerText: qsTr("Sign In to Foursquare")

        MouseArea {
            anchors.fill: parent
            onClicked: {
                reset();
            }
        }
    }

    WebView {
        id: webView
        anchors {top:header.bottom; bottom:parent.bottom; left:parent.left; right:parent.right}
        preferredHeight: height
        preferredWidth: width
        url: ""

        onLoadStarted: {
            //console.log("URL is now " + webView.url);
            //waiting_show();
            header.busy = true;
        }

        onLoadFinished: {
            //console.log("URL is now " + webView.url);
            //waiting_hide();
            header.busy = false;
            loginDialog.finished( webView.url );
        }

        onLoadFailed: {
            //console.log("FAILED URL is now " + webView.url);
            //waiting_hide();
            header.busy = false;
            loginDialog.loadFailed();
        }
    }
}

import Qt 4.7
import com.nokia.meego 1.0
import QtWebKit 1.0

import "../components"

import "../js/api.js" as Api

PageWrapper {
    id: loginDialog
    signal finished(string url)
    signal loadFailed()
    anchors.fill: parent

    headerText: qsTr("Sign In to Foursquare")
    headerIcon: "image://theme/icon-l-accounts-main-view"

    tools: ToolBarLayout{
        ToolIcon{
            platformIconId: "toolbar-back"
            onClicked: stack.pop()
        }
        ToolIcon {
            platformIconId: "toolbar-refresh"
            onClicked: {
                reset();
            }
        }
        ToolIcon {
            platformIconId: "toolbar-view-menu"
            onClicked: {
                menu.open();
            }
        }
    }

    Menu {
        id: menu
        MenuLayout {
            MenuItem {
                text: qsTr("Exit")
                onClicked: {
                    windowHelper.disableSwype(false);
                    Qt.quit();
                }
            }
        }
    }

    function load() {
        loginDialog.finished.connect(function(url) {
            var token = Api.parseAuth(url, "access_token");
            if (token!==undefined) {
                configuration.setAccessToken(token);
            }
        });
        loginDialog.loadFailed.connect(function() {
            //TODO: error loading page - show some details
            show_error(qsTr("Error connecting to Foursquare site"));
        });
        reset();
    }

    function reset() {
        webView.url = Api.AUTHENTICATE_URL;
        webView.reload.trigger();
    }

    WebView {
        id: webView
        anchors {top:pagetop; bottom:parent.bottom; left:parent.left; right:parent.right}
        preferredHeight: height
        preferredWidth: width
        url: ""

        onLoadStarted: {
            waiting_show();
        }

        onLoadFinished: {
            waiting_hide();
            loginDialog.finished( webView.url );
        }

        onLoadFailed: {
            waiting_hide();
            loginDialog.loadFailed();
        }
    }
}

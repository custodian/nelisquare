var windowStash = [];
var windowFactory = [];

function buildPage(owner, type, params, callback) {

    var topPage = topWindow();
    if (topPage!== undefined) {
        //console.log("Top page: " + JSON.stringify(topPage.type) + " params: " + JSON.stringify(topPage.params));
        if (topPage.type === type
            && topPage.params.id === params.id) {
            //console.log("Same page - just update info")
            window.topWindowType = topPage.type;
            topPage.params.update(topPage.page);
            return;
        }
    }

    var builder = function(factory){
        var page = factory.createObject(owner);
        var window = {
            "page" : page,
            "type" : type,
            "params" : params
        };
        pushWindow(window);
        page.stateChanged.connect(function(state){
            //console.log(window.type + " state " + state);
            if (state === "hidden") {
                //console.log("Destroing " + window.type);
                page.destroy(1000);
            }
        });

        callback(page);
        page.state = "shown";
        params.update(page);
    }

    if (windowFactory[type] === undefined) {
        var factory = Qt.createComponent("pages/"+type + ".qml");
        windowFactory[type] = factory;
        if (factory.status === Component.Ready) {
            builder(factory);
        } else {
            console.log("delayed ready page: " + factory.errorString());
            factory.statusChanged.connect(function(){
                  console.log("page is ready");
                  builder(factory);
              });
        }
    } else {
        builder(windowFactory[type]);
    }
}

function pushWindow(wnd) {
    if (windowStash.length>0) {
        topWindow().page.state = "hiddenLeft"
    }
    windowStash.push(wnd);
    window.topWindowType = wnd.type;
    backwardsButton.shown = windowStash.length>1
}

function popWindow(state) {
    if (windowStash.length>1) {
        var lastwindow = windowStash.pop();
        lastwindow.page.state = "hidden";
    }
    backwardsButton.shown = windowStash.length>1

    var wnd = topWindow();
    wnd.page.state = "shown";
    window.topWindowType = wnd.type;
}

function clearWindows() {
    while (windowStash.length > 1) {
        var window = windowStash.pop();
        window.page.state = "hidden";
    }
    popWindow();
}

function topWindow() {
    return windowStash[windowStash.length-1];
}

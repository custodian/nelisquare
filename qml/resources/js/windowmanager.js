var windowStash = [];
var windowFactory = [];
var windowDestructor = [];

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
            if (state === "hidden") {
                windowDestructor.push(window);
            }
        });

        callback(page);
        params.update(page);
    }

    if (windowFactory[type] === undefined) {
        var factory = Qt.createComponent("components/"+type + "Page.qml");
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
    windowStash.push(wnd);
    window.topWindowType = wnd.type;
    backwardsButton.shown = windowStash.length>1
}

function popWindow() {
    if (windowStash.length<=1)
        return;
    var topwindow = windowStash.pop();
    window.topWindowType = topWindow().type;
    backwardsButton.shown = windowStash.length>1
    topwindow.page.state = "hidden";
}

function clearWindows() {
    while (windowStash.length > 1) {
        var window = windowStash.pop();
        window.page.state = "hidden";
    }
    backwardsButton.shown = false
}

function destroyWindows() {
    while (windowDestructor.length > 1) {
        var window = windowDestructor.shift();
        window.page.destroy();
    }
}

function topWindow() {
    return windowStash[windowStash.length-1];
}

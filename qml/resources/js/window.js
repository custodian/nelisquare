
var currentWindow = "";
var windowStash = [];

function pushWindow(window) {
    if (currentWindow !== "") {
        windowStash.push(currentWindow);
    }
    currentWindow = window;
    backwardsButton.shown = windowStash.length>0
    currentWindow();
}

function popWindow() {
    if (windowStash.length==0)
        return;
    currentWindow = windowStash.pop();
    backwardsButton.shown = windowStash.length>0
    currentWindow();
}

function clearWindows() {
    currentWindow = "";
    windowStash = [];
}

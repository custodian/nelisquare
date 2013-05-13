import Qt 4.7
import "."

Image {
    id: root

    property string sourceUncached: ""
    property string __sourceUncached: ""

    Image {
        id: loader
        anchors.centerIn: root
        source: "../pics/"+mytheme.name+"/loader.png"
        visible: (root.status != Image.Ready && sourceUncached != "")
    }

    onStatusChanged: {
        loader.visible = (root.status != Image.Ready)
        if (root.status == Image.Error) {
            //Error loading
            cache.removeUrl(__sourceUncached);
            cacheLoad();
        }
    }

    onSourceUncachedChanged: {
        //console.log("New url arrived: " + sourceUncached + " Old was: " + __sourceUncached);
        //Remove old queue (if any)
        if (__sourceUncached !== "") {
            cache.dequeueObject(__sourceUncached,root);
        }
        //setup new url
        __sourceUncached = sourceUncached;
        //load cached image
        cacheLoad();
    }

    function cacheLoad() {
        if (__sourceUncached !== "") {
            //if valid url - queue cache
            //console.log("Queue cache update for: " + __sourceUncached);
            cache.queueObject(__sourceUncached,root);
        } else {
            //just reset source
            source = __sourceUncached;
        }
    }

    Component.onDestruction: {
        //remove queue (if any)
        if (__sourceUncached !== "") {
            //console.log("Dequeue cache for: " + __sourceUncached);
            cache.dequeueObject(__sourceUncached,root);
        }
    }

    function cacheCallback(status, url) {
        //console.log("CacheImage callback: " + url);
        if (status) {
            root.source = url;
        }
    }
}

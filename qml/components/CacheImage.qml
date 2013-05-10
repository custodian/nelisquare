import Qt 4.7
import "."

Image {
    id: root
    function cacheCallback(status, url) {
        //console.log(" in callback with status: " + status + " url: " + url );
        if (status) {
            root.source = url;
        }
    }
}

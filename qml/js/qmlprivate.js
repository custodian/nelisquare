/*
 * Private bindings
 */
.pragma library

var _privs = {}

function priv(key) {
    var h = key.toString()
    var o = _privs[key]
    if (!o) {
        o = {}
        _privs[key] = o
    }
    return o
}

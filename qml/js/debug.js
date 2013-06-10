/*
 * General debug helpers
 */

.pragma library

api.log( qsTr("loading debug...") );

api.debugenabled = false;

api.debugobject = false;
function loaddebugobject() {
    return undefined
}

api.debugspecial = false;
function loaddebugspecial() {
    return undefined
}

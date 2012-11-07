import Qt 4.7
import QtQuick 1.1

Item {
    id: swypearea
    anchors.fill: parent

    signal swype(int type);
    signal pan (real dx, real dy);
    signal zoom (real zoom);

    property variant direction: {
        "NONE": 0,
        "DOWNLEFT": 1,
        "DOWN": 2,
        "DOWNRIGHT": 3,
        "LEFT": 4,
        "CENTER": 5,
        "RIGHT":6 ,
        "UPLEFT":7 ,
        "UP": 8,
        "UPRIGHT": 9,
    }

    Component.onCompleted: {
        if (theme.platform !== "maemo") {
            Qt.createQmlObject("import QtQuick 1.1; \
                PinchArea { \
                    anchors.fill: parent; \
                    enabled: true; \
                    property real _old_scale: 1; \
                    onPinchStarted: { \
                        _old_scale = 1; \
                    } \
                    onPinchUpdated: { \
                        var zoom = pinch.scale - _old_scale; \
                        swypearea.zoom(zoom); \
                        _old_scale = pinch.scale; \
                    } \
                    onPinchFinished: { \
                    } \
                }",swypearea);
        };

        Qt.createQmlObject("import Qt 4.7; \
            MouseArea { \
                anchors.fill: parent; \
                property real _start_x; \
                property real _start_y; \
                property real _current_x: 0; \
                property real _current_y: 0; \
                onPressed: { \
                    _start_x = mouse.x; \
                    _start_y = mouse.y; \
                    _current_x = _start_x; \
                    _current_y = _start_y; \
                } \
                onPositionChanged: { \
                    var delta_x = mouse.x - _current_x; \
                    var delta_y = mouse.y - _current_y; \
                    swypearea.pan(delta_x,delta_y); \
                    _current_x = mouse.x; \
                    _current_y = mouse.y; \
                } \
                onReleased: { \
                    var _left = false; \
                    var _right = false; \
                    var _up = false; \
                    var _down = false; \
                    var direction = 0; \
                    if (Math.abs(mouse.x - _start_x) > width * 0.25) { \
                        if (mouse.x < _start_x) \
                            _right = true; \
                        else \
                            _left = true; \
                    } \
                    if (Math.abs(mouse.y - _start_y) > height * 0.25) { \
                        if (mouse.y < _start_y) \
                            _down = true; \
                        else \
                            _up = true; \
                    } \
                    if (_right && _up) { \
                        direction = 9; \
                    } else if (_right && _down) { \
                        direction = 3; \
                    } else if (_right) { \
                        direction = 6; \
                    } else if (_left && _up) { \
                        direction = 7; \
                    } else if (_left && _down) { \
                        direction = 1; \
                    } else if (_left) { \
                        direction = 4; \
                    } else if (_up) { \
                        direction = 8; \
                    } else if (_down) { \
                        direction = 2; \
                    } \
                    swypearea.swype(direction); \
                } \
            }",swypearea);
    }

}

import Qt 4.7

MouseArea {
    id: swypearea
    anchors.fill: parent

    signal swype(int type);

    property int _start_x;
    property int _start_y;

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

    onPressed: {
        //console.log("PRESSED: " + JSON.stringify(mouse));
        _start_x = mouse.x;
        _start_y = mouse.y;
    }
    onReleased: {
        //console.log("RELEASED: " + JSON.stringify(mouse));

        var _left = false;
        var _right = false;
        var _up = false;
        var _down = false;
        var direction = 0;
        if (Math.abs(mouse.x - _start_x) > width * 0.25) {
            if (mouse.x < _start_x)
                _right = true;
            else
                _left = true;
        }
        if (Math.abs(mouse.y - _start_y) > height * 0.25) {
            if (mouse.y < _start_y)
                _down = true;
            else
                _up = true;
        }

        if (_right && _up) {
            direction = 9;
        } else if (_right && _down) {
            direction = 3;
        } else if (_right) {
            direction = 6;
        } else if (_left && _up) {
            direction = 7;
        } else if (_left && _down) {
            direction = 1;
        } else if (_left) {
            direction = 4;
        } else if (_up) {
            direction = 8;
        } else if (_down) {
            direction = 2;
        }
        swypearea.swype(direction);
    }
}

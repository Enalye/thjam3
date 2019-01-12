module game.dialog;

import atelier;

DialogGui dialogGui;

class DialogGui: GuiElement {
    private {
        NinePatch _bubble;
        Text _name;
        Text _msg;
        Vec2f _originalSize = Vec2f.one, _newSize = Vec2f.one;
        Timer _timer, _timer2;
        int _characterId;
        string _newMsg;
    }

    this() {
        size(Vec2f(300f, 200f));
        position(Vec2f(150f, 50f));
        setAlign(GuiAlignX.Right, GuiAlignY.Top);

        auto box = new VContainer;
        box.setAlign(GuiAlignX.Center, GuiAlignY.Center);
        addChildGui(box);

        _name = new Text("");
        box.addChildGui(_name);

        _msg = new Text("");
        box.addChildGui(_msg);
        _bubble = fetch!NinePatch("bubble");
        _bubble.size = size;
    }

    void setNewDialog(string name, string msg) {
        _name.text = name;
        _msg.text = msg;
        _originalSize = _bubble.size;
        _newSize = _msg.size + Vec2f(80f, 80f);
        _msg.text = " ";
        _msg.text = "";
        _timer.start(1f);
        _timer2.start(0.02f);
        _newMsg = msg;
        _characterId = 0;
    }

    override void update(float deltaTime) {
        _timer.update(deltaTime);
        _timer2.update(deltaTime);
        _bubble.size = _originalSize.lerp(_newSize, easeOutBounce(_timer.time));

        if(_characterId < _newMsg.length && !_timer2.isRunning) {
            if(_newMsg[_characterId] == '{') {
                while(_newMsg[_characterId] != '}')
                    _characterId ++;
                _characterId += 2;
                if(_characterId > _newMsg.length)
                    _characterId = to!int(_newMsg.length);
            }
            if(_characterId == 0)
                _msg.text = "" ~ _newMsg[0];
            else
                _msg.text = _newMsg[0.. _characterId];
            _characterId ++;
            _timer2.start(0.02f);
        }
    }

    override void draw() {
        _bubble.draw(center);
    }
}
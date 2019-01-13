module game.dialog;

import std.conv: to;
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
        VContainer _box;
        bool _isCharacterSpeaking;

        Sound _sansUndertaleTalk;
    }

    this() {
        size(Vec2f(300f, 200f));
        position(Vec2f(0f, 25f));
        setAlign(GuiAlignX.Center, GuiAlignY.Top);

        _box = new VContainer;
        _box.setAlign(GuiAlignX.Center, GuiAlignY.Center);
        addChildGui(_box);

        _name = new Text("");

        _msg = new Text("");
        _bubble = fetch!NinePatch("bubble");
        _bubble.size = size;

        _sansUndertaleTalk = fetch!Sound("talk");
    }

    void setNewDialog(string name, string msg) {
        _box.removeChildrenGuis();
        _box.addChildGui(_name);
        _box.addChildGui(_msg);

        _name.text = name;
        _msg.text = msg;
        _originalSize = _bubble.size;
        _newSize = _msg.size + Vec2f(32f, 32f);
        _msg.text = " ";
        _msg.text = "";
        _timer.start(1f);
        _timer2.start(0.02f);
        _newMsg = msg ~ " ";
        _characterId = 0;
        _isCharacterSpeaking = true;
    }

    void setNewDialog(string msg) {
        _box.removeChildrenGuis();
        _box.addChildGui(_msg);

        _msg.text = msg;
        _originalSize = _bubble.size;
        _newSize = _msg.size + Vec2f(32f, 32f);
        _msg.text = " ";
        _msg.text = "";
        _timer.start(1f);
        _timer2.start(0.02f);
        _newMsg = msg ~ " ";
        _characterId = 0;
        _isCharacterSpeaking = false;
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
            if(_isCharacterSpeaking && _characterId < _newMsg.length && _newMsg[_characterId] != ' ')
                _sansUndertaleTalk.play();
            _characterId ++;
            _timer2.start(0.02f);
        }
    }

    bool isOver() {
        return _timer2.time() == 1;
    }

    bool isCharacterSpeaking() {
        return _isCharacterSpeaking;
    }

    override void draw() {
        _bubble.draw(center);
    }
}
module game.dialog;

import atelier;

DialogGui dialogGui;

class DialogGui: GuiElement {
    private {
        Text _name;
        Text _msg;
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
    }

    void setNewDialog(string name, string msg) {
        _name.text = name;
        writeln(_name.text);
        _msg.text = msg;
    }
}
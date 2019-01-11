module game.dialog;

import atelier;

class DialogGui: GuiElement {
    private {
        Text _text;
    }

    this() {
        size(Vec2f(300f, 200f));
        setAlign(GuiAlignX.Right, GuiAlignY.Top);

        _text = new Text("Hey test azeaze");
        _text.setAlign(GuiAlignX.Center, GuiAlignY.Center);
        addChildGui(_text);
    }
}
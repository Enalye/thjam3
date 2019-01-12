module game.patient_gui;

import std.random;
import atelier;
import game.dialog;

class PatientGui: GuiElement {
    HeadGui headGui;
    BodyGui bodyGui;

    this() {
        setAlign(GuiAlignX.Left, GuiAlignY.Top);
        position(Vec2f(350f, 300f));

        headGui = new HeadGui;
        bodyGui = new BodyGui;
        size(headGui.size + bodyGui.size);
        addChildGui(bodyGui);
        addChildGui(headGui);
    }


}

class HeadGui: GuiElement {
    Sprite headSprite;
    MouthGui mouthGui;

    this() {
        headSprite = fetch!Sprite("test_head");
        setAlign(GuiAlignX.Center, GuiAlignY.Top);

        size(headSprite.size);
        position(Vec2f(0f, -50f));

        mouthGui = new MouthGui;
        addChildGui(mouthGui);
    }

    override void draw() {
        headSprite.draw(center);
    }
}

class BodyGui: GuiElement {
    Sprite bodySprite;

    this() {
        bodySprite = fetch!Sprite("test_body");
        setAlign(GuiAlignX.Center, GuiAlignY.Bottom);

        size(bodySprite.size);
        position(Vec2f(0f, 50f));
    }

    override void draw() {
        bodySprite.draw(center);
    }
}

class MouthGui: GuiElement {
    Tileset mouthAnim;

    this() {
        mouthAnim = fetch!Tileset("test_mouth");
        setAlign(GuiAlignX.Center, GuiAlignY.Bottom);
        position(Vec2f(0f, 25f));
        size(mouthAnim.size);
    }

    override void draw() {
        if(dialogGui.isOver())
            mouthAnim.draw(0, center);
        else
            mouthAnim.draw(uniform(0, mouthAnim.columns), center);
    }
}
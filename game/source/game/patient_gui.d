module game.patient_gui;

import std.random;
import atelier;
import game.dialog;

PatientGui patientGui;

class PatientGui: GuiElement {
    HeadGui headGui;
    BodyGui bodyGui;

    Timer timer;
    enum State {
        Normal, MovingOut, MovingIn
    }
    State state;

    this() {
        setAlign(GuiAlignX.Left, GuiAlignY.Top);
        position(Vec2f(350f, 300f));

        headGui = new HeadGui;
        bodyGui = new BodyGui;
        size(headGui.size + bodyGui.size);
        addChildGui(bodyGui);
        addChildGui(headGui);
    }

    override void update(float deltaTime) {
        timer.update(deltaTime);
        final switch(state) with(State) {
        case Normal:
            position(Vec2f(350f, 300f));
            break;
        case MovingOut:
            position(Vec2f(lerp(350f, -300f, easeInCirc(timer.time)), 300f));
            if(!timer.isRunning)
                state = State.Normal;
            break;
        case MovingIn:
            position(Vec2f(lerp(900f, 350f, easeOutCirc(timer.time)), 300f));
            if(!timer.isRunning)
                state = State.Normal;
            break;
        }
    }

    void moveOut() {
        state = State.MovingOut;
        timer.start(1f);
    }

    void moveIn() {
        state = State.MovingIn;
        timer.start(1f);
    }

    void setUnconscious() {
        
    }

    void setDead() {

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
        if(dialogGui.isOver() || !dialogGui.isCharacterSpeaking())
            mouthAnim.draw(0, center);
        else
            mouthAnim.draw(uniform(0, mouthAnim.columns), center);
    }
}
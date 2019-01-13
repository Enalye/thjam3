module game.patient_gui;

import std.random;
import atelier;
import game.dialog;

PatientGui patientGui;

class PatientGui: GuiElement {
    Timer timer;
    enum State {
        Normal, MovingOut, MovingIn, Dead
    }
    State state;

    Tileset tileset;
    float angle;
    void setCharacter(string tilesetName) {
        tileset = fetch!Tileset(tilesetName);
        size(tileset.size);
    }

    this() {
        isInteractable(false);
        setAlign(GuiAlignX.Left, GuiAlignY.Top);
        position(Vec2f(250f, 200f));
    }

    override void update(float deltaTime) {
        timer.update(deltaTime);
        final switch(state) with(State) {
        case Normal:
            position(Vec2f(250f, 200f));
            break;
        case MovingOut:
            position(Vec2f(lerp(250f, -300f, easeInCirc(timer.time)), 200f));
            angle = 0f;
            if(!timer.isRunning)
                state = State.Normal;
            break;
        case MovingIn:
            position(Vec2f(lerp(900f, 250f, easeOutCirc(timer.time)), 200f));
            angle = 0f;
            if(!timer.isRunning)
                state = State.Normal;
            break;
        case Dead:
            position(Vec2f(250f, lerp(200f, 600f, easeOutCirc(timer.time))));
            angle = 0f;
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

    void setDead() {
        state = State.Dead;
        timer.start(1f);
    }

    override void draw() {
        tileset.angle = angle;
        if(dialogGui.isOver() || !dialogGui.isCharacterSpeaking())
            tileset.draw(0, center);
        else
            tileset.draw(uniform(0, tileset.columns), center);
    }
}
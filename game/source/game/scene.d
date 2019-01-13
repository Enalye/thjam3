module game.scene;

import std.typecons;
import atelier;
import game.patient, game.doctor, game.menu, game.dialog, game.patient_gui;

private final class ButtonNameGui: GuiElementCanvas {
    private {
        Sprite _rect;
    }

    this(string name) {
        _rect = fetch!Sprite("button_rect");
        position(Vec2f(200f, 0f));

        auto lbl = new Label(name);
        lbl.setAlign(GuiAlignX.Center, GuiAlignY.Center);
        addChildGui(lbl);

        _rect.size = lbl.size + Vec2f(10f, 25f);
        size(_rect.size);

        GuiState defaultState = {
            color: Color.clear,
            offset: Vec2f(75f, 0f),
            scale: Vec2f(.1f, .8f),
            time: .15f
        };
        addState("default", defaultState);

        GuiState unrolledState = {
            offset: Vec2f(125f, 0f),
            easingFunction: getEasingFunction("sine-in-out")
        };
        addState("unrolled", unrolledState);
        setState("default");
    }

    override void draw() {
        _rect.draw(center);
    }
}

private final class MainButton: Button {
    private {
        Sprite _sprite;
        Sprite _icon;
        ButtonNameGui _btnName;
    }

    this(string name, string spriteName) {
        setAlign(GuiAlignX.Left, GuiAlignY.Top);
        _sprite = fetch!Sprite("button_circle");
        _sprite.size = Vec2f(100f, 100f);
        size(_sprite.size * 1.5f);

        _icon = fetch!Sprite(spriteName);
        _icon.fit(Vec2f(80f, 80f));

        _btnName = new ButtonNameGui(name);
        _btnName.setAlign(GuiAlignX.Center, GuiAlignY.Center);
        addChildGui(_btnName);

        GuiState defaultState = {
            time: .25f
        };
        addState("default", defaultState);

        GuiState unrolledState = {
            offset: Vec2f(-50f, 0f),
            easingFunction: getEasingFunction("sine-in-out")
        };
        addState("unrolled", unrolledState);
        setState("default");
    }

    override void onHover() {
        doTransitionState("unrolled");
        _btnName.doTransitionState("unrolled");
    }

    override void update(float deltaTime) {
        if(!isHovered) {
            doTransitionState("default");
            _btnName.doTransitionState("default");
        }
    }

    override void draw() {
        _sprite.color = isLocked ? Color(.3f, .6f, .6f) : Color.white;
        _icon.color = isLocked ? Color(.6f, .6f, .6f) : Color.white;
        _sprite.draw(center);
        _icon.draw(center);
    }
}

class MenuButton: Button {
    private {
        Sprite _sprite;
    }

    this(string name) {
        _sprite = fetch!Sprite("button_cross");
        size(_sprite.size * 2f);

        auto lbl = new Label(name);
        lbl.setAlign(GuiAlignX.Center, GuiAlignY.Center);
        addChildGui(lbl);
    }

    override void draw() {
        _sprite.draw(center);
    }
}

class SceneGui: GuiElement {
    Patient     _patient;
    Doctor      _doctor;

    MainButton _talksBtn, _observationsBtn, _actionsBtn;

    Sprite _bgSprite, _bordersSprite;

    this(string doctorName) {
        dialogGui = new DialogGui;
        patientGui = new PatientGui;

        _bgSprite = fetch!Sprite("background");
        _bordersSprite = fetch!Sprite("borders");

        size(screenSize);

        {
            _talksBtn = new MainButton("Talk", "button_bubble");
            _talksBtn.position = Vec2f(880f, 455f);
            _talksBtn.setCallback(this, "talk");
            addChildGui(_talksBtn);

            _observationsBtn = new MainButton("Observations", "button_eye");
            _observationsBtn.position = Vec2f(695f, 550f);
            _observationsBtn.setCallback(this, "observe");
            addChildGui(_observationsBtn);

            _actionsBtn = new MainButton("Actions", "button_needle");
            _actionsBtn.position = Vec2f(1060f, 320f);
            _actionsBtn.setCallback(this, "action");
            addChildGui(_actionsBtn);
        }

        auto menuBtn = new MenuButton("Menu");
        menuBtn.setCallback(this, "menu");
        addChildGui(menuBtn);

        _doctor = new Doctor(doctorName);
        _patient = _doctor.getNextPatient();
        if(_patient is null)
            return;

        addChildGui(dialogGui);
        addChildGui(patientGui);
    }

    override void onCallback(string id) {
        switch(id) {
        case "talk":
            auto modal = new TalkGui(_patient.getTalkList());
            modal.setCallback(this, "modal.talk");
            setModalGui(modal);
            break;
        case "observe":
            auto modal = new ObserveGui(_patient.getObservationList());
            modal.setCallback(this, "modal.observe");
            setModalGui(modal);
            break;
        case "action":
            auto modal = new ActionGui(_patient.getActionList());
            modal.setCallback(this, "modal.action");
            setModalGui(modal);
            break;
        case "modal.talk":
            auto modal = getModalGui!TalkGui();
            _patient.doTalk(modal.value);
            break;
        case "modal.observe":
            auto modal = getModalGui!ObserveGui();
            _patient.doObservation(modal.value);
            break;
        case "modal.action":
            auto modal = getModalGui!ActionGui();
            _patient.doAction(modal.value);
            break;
        case "menu":
            setModalGui(new MenuConfirmationGui);
            break;
        default:
            break;
        }
    }

    bool isFailed, isSuccess;
    Timer endTimer;
    override void update(float deltaTime) {
        endTimer.update(deltaTime);
        if(_patient.isDead() && dialogGui.isOver() && !isFailed && !isSuccess) {
            isFailed = true;
            endTimer.start(1f);
        }

        _talksBtn.isLocked = _patient.isHealedUp() || !dialogGui.isOver() || isFailed || isSuccess;
        _observationsBtn.isLocked = _patient.isHealedUp() || !dialogGui.isOver() || isFailed || isSuccess;
        _actionsBtn.isLocked = _patient.isHealedUp() || !dialogGui.isOver() || isFailed || isSuccess;

        if(_patient.isHealedUp() && dialogGui.isOver() && !isFailed && !isSuccess) {
            isSuccess = true;
            endTimer.start(1f);
        }

        if(isFailed && !endTimer.isRunning) {
            isFailed = false;
            onMainMenu();
        }
        else if(isSuccess && !endTimer.isRunning) {
            isSuccess = false;
            _patient = _doctor.getNextPatient();
        }
    }

    override void draw() {
        _bgSprite.draw(center);
        _bordersSprite.draw(center);
    }
}

class TalkGui: GuiElement {
    string value;

    this(Tuple!(string, string)[] list) {
        size(screenSize);

        auto box = new VContainer;
        box.setAlign(GuiAlignX.Center, GuiAlignY.Center);
        addChildGui(box);
        foreach(element; list) {
            auto btn = new TextButton(element[1]);
            btn.setCallback(this, element[0]);
            box.addChildGui(btn);
        }
    }

    override void onSubmit() {
        stopModalGui();
    }

    override void onCallback(string id) {
        value = id;
        triggerCallback();
        stopModalGui();
    }
}

class ObserveGui: GuiElement {
    string value;

    this(Tuple!(string, string)[] list) {
        size(screenSize);

        auto box = new VContainer;
        box.setAlign(GuiAlignX.Center, GuiAlignY.Center);
        addChildGui(box);
        foreach(element; list) {
            auto btn = new TextButton(element[1]);
            btn.setCallback(this, element[0]);
            box.addChildGui(btn);
        }
    }

    override void onSubmit() {
        stopModalGui();
    }

    override void onCallback(string id) {
        value = id;
        triggerCallback();   
        stopModalGui();
    }
}

class ActionGui: GuiElement {
    string value;

    this(Tuple!(string, string)[] list) {
        size(screenSize);

        auto box = new VContainer;
        box.setAlign(GuiAlignX.Center, GuiAlignY.Center);
        addChildGui(box);
        foreach(element; list) {
            auto btn = new TextButton(element[1]);
            btn.setCallback(this, element[0]);
            box.addChildGui(btn);
        }
    }

    override void onSubmit() {
        stopModalGui();
    }

    override void onCallback(string id) {
        value = id;
        triggerCallback();        
        stopModalGui();
    }
}

private final class MenuConfirmationGui: GuiElementCanvas {
    this() {
        size(Vec2f(400f, 100f));
        setAlign(GuiAlignX.Center, GuiAlignY.Center);

        { //Title
            auto title = new Label("Return to the main menu ?");
            title.setAlign(GuiAlignX.Left, GuiAlignY.Top);
            title.position = Vec2f(20f, 10f);
            addChildGui(title);
        }

        { //Validation
            auto box = new HContainer;
            box.setAlign(GuiAlignX.Right, GuiAlignY.Bottom);
            box.spacing = Vec2f(25f, 15f);
            addChildGui(box);

            auto applyBtn = new TextButton("Go to the menu");
            applyBtn.size = Vec2f(150f, 35f);
            applyBtn.setCallback(this, "apply");
            box.addChildGui(applyBtn);

            auto cancelBtn = new TextButton("Cancel");
            cancelBtn.size = Vec2f(150f, 35f);
            cancelBtn.setCallback(this, "cancel");
            box.addChildGui(cancelBtn);
        }

        //States
        GuiState hiddenState = {
            offset: Vec2f(0f, -50f),
            color: Color.clear
        };
        addState("hidden", hiddenState);

        GuiState defaultState = {
            time: .5f,
            easingFunction: getEasingFunction("sine-out")
        };
        addState("default", defaultState);

        setState("hidden");
        doTransitionState("default");
    }

    override void onCallback(string id) {
        switch(id) {
        case "apply":
            stopModalGui();
            onMainMenu();
            break;
        case "cancel":
            stopModalGui();
            break;
        default:
            break;
        }
    }

    override void draw() {
        drawFilledRect(origin, size, Color(.11f, .08f, .15f));
    }

    override void drawOverlay() {
        drawRect(origin, size, Color.gray);
    }
}
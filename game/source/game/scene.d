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
        if(!isHovered || isLocked) {
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

    TalkGui     _talkGUI;
    ObserveGui  _observeGUI;
    ActionGui   _actionGUI;

    SyringeGui  _syringeGUI;

    Sprite _bgSprite, _bordersSprite, _doctorSprite;

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

        _doctor = new Doctor(doctorName);
        _doctorSprite = fetch!Sprite(_doctor.id ~ "_face");
        _patient = _doctor.getNextPatient();

        // Sanity assertion
        if(_patient is null)
            return;

        _syringeGUI = new SyringeGui(_patient);
        addChildGui(_syringeGUI);
        addChildGui(dialogGui);
        addChildGui(patientGui);
        updateGUIs();

        auto menuBtn = new MenuButton("Menu");
        menuBtn.setCallback(this, "menu");
        addChildGui(menuBtn);
    }

    override void onCallback(string id) {
        switch(id) {
        case "talk":
            _talkGUI.setCallback(this, "modal.talk");
            setModalGui(_talkGUI);
            break;
        case "observe":
            _observeGUI.setCallback(this, "modal.observe");
            setModalGui(_observeGUI);
            break;
        case "action":
            _actionGUI.setCallback(this, "modal.action");
            setModalGui(_actionGUI);
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

        updateGUIs();
    }

    void updateGUIs() {
        _talkGUI = new TalkGui(_patient.getTalkList());
        _observeGUI = new ObserveGui(_patient.getObservationList());
        _actionGUI = new ActionGui(_patient.getActionList());
    }

    bool isFailed, isSuccess;
    Timer endTimer;
    override void update(float deltaTime) {
        endTimer.update(deltaTime);
        if(_patient.isDead() && dialogGui.isOver() && !isFailed && !isSuccess) {
            isFailed = true;
            patientGui.setDead();
            endTimer.start(1f);
        }

        _talksBtn.isLocked = _patient.isHealedUp() || !dialogGui.isOver() || isFailed || isSuccess || _talkGUI.data.length == 0;
        _observationsBtn.isLocked = _patient.isHealedUp() || !dialogGui.isOver() || isFailed || isSuccess || _observeGUI.data.length == 0;
        _actionsBtn.isLocked = _patient.isHealedUp() || !dialogGui.isOver() || isFailed || isSuccess || _actionGUI.data.length == 0;

        if(_patient.isHealedUp() && dialogGui.isOver() && !isFailed && !isSuccess) {
            isSuccess = true;
            patientGui.moveOut();
            endTimer.start(1f);
        }

        if(isFailed && !endTimer.isRunning) {
            isFailed = false;
            onMainMenu();
        }
        else if(isSuccess && !endTimer.isRunning) {
            isSuccess = false;
            patientGui.moveIn();
            _patient = _doctor.getNextPatient();
            updateGUIs();
            _syringeGUI.updatePatientReference(_patient);
        }
    }

    override void draw() {
        _bgSprite.draw(center);
        _doctorSprite.anchor = Vec2f(1, 0);
        _doctorSprite.fit(Vec2f(280, 280));
        _doctorSprite.draw(Vec2f(screenWidth, 0));
        _bordersSprite.draw(center);
    }
}

private final class SubMenuButton: GuiElementCanvas {
    private {
        Sprite _sprite;
    }

    void function() onClick;

    override void onSubmit() {
        if(isLocked)
            return;
        if(onClick !is null)
            onClick();
        triggerCallback();
    }

    this(string name) {
        _sprite = fetch!Sprite("button_rect");

        auto lbl = new Label(name);
        lbl.setAlign(GuiAlignX.Center, GuiAlignY.Center);
        addChildGui(lbl);

        size(lbl.size + Vec2f(25f, 25f));
        _sprite.size = size;

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

    override void draw() {
        _sprite.draw(center);
    }
}

class SyringeGui: GuiElement {
    Sprite _syringeSprite, _gaugeSprite;
    Patient _patientReference;

    float _startHeight;

    float _oldLevel;
    float _targetLevel;

    Timer _timer;

    this(Patient patient) {
        size(Vec2f(142f, 600f));
        _syringeSprite  = fetch!Sprite("syringe");
        _gaugeSprite    = fetch!Sprite("gauge");
        _startHeight    = _gaugeSprite.size.y;

        _syringeSprite.scale = Vec2f(0.5f, 0.5f);
        _gaugeSprite.scale = Vec2f(0.5f, 0.5f);
        _gaugeSprite.color = Color(1f, 0.55f, 0, 0.5f);
        _gaugeSprite.anchor = Vec2f(0.5f, 1f);

        _patientReference = patient;
        _oldLevel = 0;
        _targetLevel = 0;
    }

    void updatePatientReference(Patient patient) {
        _patientReference = patient;
    }

    override void update(float deltaTime) {
        float level = _patientReference.getSicknessLevel();
        if(_targetLevel != level) {
            _oldLevel = _targetLevel;
            _targetLevel = level;
            _timer.start(0.5f);
        }

        _timer.update(deltaTime);
        float displayLevel = _oldLevel.lerp(_targetLevel, _timer.time);
        _gaugeSprite.size.y =  _startHeight * displayLevel;
    }

    override void draw() {
        _syringeSprite.draw(Vec2f(100, center.y));
        _gaugeSprite.draw(Vec2f(100, center.y + 102));
    }
}

class TalkGui: GuiElement {
    string value;
    Tuple!(string, string)[] data;

    this(Tuple!(string, string)[] list) {
        data = list;
        size(screenSize);

        auto box = new VContainer;
        box.spacing = Vec2f(0f, 15f);
        box.setAlign(GuiAlignX.Center, GuiAlignY.Center);
        addChildGui(box);
        foreach(element; list) {
            auto btn = new SubMenuButton(element[1]);
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
    Tuple!(string, string)[] data;

    this(Tuple!(string, string)[] list) {
        data = list;
        size(screenSize);

        auto box = new VContainer;
        box.spacing = Vec2f(0f, 15f);
        box.setAlign(GuiAlignX.Center, GuiAlignY.Center);
        addChildGui(box);
        foreach(element; list) {
            auto btn = new SubMenuButton(element[1]);
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
    Tuple!(string, string)[] data;

    this(Tuple!(string, string)[] list) {
        data = list;
        size(screenSize);

        auto box = new VContainer;
        box.spacing = Vec2f(0f, 15f);
        box.setAlign(GuiAlignX.Center, GuiAlignY.Center);
        addChildGui(box);
        foreach(element; list) {
            auto btn = new SubMenuButton(element[1]);
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
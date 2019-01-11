module game.scene;

import std.typecons;
import atelier;
import game.patient, game.doctor, game.menu;

class SceneGui: GuiElement {
    Patient _patient;
    Doctor _doctor;

    this(string doctorName) {
        size(screenSize);

        auto box = new VContainer;
        box.setAlign(GuiAlignX.Right, GuiAlignY.Center);
        addChildGui(box);
        {
            auto talksBtn = new TextButton("Talk");
            talksBtn.setCallback(this, "talk");
            box.addChildGui(talksBtn);

            auto observationsBtn = new TextButton("Observe");
            observationsBtn.setCallback(this, "observe");
            box.addChildGui(observationsBtn);

            auto actionsBtn = new TextButton("Actions");
            actionsBtn.setCallback(this, "action");
            box.addChildGui(actionsBtn);
        }

        auto menuBtn = new TextButton("Menu");
        menuBtn.setCallback(this, "menu");
        addChildGui(menuBtn);

        _doctor = new Doctor(doctorName);
        _patient = _doctor.getNextPatient();
    }

    override void onCallback(string id) {
        switch(id) {
        case "talk":
            auto modal = new TalkGui(_doctor.getTalkList());
            modal.setCallback(this, "modal.talk");
            setModalGui(modal);
            break;
        case "observe":
            auto modal = new ObserveGui(_doctor.getObservationList());
            modal.setCallback(this, "modal.observe");
            setModalGui(modal);
            break;
        case "action":
            auto modal = new ActionGui(_doctor.getActionList());
            modal.setCallback(this, "modal.action");
            setModalGui(modal);
            break;
        case "modal.talk":
            auto modal = getModalGui!TalkGui();
            writeln("TALK: " ~ _patient.getTalk(modal.value));
            break;
        case "modal.observe":
            auto modal = getModalGui!ObserveGui();
            writeln("OBSERVE: " ~ _patient.getObservation(modal.value));
            break;
        case "modal.action":
            auto modal = getModalGui!ActionGui();
            _doctor.doAction(modal.value, _patient);
            break;
        case "menu":
            setModalGui(new MenuConfirmationGui);
            break;
        default:
            break;
        }
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
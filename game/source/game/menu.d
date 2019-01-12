module game.menu;

import std.stdio, std.conv;
import atelier;
import game.loader, game.scene;

void setupApplication(string[] args) {
	createApplication(Vec2u(1280u, 720u), "Thjam3");

    windowClearColor = Color(0.111f, 0.1125f, 0.123f);

    onStartupLoad(&onLoadComplete);

	runApplication();
    destroyApplication();
}

void onLoadComplete() {
	onMainMenu();
}

void onMainMenu() {
    removeRootGuis();
	addRootGui(new MainMenuGui);
}

/// Character selection screen
final class MainMenuGui: GuiElement {
    this() {
        size(screenSize);

        auto label = new Label("THJAM3");
        label.setAlign(GuiAlignX.Center, GuiAlignY.Center);
        addChildGui(label);
    }

    override void onSubmit() {
        removeRootGuis();
        addRootGui(new SceneGui("data/doctors/koishi.json"));
    }

    override void update(float deltaTime) {

    }

    override void draw() {

    }
}
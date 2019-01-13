module game.menu;

import std.stdio, std.conv, std.path, std.file;
import atelier;
import game.loader, game.scene;

void setupApplication(string[] args) {
	createApplication(Vec2u(1280u, 720u), "Youkai Center");

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

private final class ArrowButton: Button {
    private {
        Sprite _sprite;
    }

    this(string name) {
        _sprite = fetch!Sprite(name);
        size(_sprite.size);
    }

    override void draw() {
        _sprite.draw(center);
    }
}

/// Character selection screen
final class MainMenuGui: GuiElement {
    Sprite _bg;
    string[] files;
    Sprite[] _sprites;
    int selectId;

    ArrowButton left, right;

    this() {
        size(screenSize);

        auto music = fetch!Music("title");
        music.isLooped = true;
        music.play();

        _bg = fetch!Sprite("title_bg");

        auto label = new Label("Youkai Center");
        label.setAlign(GuiAlignX.Center, GuiAlignY.Top);
        addChildGui(label);

        foreach(file; dirEntries("data/doctors/", "{*.json}", SpanMode.depth)) {
            files ~= file;

            auto json = parseJSON(readText(file));
            _sprites ~= fetch!Sprite(getJsonStr(json, "select"));
        }
        
        left = new ArrowButton("menu_left");
        left.setAlign(GuiAlignX.Left, GuiAlignY.Center);
        left.setCallback(this, "left");
        addChildGui(left);

        right = new ArrowButton("menu_right");
        right.setAlign(GuiAlignX.Right, GuiAlignY.Center);
        right.setCallback(this, "right");
        addChildGui(right);
    }

    override void onCallback(string id) {
        switch(id) {
        case "left":
            selectId --;
            if(selectId < 0)
                selectId = to!int(files.length) - 1;
            break;
        case "right":
            selectId ++;
            if(selectId >= to!int(files.length))
                selectId = 0;
            break;
        default:
            break;
        }
    }

    override void onSubmit() {
        removeRootGuis();
        addRootGui(new SceneGui(files[selectId]));
    }

    override void update(float deltaTime) {

    }

    override void draw() {
        _bg.draw(center);
        _sprites[selectId].draw(Vec2f(center.x, center.y + 80));
    }
}
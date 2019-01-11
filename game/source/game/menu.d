/**
Primidi
Copyright (c) 2016 Enalye

This software is provided 'as-is', without any express or implied warranty.
In no event will the authors be held liable for any damages arising
from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute
it freely, subject to the following restrictions:

	1. The origin of this software must not be misrepresented;
	   you must not claim that you wrote the original software.
	   If you use this software in a product, an acknowledgment
	   in the product documentation would be appreciated but
	   is not required.

	2. Altered source versions must be plainly marked as such,
	   and must not be misrepresented as being the original software.

	3. This notice may not be removed or altered from any source distribution.
*/

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
	//addRootGui(new MainMenuGui);
    addRootGui(new SceneGui("data/doctors/eirin.json"));
}

/// Character selection screen
final class MainMenuGui: GuiElement {
    this() {
        size(screenSize);

        auto label = new Label("THJAM3");
        label.setAlign(GuiAlignX.Center, GuiAlignY.Center);
        addChildGui(label);
    }

    override void update(float deltaTime) {

    }

    override void draw() {

    }
}
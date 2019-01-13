module game.doctor;

import std.stdio, std.file, std.json, std.conv, std.typecons;
import atelier;
import game.patient, game.menu;


final class Doctor {
    string id;

    private {
        JSONValue _json;
        string[] _patients;
        int _patientId = -1;
    }

    this(string name) {
        _json = parseJSON(readText(name));
        id = getJsonStr(_json, "id");
        _patients = getJsonArrayStr(_json, "patients");
        auto music = fetch!Music(id);
        music.isLooped = true;
        music.play();
    }

    Patient getNextPatient() {
        _patientId++;
        if(_patientId >= _patients.length) {
            writeln("victory");
            onMainMenu();
            return null;
        }
        else {
            return new Patient("data/patients/" ~ id ~ "/" ~ _patients[_patientId] ~ ".json");
        }
    }
}
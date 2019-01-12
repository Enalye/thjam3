module game.doctor;

import std.stdio, std.file, std.json, std.conv, std.typecons;
import atelier;
import game.patient, game.menu;


final class Doctor {
    private {
        JSONValue _json;
        string[] _patients;
        int _patientId = -1;
    }

    this(string name) {
        _json = parseJSON(readText(name));
        _patients = getJsonArrayStr(_json, "patients");
    }

    Patient getNextPatient() {
        _patientId++;
        if(_patientId >= _patients.length) {
            writeln("victory");
            onMainMenu();
        }
        return new Patient("data/patients/" ~ getJsonStr(_json, "id") ~ "/" ~ _patients[_patientId] ~ ".json");
    }
}
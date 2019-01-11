module game.doctor;

import std.file, std.json, std.conv, std.typecons;
import atelier;
import game.patient, game.menu;


final class Doctor {
    private {
        JSONValue _json;
        JSONValue[] _actionsJson, _talksJson, _observationsJson;
        string[] _patients;
        int _patientId = -1;
    }

    this(string name) {
        _json = parseJSON(readText(name));
        _actionsJson = getJsonArray(_json, "actions");
        _talksJson = getJsonArray(_json, "talks");
        _observationsJson = getJsonArray(_json, "observations");
        _patients = getJsonArrayStr(_json, "patients");
    }

    Patient getNextPatient() {
        _patientId ++;
        if(_patientId >= _patients.length) {
            writeln("victory");
            onMainMenu();
        }
        return new Patient("data/patients/" ~ getJsonStr(_json, "id") ~ "/" ~ _patients[_patientId] ~ ".json");
    }

    Tuple!(string, string)[] getActionList() {
        Tuple!(string, string)[] list;
        foreach(node; _actionsJson) {
            list ~= tuple(getJsonStr(node, "id"), getJsonStr(node, "name"));
        }
        return list;
    }

    Tuple!(string, string)[] getTalkList() {
        Tuple!(string, string)[] list;
        foreach(node; _talksJson) {
            list ~= tuple(getJsonStr(node, "id"), getJsonStr(node, "name"));
        }
        return list;
    }

    Tuple!(string, string)[] getObservationList() {
        Tuple!(string, string)[] list;
        foreach(node; _observationsJson) {
            list ~= tuple(getJsonStr(node, "id"), getJsonStr(node, "name"));
        }
        return list;
    }
}
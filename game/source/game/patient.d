module game.patient;

import std.file, std.json, std.random;
import atelier;
import game.doctor;

enum PatientState {
    Normal, Unconscious, Cured, InPain, Dead, Failed, Happy, Distress
}

class Patient {
    private {
        PatientState _state;

        int _hunger, _thirst, _inconsciousness, _intoxication, _pain, _sickness, _sadness;

        bool _needProthesis;


        JSONValue _json, _behaviourJson;
    }

    this(string name) {
        _json = parseJSON(readText(name));

        if(!hasJson(_json, "behaviour"))
            throw new Exception("No behaviour scope found in patient");
        _behaviourJson = getJson(_json, "behaviour");

        if(!hasJson(_json, "init"))
            throw new Exception("No init scope found in patient");
        auto node = getJson(_json, "init");
        _thirst = getJsonInt(node, "thirst", 0);
        _hunger = getJsonInt(node, "hunger", 0);
        _inconsciousness = getJsonInt(node, "inconsciousness", 0);
        _intoxication = getJsonInt(node, "intoxication", 0);
        _pain = getJsonInt(node, "pain", 0);
        _sickness = getJsonInt(node, "sickness", 0);
        _sadness = getJsonInt(node, "sadness", 0);
    }

    // Calculate the current state of the patient according to the patient's values
    void processState() {
        auto newState = PatientState.Normal;
        // TODO: Processing.

        if(newState != _state) {
            // TODO: Play the new animation and dialog.
        }
        _state = newState;
    }

    string doThing(string id) {
        if(!hasJson(_behaviourJson, id))
            throw new Exception("No id \'" ~ id ~ "\' found in patient");
        auto list = getJsonArray(_behaviourJson, id);
        auto node = list.choice();
        
        auto txt = "";
        if(hasJson(node, "text")) {
            txt = getJsonStr(node, "text");

        }

        _thirst += getJsonInt(node, "thirst", 0);
        _hunger += getJsonInt(node, "hunger", 0);
        _inconsciousness += getJsonInt(node, "inconsciousness", 0);
        _intoxication += getJsonInt(node, "intoxication", 0);
        _pain += getJsonInt(node, "pain", 0);
        _sickness += getJsonInt(node, "sickness", 0);
        _sadness += getJsonInt(node, "sadness", 0);

        processState();
        return txt;
    }

    void doAction(string id) {
        string txt = doThing(id);
        writeln("Act: ", txt);
    }

    void doObservation(string id) {
        string txt = doThing(id);
        writeln("Obs: ", txt);

    }

    void doTalk(string id) {
        string txt = doThing(id);
        writeln("Talk: ", txt);
        
    }
}
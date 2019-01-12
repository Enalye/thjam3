module game.patient;

import std.stdio, std.file, std.json, std.random, std.typecons, std.algorithm;
import atelier;
import game.doctor, game.dialog;

enum PatientState {
    Normal, Unconscious, Cured, InPain, Dead, Failed, Happy, Distress
}

class Patient {
    private {
        PatientState _state;

        int _unconsciousness, _sickness, _symptoms;

        JSONValue _json;
        JSONValue[string] _savedNodes;
    }

    this(string name) {
        _json = parseJSON(readText(name));

        if(!hasJson(_json, "init"))
            throw new Exception("No init scope found in patient");
        auto node = getJson(_json, "init");
        _unconsciousness = getJsonInt(node, "unconsciousness", 0);
        _sickness = getJsonInt(node, "sickness", 0);
        _symptoms = getJsonInt(node, "symptoms", 0);

        if(hasJson(_json, "hello")) {
            auto hello = getJson(_json, "hello");
            dialogGui.setNewDialog(getJsonStr(_json, "name"), getJsonStr(hello, "text"));
        }
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

    void doThing(string parentId, string id) {
        if(!hasJson(_json, parentId))
            throw new Exception("No scope \'" ~ id ~ "\' found in patient");
        JSONValue parentNode = getJson(_json, parentId);
 
        auto node = _savedNodes[id];
        
        if(hasJson(node, "text")) {
            string txt = getJsonStr(node, "text");
            if(txt.length && dialogGui !is null)
                dialogGui.setNewDialog(getJsonStr(_json, "name"), txt);
        }
        else if(hasJson(node, "narrator")) {
            string txt = getJsonStr(node, "narrator");
            if(txt.length && dialogGui !is null)
                dialogGui.setNewDialog(txt);
        }
        if(hasJson(node, "sound")) {
            fetch!Sound(getJsonStr(node, "sound")).play();
        }

        _unconsciousness = max(0, _unconsciousness + getJsonInt(node, "unconsciousness", 0));
        _sickness        = max(0, _sickness + getJsonInt(node, "sickness", 0));
        _symptoms        = max(0, _symptoms + getJsonInt(node, "symptoms", 0));

        writeln("----------------------------");
        writeln("Unconsciousness | ", _unconsciousness);
        writeln("Symptom         | ", _symptoms);
        writeln("Sickness        | ", _sickness);
        writeln("----------------------------");

        processState();
    }

    void doAction(string id) {
        doThing("actions", id);
    }

    void doObservation(string id) {
        doThing("observations", id);
    }

    void doTalk(string id) {
        doThing("talks", id);
    }

    bool isHealedUp() {
        return _sickness <= 0;
    }

    bool isDead() {
        return _sickness >= 100;
    }

    private Tuple!(string, string)[] getList(string id) {
        if(!hasJson(_json, id))
            throw new Exception("No scope \'" ~ id ~ "\' found in patient");
        JSONValue parentNode = getJson(_json, id);
        Tuple!(string, string)[] list;
        foreach(string tag, JSONValue node; parentNode.object) {
            auto ary = getJsonArray(parentNode, tag);
            bool hasValue = false;
            foreach(value; ary) {
                if(!hasJson(value, "nbSymptomsNeeded"))
                    continue;
                if(getJsonInt(value, "nbSymptomsNeeded") == _symptoms) {
                    _savedNodes[tag] = value;
                    hasValue = true;
                    break;
                }
            }
            if(!hasValue && ary.length) {
                foreach(value; ary) {
                    if(!hasJson(value, "nbSymptomsNeeded")) {
                        _savedNodes[tag] = value;
                        hasValue = true;
                        break;
                    }
                }
            }
            if(hasValue) {
                list ~= tuple(tag, getJsonStr(_savedNodes[tag], "name"));
            }
        }
        return list;
    }

    Tuple!(string, string)[] getActionList() {
        return getList("actions");
    }

    Tuple!(string, string)[] getTalkList() {
        return getList("talks");
    }

    Tuple!(string, string)[] getObservationList() {
        return getList("observations");
    }
}
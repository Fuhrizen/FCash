/*
 * Resolves a transfer target reference or seven-digit account number.
 * Parameters: [reference <STRING>]
 * Returns: [kind <PERSONAL|SHARED|NONE>, id <STRING>, label <STRING>, player <OBJECT>]
 */
params ["_reference"];
if (!isServer || {!(_reference isEqualType "")}) exitWith {["NONE", "", "", objNull]};
private _ref = trim _reference;
private _kind = "NONE";
private _id = "";

if ((_ref find "PIN:") == 0) then {_ref = _ref select [4]};
private _pinIndex = missionNamespace getVariable ["FCash_server_pinIndex", createHashMap];
if ((count _ref) == 7 && {((toArray _ref) findIf {_x < 48 || {_x > 57}}) < 0}) then {
    private _row = _pinIndex getOrDefault [_ref, []];
    if (count _row >= 2) then {
        _kind = _row select 0;
        _id = _row select 1;
    };
};

if (_kind == "NONE") then {
    if ((_ref find "P:") == 0) then {
        _kind = "PERSONAL";
        _id = _ref select [2];
    } else {
        if ((_ref find "S:") == 0) then {
            _kind = "SHARED";
            _id = _ref select [2];
        } else {
            private _banks = missionNamespace getVariable ["FCash_server_banks", createHashMap];
            if !(isNil {_banks get _ref}) then {_kind = "PERSONAL"; _id = _ref};
        };
    };
};

if (_id == "") exitWith {["NONE", "", "", objNull]};
private _names = missionNamespace getVariable ["FCash_server_names", createHashMap];
if (_kind == "PERSONAL") exitWith {
    private _player = objNull;
    private _idx = allPlayers findIf {getPlayerUID _x isEqualTo _id};
    if (_idx >= 0) then {_player = allPlayers select _idx};
    ["PERSONAL", _id, _names getOrDefault [_id, "Personal bank"], _player]
};
if (_kind == "SHARED") exitWith {
    private _sharedMap = missionNamespace getVariable ["FCash_server_shared", createHashMap];
    private _shared = _sharedMap getOrDefault [_id, createHashMap];
    if (count _shared == 0) exitWith {["NONE", "", "", objNull]};
    ["SHARED", _id, _shared getOrDefault ["name", "Shared bank"], objNull]
};
["NONE", "", "", objNull]

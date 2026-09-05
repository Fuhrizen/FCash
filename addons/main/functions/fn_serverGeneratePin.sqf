/*
 * Allocates a unique seven-digit FCash account number as a string.
 * Parameters: [kind <PERSONAL|SHARED>, targetId <STRING>, internalToken <STRING optional>]
 * Returns: seven-digit STRING or "".
 */
params ["_kind", "_targetId", ["_token", ""]];
if (isRemoteExecuted && {_token != missionNamespace getVariable ["FCash_server_internalToken", "__invalid__"]}) exitWith {""};
if (!isServer || {_targetId == ""} || {!(_kind in ["PERSONAL", "SHARED"])}) exitWith {""};

private _index = missionNamespace getVariable ["FCash_server_pinIndex", createHashMap];
private _pin = "";
private _first = ["1","2","3","4","5","6","7","8","9"];
private _digit = ["0","1","2","3","4","5","6","7","8","9"];
for "_i" from 1 to 250 do {
    private _candidate = selectRandom _first;
    for "_d" from 1 to 6 do {_candidate = _candidate + selectRandom _digit};
    if (isNil {_index get _candidate}) exitWith {_pin = _candidate};
};
if (_pin == "") exitWith {""};
_index set [_pin, [_kind, _targetId]];
missionNamespace setVariable ["FCash_server_pinIndex", _index];
_pin

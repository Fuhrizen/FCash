/*
 * Server-only authoritative registered-storage adjustment.
 * Parameters: [object <OBJECT>, value <NUMBER>, mode <ADD|SET>, reason <STRING>, internalToken <STRING optional>]
 * Returns: new balance, or -1 on failure
 */
params ["_object", "_value", ["_mode", "ADD"], ["_reason", "SCRIPT"], ["_token", ""]];
if (isRemoteExecuted && {_token != missionNamespace getVariable ["FCash_server_internalToken", "__invalid__"]}) exitWith {-1};
if (!isServer || {isNull _object} || {!(_value isEqualType 0)} || {!(finite _value)} || {!(_mode in ["ADD", "SET"])}) exitWith {-1};

private _id = netId _object;
if (_id == "") exitWith {-1};
private _storage = missionNamespace getVariable ["FCash_server_storage", createHashMap];
private _record = _storage getOrDefault [_id, []];
if (count _record < 2) exitWith {-1};
_record params ["_old", "_ownerUid"];
private _new = if (_mode == "SET") then {round _value max 0} else {round (_old + _value) max 0};
_storage set [_id, [_new, _ownerUid]];
missionNamespace setVariable ["FCash_server_storage", _storage];
_object setVariable ["FCash_storageBalance", _new, true];
["STORAGE_ADJUST", "SERVER", _id, _new - _old, [_reason, _old, _new, _ownerUid], _token] call FCash_fnc_serverAudit;
_new

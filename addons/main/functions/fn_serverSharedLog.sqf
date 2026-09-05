/*
 * Appends a bounded activity/transaction record to a shared bank.
 * Parameters: [accountId, type, actorUID, amount, targetLabel, details, internalToken]
 */
params ["_id", "_type", "_actorUid", ["_amount", 0], ["_targetLabel", ""], ["_details", []], ["_token", ""]];
if (isRemoteExecuted && {_token != missionNamespace getVariable ["FCash_server_internalToken", "__invalid__"]}) exitWith {};
if (!isServer || {_id == ""}) exitWith {};
private _sharedMap = missionNamespace getVariable ["FCash_server_shared", createHashMap];
private _shared = _sharedMap getOrDefault [_id, createHashMap];
if (count _shared == 0) exitWith {};
private _names = missionNamespace getVariable ["FCash_server_names", createHashMap];
private _actorName = if (_actorUid in ["SERVER", "MISSION"] || {(_actorUid find "MISSION:") == 0}) then {["MISSION", _actorUid] select (_actorUid == "SERVER")} else {_names getOrDefault [_actorUid, _actorUid]};
private _log = _shared getOrDefault ["log", []];
_log pushBack [systemTimeUTC, _type, _actorUid, _actorName, round _amount, _targetLabel, _details];
private _limit = round (["sharedLogLimit", 150] call FCash_fnc_getSetting) max 10;
while {count _log > _limit} do {_log deleteAt 0};
_shared set ["log", _log];
_sharedMap set [_id, _shared];
missionNamespace setVariable ["FCash_server_shared", _sharedMap];

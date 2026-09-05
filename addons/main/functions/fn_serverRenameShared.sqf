/* Server-only shared-account rename API. Returns BOOL. */
params ["_id", "_name", ["_reason", "SCRIPT"], ["_token", ""]];
if (isRemoteExecuted && {_token != missionNamespace getVariable ["FCash_server_internalToken", "__invalid__"]}) exitWith {false};
if (!isServer || {_id == ""} || {!(_name isEqualType "")}) exitWith {false};
_name = trim _name;
private _min = round (["sharedNameMin", 3] call FCash_fnc_getSetting);
private _max = round (["sharedNameMax", 32] call FCash_fnc_getSetting);
if ((count _name) < _min || {(count _name) > _max}) exitWith {false};
private _badChar = (toArray _name) findIf {!(_x == 32 || {_x == 45} || {_x == 95} || {_x >= 48 && {_x <= 57}} || {_x >= 65 && {_x <= 90}} || {_x >= 97 && {_x <= 122}})};
if (_badChar >= 0) exitWith {false};
private _sharedMap = missionNamespace getVariable ["FCash_server_shared", createHashMap];
private _shared = _sharedMap getOrDefault [_id, createHashMap];
if (count _shared == 0) exitWith {false};
private _old = _shared getOrDefault ["name", "Shared Account"];
_shared set ["name", _name];
_sharedMap set [_id, _shared];
missionNamespace setVariable ["FCash_server_shared", _sharedMap];
{[_x, _token] call FCash_fnc_serverSyncPlayer} forEach allPlayers;
["SHARED_RENAME", "SERVER", _id, 0, [_reason, _old, _name], _token] call FCash_fnc_serverAudit;
[_id, "SHARED_RENAME", "SERVER", 0, _name, [_old, _reason], _token] call FCash_fnc_serverSharedLog;
true

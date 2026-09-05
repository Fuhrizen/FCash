/*
 * Server-only administrative API for shared-account creation.
 * Parameters: [ownerUID, name, startingBalance, reason, internalToken, public]
 * Returns: account ID, or "" on failure.
 */
params ["_ownerUid", "_name", ["_startingBalance", 0], ["_reason", "SCRIPT"], ["_token", ""], ["_public", true]];
if (isRemoteExecuted && {_token != missionNamespace getVariable ["FCash_server_internalToken", "__invalid__"]}) exitWith {""};
if (!isServer || {_ownerUid == ""} || {!(_name isEqualType "")} || {!(_startingBalance isEqualType 0)} || {!(finite _startingBalance)}) exitWith {""};
if ((["sharedBankEnabled", 1] call FCash_fnc_getSetting) != 1) exitWith {""};

_name = trim _name;
private _min = round (["sharedNameMin", 3] call FCash_fnc_getSetting);
private _max = round (["sharedNameMax", 32] call FCash_fnc_getSetting);
if ((count _name) < _min || {(count _name) > _max}) exitWith {""};
private _badChar = (toArray _name) findIf {!(_x == 32 || {_x == 45} || {_x == 95} || {_x >= 48 && {_x <= 57}} || {_x >= 65 && {_x <= 90}} || {_x >= 97 && {_x <= 122}})};
if (_badChar >= 0) exitWith {""};

private _sharedMap = missionNamespace getVariable ["FCash_server_shared", createHashMap];
private _counter = (missionNamespace getVariable ["FCash_server_sharedCounter", 0]) + 1;
missionNamespace setVariable ["FCash_server_sharedCounter", _counter];
private _id = format ["FC%1_%2", floor (diag_tickTime * 1000), _counter];
private _pin = ["SHARED", _id, _token] call FCash_fnc_serverGeneratePin;
if (_pin == "") exitWith {""};
private _members = createHashMapFromArray [[_ownerUid, "OWNER"]];
_sharedMap set [_id, createHashMapFromArray [
    ["name", _name], ["balance", round _startingBalance max 0], ["owner", _ownerUid], ["members", _members],
    ["invites", createHashMap], ["createdAt", systemTimeUTC], ["pin", _pin], ["public", _public], ["log", []]
]];
missionNamespace setVariable ["FCash_server_shared", _sharedMap];

{[_x, _token] call FCash_fnc_serverSyncPlayer} forEach allPlayers;
[_id, "SHARED_CREATE", _ownerUid, round _startingBalance max 0, _name, [_reason], _token] call FCash_fnc_serverSharedLog;
["SHARED_CREATE_ADMIN", "SERVER", _id, round _startingBalance max 0, [_reason, _ownerUid, _name, _pin, _public], _token] call FCash_fnc_serverAudit;
_id

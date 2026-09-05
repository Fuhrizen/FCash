/*
 * Registers a networked object as authoritative FCash storage.
 * Parameters: [object <OBJECT>, ownerUID <STRING optional>, startingBalance <NUMBER optional>, internalToken <STRING optional>]
 * Returns: BOOL on server; false on invalid input
 */
params ["_object", ["_ownerUid", ""], ["_startingBalance", 0], ["_token", ""]];
if (isRemoteExecuted && {_token != missionNamespace getVariable ["FCash_server_internalToken", "__invalid__"]}) exitWith {false};
if (!isServer || {isNull _object}) exitWith {false};
if !(_ownerUid isEqualType "") exitWith {false};
if !(_startingBalance isEqualType 0) exitWith {false};
if !(finite _startingBalance) exitWith {false};

private _id = netId _object;
if (_id == "") exitWith {false};
private _storage = missionNamespace getVariable ["FCash_server_storage", createHashMap];
_storage set [_id, [round _startingBalance max 0, _ownerUid]];
missionNamespace setVariable ["FCash_server_storage", _storage];

// These flags only drive client interaction presentation. Access control remains in the server map.
_object setVariable ["FCash_isStorage", true, true];
_object setVariable ["FCash_storageSecured", _ownerUid != "", true];
_object setVariable ["FCash_storageBalance", round _startingBalance max 0, true];
[_object, "STORAGE"] remoteExecCall ["FCash_fnc_clientInstallObjectActions", 0, true];
true

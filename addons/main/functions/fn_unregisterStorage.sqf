/*
 * Server-only API: removes an FCash stash registration.
 * Parameters: [object <OBJECT>, internalToken <STRING optional>, forceDiscard <BOOL optional>]
 * When forceDiscard is false, secured balances refund their owner and unsecured
 * non-empty stashes are preserved. Zeus uses forceDiscard=true for low-friction admin removal.
 * Returns: BOOL
 */
params ["_object", ["_token", ""], ["_forceDiscard", false]];
if (isRemoteExecuted && {_token != missionNamespace getVariable ["FCash_server_internalToken", "__invalid__"]}) exitWith {false};
if (!isServer || {isNull _object}) exitWith {false};
private _id = netId _object;
if (_id == "") exitWith {false};
private _storage = missionNamespace getVariable ["FCash_server_storage", createHashMap];
private _record = _storage getOrDefault [_id, []];
if (count _record < 2) exitWith {false};
_record params ["_balance", "_ownerUid"];
if (!_forceDiscard) then {
    if (_balance > 0 && {_ownerUid == ""}) exitWith {false};
    if (_balance > 0) then {
        [_ownerUid, _balance, "ADD", "STORAGE_UNREGISTER_REFUND", _token] call FCash_fnc_serverAdjustWallet;
    };
};
_storage deleteAt _id;
missionNamespace setVariable ["FCash_server_storage", _storage];
_object setVariable ["FCash_isStorage", false, true];
_object setVariable ["FCash_storageSecured", false, true];
_object setVariable ["FCash_storageBalance", 0, true];
true

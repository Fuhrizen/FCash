/*
 * Server-only shared-account deletion API. Remaining balance is refunded to the owner's personal bank.
 * Returns refunded amount, or -1 on failure.
 */
params ["_id", ["_reason", "SCRIPT"], ["_token", ""]];
if (isRemoteExecuted && {_token != missionNamespace getVariable ["FCash_server_internalToken", "__invalid__"]}) exitWith {-1};
if (!isServer || {_id == ""}) exitWith {-1};
private _sharedMap = missionNamespace getVariable ["FCash_server_shared", createHashMap];
private _shared = _sharedMap getOrDefault [_id, createHashMap];
if (count _shared == 0) exitWith {-1};
private _ownerUid = _shared getOrDefault ["owner", ""];
private _balance = _shared getOrDefault ["balance", 0];
private _pin = _shared getOrDefault ["pin", ""];
_sharedMap deleteAt _id;
missionNamespace setVariable ["FCash_server_shared", _sharedMap];
if (_pin != "") then {
    private _pinIndex = missionNamespace getVariable ["FCash_server_pinIndex", createHashMap];
    _pinIndex deleteAt _pin;
    missionNamespace setVariable ["FCash_server_pinIndex", _pinIndex];
};

if (_ownerUid != "" && {_balance > 0}) then {
    [_ownerUid, _balance, "ADD", format ["%1_REFUND", _reason], _token] call FCash_fnc_serverAdjustBank;
};
{[_x, _token] call FCash_fnc_serverSyncPlayer} forEach allPlayers;
["SHARED_DELETE", "SERVER", _id, _balance, [_reason, _ownerUid, "REFUNDED_TO_OWNER_BANK"], _token] call FCash_fnc_serverAudit;
_balance

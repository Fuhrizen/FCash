/*
 * Server-only administrative API for shared-account balance adjustment.
 * Parameters: [accountId <STRING>, value <NUMBER>, mode <ADD|SET>, reason <STRING>, internalToken <STRING optional>]
 * Returns: new balance, or -1 on failure
 */
params ["_id", "_value", ["_mode", "ADD"], ["_reason", "SCRIPT"], ["_token", ""], ["_actorUid", "SERVER"]];
if (isRemoteExecuted && {_token != missionNamespace getVariable ["FCash_server_internalToken", "__invalid__"]}) exitWith {-1};
if (!isServer || {_id == ""} || {!(_value isEqualType 0)} || {!(finite _value)} || {!(_mode in ["ADD", "SET"])}) exitWith {-1};
private _sharedMap = missionNamespace getVariable ["FCash_server_shared", createHashMap];
private _shared = _sharedMap getOrDefault [_id, createHashMap];
if (count _shared == 0) exitWith {-1};
private _old = _shared getOrDefault ["balance", 0];
private _new = if (_mode == "SET") then {round _value max 0} else {round (_old + _value) max 0};
_shared set ["balance", _new];
_sharedMap set [_id, _shared];
missionNamespace setVariable ["FCash_server_shared", _sharedMap];

private _members = _shared getOrDefault ["members", createHashMap];
{
    private _uid = _x;
    private _idx = allPlayers findIf {getPlayerUID _x isEqualTo _uid};
    if (_idx >= 0) then {[allPlayers select _idx, _token] call FCash_fnc_serverSyncPlayer};
} forEach keys _members;
["SHARED_ADJUST", "SERVER", _id, _new - _old, [_reason, _old, _new], _token] call FCash_fnc_serverAudit;
[_id, "SHARED_ADJUST", _actorUid, _new - _old, _reason, [_old, _new], _token] call FCash_fnc_serverSharedLog;
_new

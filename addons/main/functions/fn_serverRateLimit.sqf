/*
 * Per-network-owner request limiter.
 * Parameters: [ownerId <NUMBER>]
 * Returns: BOOL (true when request is permitted)
 */
params [["_ownerId", -1, [0]], ["_token", ""]];
if (isRemoteExecuted && {_token != missionNamespace getVariable ["FCash_server_internalToken", "__invalid__"]}) exitWith {false};
if (_ownerId < 0) exitWith {false};

private _window = ["requestWindow", 1.0] call FCash_fnc_getSetting;
private _burst = round (["requestBurst", 10] call FCash_fnc_getSetting);
private _now = diag_tickTime;
private _rate = missionNamespace getVariable ["FCash_server_rate", createHashMap];
private _state = _rate getOrDefault [_ownerId, [_now, 0]];
_state params ["_start", "_count"];

if ((_now - _start) > _window) then {
    _start = _now;
    _count = 0;
};
_count = _count + 1;
_rate set [_ownerId, [_start, _count]];
missionNamespace setVariable ["FCash_server_rate", _rate];
_count <= _burst

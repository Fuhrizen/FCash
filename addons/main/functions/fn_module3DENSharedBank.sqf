/*
 * Eden module: creates a shared bank and grants synchronized player slots membership.
 * The first synchronized CAManBase becomes owner when that slot resolves to a player; remaining units become members.
 */
params ["_logic", ["_units", []], ["_activated", true]];
if (isRemoteExecuted) exitWith {};
if (!isServer || {!_activated} || {isNull _logic}) exitWith {};
private _name = trim (_logic getVariable ["FCash_sharedName", "Shared Bank"]);
private _raw = _logic getVariable ["FCash_sharedValue", "0"];
private _public = _logic getVariable ["FCash_sharedPublic", true];
private _token = missionNamespace getVariable ["FCash_server_internalToken", ""];
private _targets = (synchronizedObjects _logic) select {_x isKindOf "CAManBase"};

private _starting = [_logic, _raw, 0, _token] call FCash_fnc_serverResolveStartingValue;
private _missionOwner = format ["MISSION:%1", netId _logic];
private _id = [_missionOwner, _name, _starting, "3DEN", _token, _public] call FCash_fnc_serverCreateShared;
if (_id == "") exitWith {};

private _ownerTarget = objNull;
private _ownerIndex = _targets findIf {isPlayer _x || {_x in playableUnits}};
if (_ownerIndex >= 0) then {_ownerTarget = _targets select _ownerIndex};
if (isNull _ownerTarget && {!(_targets isEqualTo [])}) then {_ownerTarget = _targets select 0};

{
    private _role = ["MEMBER", "OWNER"] select (_x isEqualTo _ownerTarget);
    private _pending = _x getVariable ["FCash_pendingSharedMembership", []];
    _pending pushBackUnique [_id, _role, _missionOwner];
    _x setVariable ["FCash_pendingSharedMembership", _pending, true];
    if (isPlayer _x) then {[_x, _token] call FCash_fnc_serverEnsureAccount; [_x, _token] call FCash_fnc_serverSyncPlayer};
} forEach _targets;

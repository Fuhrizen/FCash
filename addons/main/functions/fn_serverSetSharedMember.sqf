/*
 * Server-only shared membership API.
 * role: MANAGER, MEMBER, VIEWER, or REMOVE. Owner cannot be modified here.
 * Returns BOOL.
 */
params ["_id", "_memberUid", "_role", ["_reason", "SCRIPT"], ["_token", ""]];
if (isRemoteExecuted && {_token != missionNamespace getVariable ["FCash_server_internalToken", "__invalid__"]}) exitWith {false};
if (!isServer || {_id == ""} || {_memberUid == ""} || {!(_role in ["MANAGER", "MEMBER", "VIEWER", "REMOVE"])}) exitWith {false};
private _sharedMap = missionNamespace getVariable ["FCash_server_shared", createHashMap];
private _shared = _sharedMap getOrDefault [_id, createHashMap];
if (count _shared == 0) exitWith {false};
private _ownerUid = _shared getOrDefault ["owner", ""];
if (_memberUid == _ownerUid) exitWith {false};
private _members = _shared getOrDefault ["members", createHashMap];
private _oldRole = _members getOrDefault [_memberUid, "NONE"];
if (_role != "REMOVE" && {_oldRole == "NONE"} && {(count _members) >= round (["sharedMaxMembers", 32] call FCash_fnc_getSetting)}) exitWith {false};
if (_role == "REMOVE") then {
    _members deleteAt _memberUid;
} else {
    _members set [_memberUid, _role];
};
_shared set ["members", _members];
private _invites = _shared getOrDefault ["invites", createHashMap];
_invites deleteAt _memberUid;
_shared set ["invites", _invites];
_sharedMap set [_id, _shared];
missionNamespace setVariable ["FCash_server_shared", _sharedMap];

private _syncUids = keys _members;
_syncUids pushBackUnique _memberUid;
{
    private _uid = _x;
    private _idx = allPlayers findIf {getPlayerUID _x isEqualTo _uid};
    if (_idx >= 0) then {[allPlayers select _idx, _token] call FCash_fnc_serverSyncPlayer};
} forEach _syncUids;
["SHARED_MEMBER_ADMIN", "SERVER", _memberUid, 0, [_reason, _id, _oldRole, _role], _token] call FCash_fnc_serverAudit;
[_id, "SHARED_MEMBER", "SERVER", 0, _memberUid, [_reason, _oldRole, _role], _token] call FCash_fnc_serverSharedLog;
true

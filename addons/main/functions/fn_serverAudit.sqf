/*
 * Appends one bounded authoritative audit record.
 * Parameters: [type, actorUID, target, amount, details]
 * Returns: nothing
 */
params ["_type", "_actorUid", ["_target", ""], ["_amount", 0], ["_details", []], ["_token", ""]];
if (isRemoteExecuted && {_token != missionNamespace getVariable ["FCash_server_internalToken", "__invalid__"]}) exitWith {};
if (!isServer) exitWith {};

private _audit = missionNamespace getVariable ["FCash_server_audit", []];
_audit pushBack [systemTimeUTC, _type, _actorUid, _target, _amount, _details];
private _limit = round (["auditLimit", 250] call FCash_fnc_getSetting);
while {count _audit > _limit} do {_audit deleteAt 0};
missionNamespace setVariable ["FCash_server_audit", _audit];

["transaction", [_type, _actorUid, _target, _amount, _details]] call FCash_fnc_emitEvent;

/*
 * Registers a custom object as an FCash banking terminal.
 * Server-side registration is authoritative; the public flag is UI metadata only.
 * Parameters: [object <OBJECT>, internalToken <STRING optional>]
 * Returns: BOOL
 */
params ["_object", ["_token", ""]];
if (isRemoteExecuted && {_token != missionNamespace getVariable ["FCash_server_internalToken", "__invalid__"]}) exitWith {false};
if (!isServer || {isNull _object}) exitWith {false};
private _id = netId _object;
if (_id == "") exitWith {false};

private _terminals = missionNamespace getVariable ["FCash_server_terminals", createHashMap];
_terminals set [_id, true];
missionNamespace setVariable ["FCash_server_terminals", _terminals];

_object setVariable ["FCash_isTerminal", true, true];
[_object, "TERMINAL"] remoteExecCall ["FCash_fnc_clientInstallObjectActions", 0, true];
true

/* Server-only API: removes a custom FCash banking terminal registration. */
params ["_object", ["_token", ""]];
if (isRemoteExecuted && {_token != missionNamespace getVariable ["FCash_server_internalToken", "__invalid__"]}) exitWith {false};
if (!isServer || {isNull _object}) exitWith {false};
private _id = netId _object;
if (_id == "") exitWith {false};
private _terminals = missionNamespace getVariable ["FCash_server_terminals", createHashMap];
_terminals deleteAt _id;
missionNamespace setVariable ["FCash_server_terminals", _terminals];
_object setVariable ["FCash_isTerminal", false, true];
true

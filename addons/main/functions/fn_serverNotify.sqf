/*
 * Sends a sanitized UI notification to one player.
 * Parameters: [player <OBJECT>, message <STRING>, kind <STRING optional>]
 * Returns: nothing
 */
params ["_player", "_message", ["_kind", "INFO"], ["_token", ""]];
if (isRemoteExecuted && {_token != missionNamespace getVariable ["FCash_server_internalToken", "__invalid__"]}) exitWith {};
if (isNull _player) exitWith {};
[_message, _kind] remoteExecCall ["FCash_fnc_clientNotify", owner _player];

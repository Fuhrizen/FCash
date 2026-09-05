/*
 * Requests an authoritative account snapshot from the server.
 * Parameters: none
 * Returns: nothing
 */
if (!hasInterface) exitWith {};
["SYNC", []] remoteExecCall ["FCash_fnc_serverRequest", 2];

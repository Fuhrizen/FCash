/*
 * Resolves the player object that owns a remoteExec request.
 * Parameters: [ownerId <NUMBER>]
 * Returns: OBJECT or objNull
 */
params [["_ownerId", -1, [0]]];
private _index = allPlayers findIf {owner _x isEqualTo _ownerId};
if (_index < 0) exitWith {objNull};
allPlayers select _index

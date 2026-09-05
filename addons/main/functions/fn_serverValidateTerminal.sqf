/*
 * Validates that the caller is physically at an authoritative FCash bank terminal.
 * Default configured ATM classes are trusted by class; custom terminals must exist in the server registry.
 * Parameters: [player <OBJECT>, terminal <OBJECT>]
 * Returns: BOOL
 */
params ["_player", "_terminal"];
if (!isServer || {isNull _player} || {isNull _terminal}) exitWith {false};

private _nativeAtmClasses = ["Land_Atm_01_F", "Land_Atm_02_F", "Land_ATM_01_malden_F", "Land_ATM_02_malden_F"];
private _classes = +_nativeAtmClasses;
{_classes pushBackUnique _x} forEach (["atmClasses", _nativeAtmClasses] call FCash_fnc_getSetting);
private _classAllowed = (_classes findIf {_terminal isKindOf _x}) >= 0;
private _terminals = missionNamespace getVariable ["FCash_server_terminals", createHashMap];
private _registered = !(isNil {_terminals get (netId _terminal)});
if !(_registered || _classAllowed) exitWith {false};

private _distance = ["terminalDistance", 5.0] call FCash_fnc_getSetting;
_player distance _terminal <= _distance

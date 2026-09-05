/* Submits the create-shared-bank modal. */
disableSerialization;
private _display = findDisplay 61200;
if (isNull _display) exitWith {};
private _name = ctrlText (_display displayCtrl 61201);
private _terminal = uiNamespace getVariable ["FCash_ui_terminal", objNull];
if (isNull _terminal) exitWith {[_display] call FCash_fnc_uiCloseDialog};
["SHARED_CREATE", [_terminal, _name]] remoteExecCall ["FCash_fnc_serverRequest", 2];
[_display] call FCash_fnc_uiCloseDialog;

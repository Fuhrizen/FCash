/* Requests the selected shared-bank log from the authoritative server. */
disableSerialization;
private _display = uiNamespace getVariable ["FCash_ui_bankDisplay", displayNull];
if (isNull _display) exitWith {};
private _terminal = uiNamespace getVariable ["FCash_ui_terminal", objNull];
private _ctrl = _display displayCtrl 61141;
private _idx = lbCurSel _ctrl;
if (isNull _terminal || {_idx < 0}) exitWith {};
["SHARED_LOG_REQUEST", [_terminal, _ctrl lbData _idx]] remoteExecCall ["FCash_fnc_serverRequest", 2];

/* Submits the FCash Zeus management dialog. */
disableSerialization;
private _display = uiNamespace getVariable ["FCash_ui_zeusDisplay", displayNull];
private _context = uiNamespace getVariable ["FCash_ui_zeusContext", []];
if (isNull _display || {count _context < 4}) exitWith {};
_context params ["_operation", "_target"];

private _modeCtrl = _display displayCtrl 61304;
private _accountCtrl = _display displayCtrl 61306;
private _mode = if ((lbCurSel _modeCtrl) >= 0) then {_modeCtrl lbData (lbCurSel _modeCtrl)} else {"SET"};
private _selector = if ((lbCurSel _accountCtrl) >= 0) then {_accountCtrl lbData (lbCurSel _accountCtrl)} else {""};
private _name = ctrlText (_display displayCtrl 61308);
private _value = parseNumber ctrlText (_display displayCtrl 61310);
[_display] call FCash_fnc_uiCloseDialog;
["EXECUTE", [_operation, _target, _mode, _value, _selector, _name]] remoteExecCall ["FCash_fnc_serverZeusRequest", 2];

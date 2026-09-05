/* Submits the currently open amount dialog to the authoritative server. */
disableSerialization;
private _display = findDisplay 61000;
if (isNull _display) exitWith {};
private _target = uiNamespace getVariable ["FCash_ui_amountTarget", objNull];
private _mode = uiNamespace getVariable ["FCash_ui_amountMode", ""];
private _amount = round parseNumber ctrlText (_display displayCtrl 61003);
if (isNull _target || {_amount <= 0}) exitWith {
    ["Enter a valid amount.", "ERROR"] call FCash_fnc_clientNotify;
};

private _data = switch (_mode) do {
    case "DIRECT_SEND": {[getPlayerUID _target, _amount]};
    default {[_target, _amount]};
};
[_mode, _data] remoteExecCall ["FCash_fnc_serverRequest", 2];
[ _display ] call FCash_fnc_uiCloseDialog;

/* Confirms recipient search selection and stores it for the active transfer source. */
disableSerialization;
private _display = uiNamespace getVariable ["FCash_ui_recipientDisplay", displayNull];
private _bankDisplay = uiNamespace getVariable ["FCash_ui_bankDisplay", displayNull];
if (isNull _display || {isNull _bankDisplay}) exitWith {};
private _list = _display displayCtrl 61402;
private _idx = lbCurSel _list;
if (_idx < 0) exitWith {};
private _ref = _list lbData _idx;
private _label = _list lbText _idx;
private _source = uiNamespace getVariable ["FCash_ui_recipientSource", "PERSONAL"];
private _key = ["FCash_ui_personalRecipient", "FCash_ui_sharedRecipient"] select (_source == "SHARED");
uiNamespace setVariable [_key, [_ref, _label]];
private _ctrl = _bankDisplay displayCtrl ([61128, 61148] select (_source == "SHARED"));
_ctrl ctrlSetText _label;
[_display] call FCash_fnc_uiCloseDialog;

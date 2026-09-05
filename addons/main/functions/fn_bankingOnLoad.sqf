/* Banking display onLoad handler. */
disableSerialization;
params ["_display"];
uiNamespace setVariable ["FCash_ui_bankDisplay", _display];
uiNamespace setVariable ["FCash_ui_refreshing", false];
uiNamespace setVariable ["FCash_ui_personalRecipient", []];
uiNamespace setVariable ["FCash_ui_sharedRecipient", []];

private _roleCombo = _display displayCtrl 61153;
lbClear _roleCombo;
{private _i = _roleCombo lbAdd _x; _roleCombo lbSetData [_i, _x]} forEach ["MANAGER", "MEMBER", "VIEWER"];
_roleCombo lbSetCurSel 1;

["PERSONAL"] call FCash_fnc_bankingSetTab;
[] call FCash_fnc_bankingRefresh;
[_display] call FCash_fnc_uiAnimateIn;

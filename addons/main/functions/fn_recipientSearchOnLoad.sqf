disableSerialization;
params ["_display"];
uiNamespace setVariable ["FCash_ui_recipientDisplay", _display];
(_display displayCtrl 61401) ctrlSetText "";
(_display displayCtrl 61403) cbSetChecked (uiNamespace getVariable ["FCash_ui_recipientFilterPersonal", true]);
(_display displayCtrl 61404) cbSetChecked (uiNamespace getVariable ["FCash_ui_recipientFilterShared", true]);
[] call FCash_fnc_recipientSearchRefresh;
[_display] call FCash_fnc_uiAnimateIn;

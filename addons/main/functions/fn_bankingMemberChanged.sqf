/* Syncs the shared role combo to the currently selected member. */
disableSerialization;
private _display = uiNamespace getVariable ["FCash_ui_bankDisplay", displayNull];
if (isNull _display) exitWith {};
private _memberCtrl = _display displayCtrl 61151;
private _idx = lbCurSel _memberCtrl;
if (_idx < 0) exitWith {};
private _memberUid = _memberCtrl lbData _idx;
private _sharedId = uiNamespace getVariable ["FCash_ui_sharedSelected", ""];
private _shared = missionNamespace getVariable ["FCash_cache_shared", []];
private _rowIndex = _shared findIf {(_x select 0) isEqualTo _sharedId};
if (_rowIndex < 0) exitWith {};
private _members = (_shared select _rowIndex) select 5;
private _memberIndex = _members findIf {(_x select 0) isEqualTo _memberUid};
if (_memberIndex < 0) exitWith {};
private _role = (_members select _memberIndex) select 2;
private _roleCtrl = _display displayCtrl 61153;
for "_i" from 0 to ((lbSize _roleCtrl) - 1) do {
    if ((_roleCtrl lbData _i) isEqualTo _role) exitWith {_roleCtrl lbSetCurSel _i};
};

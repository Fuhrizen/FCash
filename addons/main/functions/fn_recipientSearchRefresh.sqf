/* Refreshes the filterable transfer recipient list from the sanitized snapshot. */
disableSerialization;
private _display = uiNamespace getVariable ["FCash_ui_recipientDisplay", displayNull];
if (isNull _display) exitWith {};
private _queryRaw = trim ctrlText (_display displayCtrl 61401);
private _query = toLower _queryRaw;
private _showPersonal = cbChecked (_display displayCtrl 61403);
private _showShared = cbChecked (_display displayCtrl 61404);
uiNamespace setVariable ["FCash_ui_recipientFilterPersonal", _showPersonal];
uiNamespace setVariable ["FCash_ui_recipientFilterShared", _showShared];

private _list = _display displayCtrl 61402;
lbClear _list;
private _rows = missionNamespace getVariable ["FCash_cache_recipients", []];
private _source = uiNamespace getVariable ["FCash_ui_recipientSource", "PERSONAL"];
private _excludeRef = if (_source == "SHARED") then {format ["S:%1", uiNamespace getVariable ["FCash_ui_sharedSelected", ""]]} else {""};

private _directAccount = [_queryRaw] call FCash_fnc_formatAccountNumber;
if (_directAccount != "") then {
    private _i = _list lbAdd format ["Use account %1", _directAccount];
    _list lbSetData [_i, format ["PIN:%1", _directAccount]];
};

{
    _x params ["_ref", "_label", "_pinRaw", "_kind"];
    private _pin = [_pinRaw] call FCash_fnc_formatAccountNumber;
    private _allowedKind = (_kind == "PERSONAL" && {_showPersonal}) || {_kind == "SHARED" && {_showShared}};
    private _haystack = toLower format ["%1 %2 %3", _label, _pin, _kind];
    private _matches = _query == "" || {_haystack find _query >= 0};
    private _duplicateDirect = _directAccount != "" && {_pin == _directAccount};
    if (_ref != _excludeRef && {_allowedKind} && {_matches} && {!_duplicateDirect}) then {
        private _kindLabel = ["Personal", "Shared"] select (_kind == "SHARED");
        private _i = _list lbAdd format ["%1 | %2 | %3", _label, _pin, _kindLabel];
        _list lbSetData [_i, _ref];
    };
} forEach _rows;

if ((lbSize _list) > 0) then {_list lbSetCurSel 0};

/* Configures the dynamically adapting vanilla-friendly Zeus dialog. */
disableSerialization;
private _display = uiNamespace getVariable ["FCash_ui_zeusDisplay", displayNull];
private _context = uiNamespace getVariable ["FCash_ui_zeusContext", []];
if (isNull _display || {count _context < 4}) exitWith {closeDialog 0};
_context params ["_operation", "_target", "_targetInfo", "_shared"];
_targetInfo params [
    ["_targetName", "", [""]],
    ["_wallet", 0, [0]],
    ["_bank", 0, [0]],
    ["_isStorage", false, [false]],
    ["_stashBalance", 0, [0]]
];

private _mode = _display displayCtrl 61304;
private _account = _display displayCtrl 61306;
private _name = _display displayCtrl 61308;
private _amount = _display displayCtrl 61310;
{(_display displayCtrl _x) ctrlShow false} forEach [61303,61304,61305,61306,61307,61308,61309,61310];

switch (_operation) do {
    case "FUNDS_MANAGE": {
        (_display displayCtrl 61301) ctrlSetText "Manage Funds";
        (_display displayCtrl 61302) ctrlSetText (if (_isStorage) then {
            format ["%1 | Stash %2", _targetName, [_stashBalance] call FCash_fnc_formatMoney]
        } else {
            format ["%1 | Wallet %2 | Bank %3", _targetName, [_wallet] call FCash_fnc_formatMoney, [_bank] call FCash_fnc_formatMoney]
        });
        {(_display displayCtrl _x) ctrlShow true} forEach [61303,61304,61305,61306,61309,61310];
        lbClear _mode;
        {private _i = _mode lbAdd (_x select 1); _mode lbSetData [_i, _x select 0]} forEach [["SET","Set Balance"],["CHANGE","Change Balance"]];
        lbClear _account;
        if (_isStorage) then {
            private _i = _account lbAdd "Stash"; _account lbSetData [_i, "STASH"];
            _amount ctrlSetText str _stashBalance;
        } else {
            {private _i = _account lbAdd (_x select 1); _account lbSetData [_i, _x select 0]} forEach [["WALLET","Wallet"],["BANK","Bank"]];
            _amount ctrlSetText str _wallet;
        };
        _account lbSetCurSel 0;
        _mode lbSetCurSel 0;
    };

    case "SHARED_MANAGE": {
        (_display displayCtrl 61301) ctrlSetText "Manage Shared Banks";
        (_display displayCtrl 61302) ctrlSetText "Create, change balance, or remove a shared bank";
        {(_display displayCtrl _x) ctrlShow true} forEach [61303,61304];
        lbClear _mode;
        {private _i = _mode lbAdd (_x select 1); _mode lbSetData [_i, _x select 0]} forEach [["CREATE","Create"],["CHANGE","Change Balance"],["DELETE","Remove"]];
        lbClear _account;
        {
            _x params ["_id", "_accountName", "_accountBalance", ["_pin", ""]];
            private _i = _account lbAdd format ["%1 | %2 | %3", _accountName, [_accountBalance] call FCash_fnc_formatMoney, [_pin] call FCash_fnc_formatAccountNumber];
            _account lbSetData [_i, _id];
        } forEach _shared;
        if ((lbSize _account) > 0) then {_account lbSetCurSel 0};
        _name ctrlSetText "Shared Bank";
        _amount ctrlSetText "0";
        _mode lbSetCurSel ([0,1] select (count _shared > 0));
    };

    case "STASH_MANAGE": {
        (_display displayCtrl 61301) ctrlSetText "Manage Stash";
        (_display displayCtrl 61302) ctrlSetText format ["%1 | %2", _targetName, ["Not a stash", format ["Current %1", [_stashBalance] call FCash_fnc_formatMoney]] select _isStorage];
        {(_display displayCtrl _x) ctrlShow true} forEach [61303,61304];
        lbClear _mode;
        {private _i = _mode lbAdd (_x select 1); _mode lbSetData [_i, _x select 0]} forEach [["CREATE","Create / Reset"],["CHANGE","Change Balance"],["REMOVE","Remove"]];
        _amount ctrlSetText str _stashBalance;
        _mode lbSetCurSel ([0,1] select _isStorage);
    };
};

[] call FCash_fnc_zeusDialogModeChanged;

/* Remote target: displays a sanitized shared-bank activity log. */
params ["_name", "_pin", ["_rows", []]];
if (!hasInterface) exitWith {};
uiNamespace setVariable ["FCash_ui_sharedLog", [_name, _pin, _rows]];
createDialog "FCash_SharedLogDialog";
disableSerialization;
private _display = findDisplay 61500;
if (isNull _display) exitWith {};
private _accountNumber = [_pin] call FCash_fnc_formatAccountNumber;
(_display displayCtrl 61503) ctrlSetText format ["%1 | %2", _name, ["-------", _accountNumber] select (_accountNumber != "")];
private _list = _display displayCtrl 61501;
lbClear _list;
private _types = createHashMapFromArray [
    ["SHARED_CREATE", "Created"], ["SHARED_DEPOSIT", "Deposit"], ["SHARED_WITHDRAW", "Withdraw"],
    ["SHARED_TRANSFER", "Transfer"], ["SHARED_RECEIVE", "Received"], ["SHARED_ADJUST", "Admin adjustment"],
    ["SHARED_INVITE", "Invite"], ["SHARED_MEMBER", "Member change"], ["SHARED_VISIBILITY", "Visibility"], ["SHARED_RENAME", "Rename"]
];
private _pad = {params ["_n"]; if (_n < 10) then {format ["0%1", _n]} else {str _n}};
_rows = +_rows;
reverse _rows;
{
    _x params ["_when", "_type", "_actorUid", "_actorName", "_amount", "_target", "_details"];
    private _stamp = "";
    if (_when isEqualType [] && {count _when >= 5}) then {
        _stamp = format ["%1-%2-%3 %4:%5", _when select 0, [_when select 1] call _pad, [_when select 2] call _pad, [_when select 3] call _pad, [_when select 4] call _pad];
    };
    private _verb = _types getOrDefault [_type, _type];
    private _amountText = if (_amount == 0) then {""} else {format [" | %1", [_amount] call FCash_fnc_formatMoney]};
    private _targetText = if (_target == "") then {""} else {format [" | %1", _target]};
    _list lbAdd format ["%1 | %2 | %3%4%5", _stamp, _actorName, _verb, _amountText, _targetText];
} forEach _rows;
[_display] call FCash_fnc_uiAnimateIn;

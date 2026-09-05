/* Shows only controls required by the selected Zeus operation mode. */
disableSerialization;
private _display = uiNamespace getVariable ["FCash_ui_zeusDisplay", displayNull];
private _context = uiNamespace getVariable ["FCash_ui_zeusContext", []];
if (isNull _display || {count _context < 1}) exitWith {};
private _operation = _context select 0;
private _modeCtrl = _display displayCtrl 61304;
private _modeIndex = lbCurSel _modeCtrl;
private _mode = if (_modeIndex >= 0) then {_modeCtrl lbData _modeIndex} else {""};

private _show = {
    params ["_idcs", "_state"];
    {(_display displayCtrl _x) ctrlShow _state} forEach _idcs;
};

// Keep operation selector visible; each mode then reveals only its required fields.
[[61303,61304], true] call _show;
[[61305,61306,61307,61308,61309,61310], false] call _show;
private _confirm = _display displayCtrl 61312;
_confirm ctrlSetText "Apply";

switch (_operation) do {
    case "FUNDS_MANAGE": {
        [[61305,61306,61309,61310], true] call _show;
        (_display displayCtrl 61305) ctrlSetText "Fund";
        (_display displayCtrl 61309) ctrlSetText (["Balance", "Change (+/-)"] select (_mode == "CHANGE"));
        _confirm ctrlSetText (["Set", "Apply"] select (_mode == "CHANGE"));
    };

    case "SHARED_MANAGE": {
        switch (_mode) do {
            case "CREATE": {
                [[61307,61308,61309,61310], true] call _show;
                (_display displayCtrl 61307) ctrlSetText "Name";
                (_display displayCtrl 61309) ctrlSetText "Starting balance";
                _confirm ctrlSetText "Create";
            };
            case "DELETE": {
                [[61305,61306], true] call _show;
                (_display displayCtrl 61305) ctrlSetText "Shared bank";
                _confirm ctrlSetText "Remove";
            };
            default {
                [[61305,61306,61309,61310], true] call _show;
                (_display displayCtrl 61305) ctrlSetText "Shared bank";
                (_display displayCtrl 61309) ctrlSetText "Change (+/-)";
                _confirm ctrlSetText "Apply";
            };
        };
    };

    case "STASH_MANAGE": {
        switch (_mode) do {
            case "REMOVE": {
                _confirm ctrlSetText "Remove";
            };
            case "CHANGE": {
                [[61309,61310], true] call _show;
                (_display displayCtrl 61309) ctrlSetText "Change (+/-)";
                _confirm ctrlSetText "Apply";
            };
            default {
                [[61309,61310], true] call _show;
                (_display displayCtrl 61309) ctrlSetText "Starting balance";
                _confirm ctrlSetText "Create";
            };
        };
    };
};

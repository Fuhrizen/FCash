/*
 * Installs ACE actions on one storage or banking terminal object.
 * Parameters: [object <OBJECT>, kind <STORAGE|TERMINAL|NATIVE_TERMINAL>]
 */
params ["_object", "_kind"];
if (!hasInterface || {isNull _object}) exitWith {};

private _flag = ["FCash_actions_storage", "FCash_actions_terminal"] select (_kind in ["TERMINAL", "NATIVE_TERMINAL"]);
if (_object getVariable [_flag, false]) exitWith {};
_object setVariable [_flag, true];

switch (_kind) do {
    case "TERMINAL";
    case "NATIVE_TERMINAL": {
        private _native = _kind == "NATIVE_TERMINAL";
        private _condition = if (_native) then {
            {alive _player}
        } else {
            {alive _player && {_target getVariable ["FCash_isTerminal", false]}}
        };
        private _action = [
            "FCash_OpenBanking_Object", "Open banking", "\A3\ui_f\data\gui\Rsc\RscDisplayArsenal\cargoMisc_ca.paa",
            {[_target] call FCash_fnc_openBanking},
            _condition
        ] call ace_interact_menu_fnc_createAction;
        [_object, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;
    };
    case "STORAGE": {
        private _deposit = [
            "FCash_StorageDeposit", "Store cash", "\A3\ui_f\data\gui\Rsc\RscDisplayArsenal\cargoPut_ca.paa",
            {[_target, "STORAGE_DEPOSIT"] call FCash_fnc_openAmountDialog},
            {alive _player && {_target getVariable ["FCash_isStorage", false]}}
        ] call ace_interact_menu_fnc_createAction;
        private _withdraw = [
            "FCash_StorageWithdraw", "Take cash", "",
            {[_target, "STORAGE_WITHDRAW"] call FCash_fnc_openAmountDialog},
            {alive _player && {_target getVariable ["FCash_isStorage", false]}},
            {}, [], {[0,0,0]}, 2, [false,false,false,false,false],
            {
                params ["_target", "_player", "_actionParams", "_actionData"];
                _actionData set [1, format ["Take cash (%1)", [_target getVariable ["FCash_storageBalance", 0]] call FCash_fnc_formatMoney]];
            }
        ] call ace_interact_menu_fnc_createAction;
        [_object, 0, ["ACE_MainActions"], _deposit] call ace_interact_menu_fnc_addActionToObject;
        [_object, 0, ["ACE_MainActions"], _withdraw] call ace_interact_menu_fnc_addActionToObject;
    };
};

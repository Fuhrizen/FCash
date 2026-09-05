/*
 * Initializes a Fuhrizen's Cash Zeus module.
 * Mirrors the locality-safe curator module pattern used by ZEN:
 * - hide and group the logic on the server
 * - execute the configured module function only where the logic is local
 *
 * Parameters: [logic <OBJECT>]
 */
params [["_logic", objNull, [objNull]]];
if (isNull _logic) exitWith {};

_logic hideObject true;

if (isServer) then {
    [{
        params ["_logic"];
        if (isNull _logic) exitWith {};

        private _category = getText (configOf _logic >> "category");
        private _logicMain = missionNamespace getVariable ["bis_functions_mainscope", objNull];
        if (isNull _logicMain) exitWith {};

        private _group = missionNamespace getVariable [format ["bis_fnc_initModules_%1", _category], group _logicMain];
        [_logic] joinSilent _group;
    }, _logic] call CBA_fnc_execNextFrame;
};

if (!local _logic) exitWith {};

[{
    params ["_logic"];
    if (isNull _logic) exitWith {};

    private _functionName = getText (configOf _logic >> "function");
    if (_functionName == "") exitWith {deleteVehicle _logic};

    private _function = missionNamespace getVariable [_functionName, {}];
    [_logic] call _function;
}, _logic] call CBA_fnc_execNextFrame;
